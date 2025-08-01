import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:erenapp/models/product_model.dart';
import 'package:erenapp/screens/product_detail_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<void> _updateQuantity(String productId, int newQuantity) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final productRef = _firestore.collection('users').doc(user.uid).collection('cart').doc(productId);
    if (newQuantity > 0) {
      await productRef.update({'quantity': newQuantity});
    } else {
      await productRef.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sepetim'),
      ),
      body: user == null
          ? const Center(child: Text('Sepetinizi görmek için lütfen giriş yapın.'))
          : StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('users').doc(user.uid).collection('cart').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('Sepetiniz şu an boş.'));

          final cartItems = snapshot.data!.docs;

          return ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final itemData = cartItems[index].data() as Map<String, dynamic>;
              final product = Product.fromJson(itemData);
              final quantity = itemData['quantity'] as int;
              final productId = cartItems[index].id;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product))),
                    leading: Image.network(product.thumbnail, width: 50, height: 50, fit: BoxFit.cover),
                    title: Text(product.title),
                    subtitle: Text('\$${product.price}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => _updateQuantity(productId, quantity - 1)),
                        Text(quantity.toString(), style: const TextStyle(fontSize: 16)),
                        IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => _updateQuantity(productId, quantity + 1)),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}