import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

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
          final args = settings.arguments;

          // On attend un ProductModel (directement ou dans une map)
          if (args is ProductModel) {
            return MaterialPageRoute(
              builder: (_) => ProductDetailPage(product: args),
              settings: settings,
            );
          }
          if (args is Map && args['product'] is ProductModel) {
            return MaterialPageRoute(
              builder: (_) => ProductDetailPage(product: args['product'] as ProductModel),
              settings: settings,
            );
          }

          // Erreur d'arguments
          return MaterialPageRoute(
            builder: (_) => const _RouteErrorPage(
              message: 'Argument invalide pour /product-detail : ProductModel requis.',
            ),
            settings: settings,
          );
        }

        // Fallback routes inconnues
        return MaterialPageRoute(
          builder: (_) => _RouteErrorPage(message: 'Route inconnue : ${settings.name}'),
          settings: settings,
        );
      },
    );
  }
}

class _RouteErrorPage extends StatelessWidget {
  final String message;
  const _RouteErrorPage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigation')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(message, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
