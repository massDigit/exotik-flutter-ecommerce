import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_ecommerce/pages/home_page.dart';
import 'package:flutter_ecommerce/pages/login_page.dart';
import 'package:flutter_ecommerce/pages/register_page.dart';
import 'package:flutter_ecommerce/pages/second_page.dart';
import 'package:flutter_ecommerce/pages/third_page.dart';
import 'firebase_options.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Drawer Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const MyHomePage(),
        '/second': (_) => const SecondPage(),
        '/third': (_) => const ThirdPage(),
        // 🔥 AJOUT : Nouvelles routes pour l'authentification
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
      },
    );
  }
}