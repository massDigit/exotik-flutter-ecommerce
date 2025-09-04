import 'package:flutter/material.dart';
// 🔥 AJOUT : Import Firebase Auth pour la connexion
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/drawer.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 🔥 AJOUT : Controllers pour gérer les champs de texte
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // 🔥 AJOUT : Variables pour gérer l'état de la page
  bool _isLoading = false; // Indique si une connexion est en cours
  String _errorMessage = ''; // Stocke les messages d'erreur

  @override
  void dispose() {
    // 🔥 AJOUT : Nettoie les controllers pour éviter les fuites mémoire
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 🔥 AJOUT : Fonction principale de connexion
  Future<void> _signIn() async {

    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez remplir tous les champs';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 🔥 CŒUR : Tentative de connexion avec Firebase
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Si la connexion réussit et que le widget est toujours monté
      if (mounted) {
        // Affiche un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connexion réussie !'),
            backgroundColor: Colors.green,
          ),
        );
        // Redirige vers l'accueil
        Navigator.pushReplacementNamed(context, '/');
      }
    } on FirebaseAuthException catch (e) {
      // 🔥 AJOUT : Gestion des erreurs spécifiques Firebase
      setState(() {
        _errorMessage = _getErrorMessage(e.code);
      });
    } catch (e) {
      // Gestion des autres erreurs
      setState(() {
        _errorMessage = 'Une erreur inattendue s\'est produite';
      });
    }

    // Désactive l'état de chargement
    setState(() {
      _isLoading = false;
    });
  }

  // 🔥 AJOUT : Fonction qui traduit les codes d'erreur Firebase en français
  // Liste des erreurs ici : https://firebase.google.com/docs/auth/admin/errors?hl=fr
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Aucun utilisateur trouvé avec cette adresse email.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'invalid-email':
        return 'Adresse email invalide.';
      case 'user-disabled':
        return 'Ce compte a été désactivé.';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard.';
      default:
        return 'Une erreur est survenue. Veuillez réessayer.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      // 🔥 AJOUT : Le drawer est accessible même depuis la page de connexion
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône de connexion
            Icon(
              Icons.account_circle,
              size: 100,
              color: Colors.blue[600],
            ),
            const SizedBox(height: 30),

            // 🔥 AJOUT : Champ email avec validation
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              enabled: !_isLoading, // Désactivé pendant le chargement
            ),
            const SizedBox(height: 16),

            // 🔥 AJOUT : Champ mot de passe
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Mot de passe',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true, // Cache le texte
              enabled: !_isLoading,
              onSubmitted: (_) => _signIn(), // Connexion avec Entrée
            ),
            const SizedBox(height: 24),

            // 🔥 AJOUT : Affichage conditionnel des messages d'erreur
            if (_errorMessage.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[300]!),
                ),
                child: Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red[700]),
                  textAlign: TextAlign.center,
                ),
              ),

            if (_errorMessage.isNotEmpty) const SizedBox(height: 16),

            // 🔥 AJOUT : Bouton de connexion avec état de chargement
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _signIn, // Désactivé pendant chargement
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Se connecter', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),

            // 🔥 AJOUT : Lien vers la page d'inscription
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () => Navigator.pushReplacementNamed(context, '/register'),
              child: const Text('Pas de compte ? S\'inscrire'),
            ),
          ],
        ),
      ),
    );
  }
}
