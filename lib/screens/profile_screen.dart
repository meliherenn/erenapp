import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:erenapp/screens/edit_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Future'ı state'te tutarak gereksiz yere yeniden fetch etmeyi engelliyoruz
  late Future<DocumentSnapshot> _userFuture;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = _auth.currentUser;
    if (user != null) {
      _userFuture = _firestore.collection('users').doc(user.uid).get();
    }
  }

  String _formatBirthDate(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'Belirtilmemiş';
    }
    return DateFormat('dd/MM/yyyy').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: user == null ? null : () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(userId: user.uid),
                ),
              );

              // Düzenleme ekranından geri dönüldüğünde ve "kaydet" basıldıysa
              // state'i güncelleyerek ekranın yeniden çizilmesini sağlıyoruz.
              if (result == true) {
                setState(() {
                  _loadUserData();
                });
              }
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('Lütfen profilinizi görmek için giriş yapın.'))
          : FutureBuilder<DocumentSnapshot>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Kullanıcı bilgileri veritabanında bulunamadı.'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const Icon(Icons.person, size: 40),
                  title: const Text("Ad Soyad", style: TextStyle(color: Colors.grey)),
                  subtitle: Text(
                    userData['name_surname'] ?? 'Bilgi Yok',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
                const Divider(height: 20),
                ListTile(
                  leading: const Icon(Icons.email, size: 40),
                  title: const Text("E-posta Adresi", style: TextStyle(color: Colors.grey)),
                  subtitle: Text(
                    userData['email'] ?? 'Bilgi Yok',
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
                const Divider(height: 20),
                ListTile(
                  leading: const Icon(Icons.calendar_today, size: 40),
                  title: const Text("Doğum Tarihi", style: TextStyle(color: Colors.grey)),
                  subtitle: Text(
                    _formatBirthDate(userData['birth_date'] as Timestamp?),
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}