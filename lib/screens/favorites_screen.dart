import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:erenapp/models/product_model.dart';
import 'package:erenapp/screens/product_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorilerim'),
      ),
      body: user == null
          ? const Center(child: Text('Lütfen favorilerinizi görmek için giriş yapın.'))
          : StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').doc(user.uid).collection('favorites').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('Henüz favori ürününüz bulunmuyor.'));

          final favoriteProducts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: favoriteProducts.length,
            itemBuilder: (context, index) {
              final product = Product.fromJson(favoriteProducts[index].data() as Map<String, dynamic>);
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: Image.network(product.thumbnail, width: 50, height: 50, fit: BoxFit.cover),
                  title: Text(product.title),
                  subtitle: Text('\$${product.price}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product))),
                ),
              );
            },
          );
        },
      ),
    );
  }
}