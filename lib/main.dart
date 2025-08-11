import 'package:erenapp/firebase_options.dart';
import 'package:erenapp/screens/login_screen.dart';
import 'package:erenapp/screens/onboarding_screen.dart';
import 'package:erenapp/route/route_constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase'i burada başlatıyoruz
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  final seen = prefs.getBool('seen_onboarding') ?? false;

  runApp(MyApp(seenOnboarding: seen));
}

class MyApp extends StatelessWidget {
  final bool seenOnboarding;
  const MyApp({super.key, required this.seenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Eren App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: seenOnboarding ? const LoginScreen() : const OnBordingScreen(),
      routes: {
        logInScreenRoute: (context) => const LoginScreen(),
      },
    );
  }
}