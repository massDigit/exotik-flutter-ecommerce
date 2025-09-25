import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_ecommerce/pages/web_product_detail_page.dart';

import 'firebase_options.dart';

// Pages
import 'pages/home_page.dart';
import 'pages/web_home_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/third_page.dart';
import 'pages/product_detail_page.dart';

// Models
import 'model/product_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AppRoot());
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final isIOS = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

    return MaterialApp(
      title: kIsWeb ? 'E-Commerce (Web)' : (isIOS ? 'E-Commerce (iOS)' : 'E-Commerce'),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => kIsWeb ? const WebHomePage() : const MyHomePage(),
        '/third': (_) => const ThirdPage(),
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        // '/product-detail' est gérée dans onGenerateRoute
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/product-detail') {
          final arg = settings.arguments;
          if (arg is ProductModel) {
            return MaterialPageRoute(
              builder: (_) => kIsWeb
                  ? WebProductDetailPage(product: arg)
                  : ProductDetailPage(product: arg),
              settings: settings,
            );
          }
          // Fallback si l'argument n'est pas bon
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Produit invalide')),
            ),
            settings: settings,
          );
        }
        return null; // ou ta route inconnue
      },
    );
  }
}

