import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erenapp/models/product_model.dart';
import 'package:erenapp/screens/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:erenapp/screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Product>> _productsFuture;
  final Set<int> _favoriteProductIds = {};
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  final _searchController = TextEditingController();

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _productsFuture = _fetchAndLoadData();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProducts);
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Product>> _fetchAndLoadData() async {
    await _loadFavorites();
    return await _fetchProducts();
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        return product.title.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _loadFavorites() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final favoritesSnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .get();
    if (mounted) {
      setState(() {
        _favoriteProductIds.clear();
        for (var doc in favoritesSnapshot.docs) {
          _favoriteProductIds.add(int.parse(doc.id));
        }
      });
    }
  }

  Future<List<Product>> _fetchProducts() async {
    final response = await http.get(Uri.parse('https://dummyjson.com/products'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> productList = data['products'];
      if(mounted) {
        setState(() {
          _allProducts = productList.map((json) => Product.fromJson(json)).toList();
          _filteredProducts = _allProducts;
        });
      }
      return _filteredProducts;
    } else {
      throw Exception('Ürünler yüklenemedi');
    }
  }

  Future<void> _toggleFavorite(Product product) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final favoriteRef = _firestore.collection('users').doc(user.uid).collection('favorites').doc(product.id.toString());
    setState(() {
      if (_favoriteProductIds.contains(product.id)) {
        _favoriteProductIds.remove(product.id);
        favoriteRef.delete();
      } else {
        _favoriteProductIds.add(product.id);
        favoriteRef.set(product.toMap());
      }
    });
  }

  Future<void> _addToCart(Product product) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final cartRef = _firestore.collection('users').doc(user.uid).collection('cart').doc(product.id.toString());
    final doc = await cartRef.get();
    if (doc.exists) {
      await cartRef.update({'quantity': FieldValue.increment(1)});
    } else {
      await cartRef.set({...product.toMap(), 'quantity': 1});
    }
    if(mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${product.title} sepete eklendi.'), duration: const Duration(seconds: 1)));
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ürünler'), actions: [IconButton(icon: const Icon(Icons.logout), onPressed: _logout, tooltip: 'Çıkış Yap')]),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(labelText: 'Ürün Ara', prefixIcon: Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10.0)))),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting && _allProducts.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Hata: ${snapshot.error}'));
                } else if (_filteredProducts.isEmpty && _searchController.text.isNotEmpty) {
                  return const Center(child: Text('Aramanızla eşleşen ürün bulunamadı.'));
                } else if (_allProducts.isNotEmpty) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(10.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.65, crossAxisSpacing: 10, mainAxisSpacing: 10),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      final isFavorite = _favoriteProductIds.contains(product.id);
                      return InkWell(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product))),
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          elevation: 5,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(child: Image.network(product.thumbnail, fit: BoxFit.cover)),
                                  Padding(padding: const EdgeInsets.all(8.0), child: Text(product.title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                  Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: Text('\$${product.price}', style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold))),
                                  Padding(padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 8.0), child: ElevatedButton(onPressed: () => _addToCart(product), child: const Text('Sepete Ekle'))),
                                ],
                              ),
                              Positioned(top: 0, right: 0, child: IconButton(icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : Colors.grey), onPressed: () => _toggleFavorite(product))),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('Ürün bulunamadı.'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}