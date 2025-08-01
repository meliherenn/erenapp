import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erenapp/models/product_model.dart';
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
  final Set<int> _favoriteProductIds = {}; // Favori ürün ID'lerini tutacak set

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _productsFuture = fetchProducts();
    _loadFavorites();
  }

  // Sayfa yüklendiğinde kullanıcının favorilerini Firestore'dan çeker
  void _loadFavorites() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final favoritesSnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .get();

    setState(() {
      for (var doc in favoritesSnapshot.docs) {
        _favoriteProductIds.add(doc['id']);
      }
    });
  }

  Future<List<Product>> fetchProducts() async {
    final response =
    await http.get(Uri.parse('https://dummyjson.com/products'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> productList = data['products'];
      return productList.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  // Kalp ikonuna tıklandığında çalışır
  Future<void> _toggleFavorite(Product product) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final favoriteRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(product.id.toString());

    final isFavorite = _favoriteProductIds.contains(product.id);

    setState(() {
      if (isFavorite) {
        _favoriteProductIds.remove(product.id);
        favoriteRef.delete(); // Firestore'dan sil
      } else {
        _favoriteProductIds.add(product.id);
        favoriteRef.set(product.toMap()); // Firestore'a ekle
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite
              ? '${product.title} favorilerden kaldırıldı.'
              : '${product.title} favorilere eklendi.',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _logout() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ürünler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Çıkış Yap',
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final products = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(10.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final isFavorite = _favoriteProductIds.contains(product.id);
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Image.network(
                              product.thumbnail,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.error);
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              product.title,
                              style:
                              const TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0)
                                .copyWith(bottom: 8.0),
                            child: Text(
                              '\$${product.price}',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Favori ikonu
                      Positioned(
                        top: 4,
                        right: 4,
                        child: CircleAvatar(
                          backgroundColor: Colors.black.withOpacity(0.4),
                          child: IconButton(
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.white,
                            ),
                            onPressed: () => _toggleFavorite(product),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('Ürün bulunamadı.'));
          }
        },
      ),
    );
  }
}