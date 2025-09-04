import 'package:flutter/material.dart';
// 🔥 AJOUT : Import Firebase Auth pour l'inscription
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/drawer.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //  AJOUT : Controllers pour les 3 champs (email, password, confirm)
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  //  AJOUT : Variables d'état
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    //  AJOUT : Nettoyage des 3 controllers
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  //  AJOUT : Fonction principale d'inscription
  Future<void> _register() async {
    // Validation des champs vides
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez remplir tous les champs';
      });
      return;
    }

    //  AJOUT : Validation que les mots de passe correspondent
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Les mots de passe ne correspondent pas.';
      });
      return;
    }

    //  AJOUT : Validation de la longueur du mot de passe
    if (_passwordController.text.length < 6) {
      setState(() {
        _errorMessage = 'Le mot de passe doit contenir au moins 6 caractères.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // 🔥 CŒUR : Création du compte avec Firebase
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        // Message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscription réussie ! Vous êtes maintenant connecté.'),
            backgroundColor: Colors.green,
          ),
        );
        //  BONUS : L'utilisateur est automatiquement connecté après inscription
        Navigator.pushReplacementNamed(context, '/');
      }
    } on FirebaseAuthException catch (e) {
      // Gestion des erreurs Firebase
      setState(() {
        _errorMessage = _getErrorMessage(e.code);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Une erreur inattendue s\'est produite';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  // 🔥 AJOUT : Traduction des erreurs d'inscription
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'email-already-in-use':
        return 'Cette adresse email est déjà utilisée.';
      case 'weak-password':
        return 'Le mot de passe est trop faible.';
      case 'invalid-email':
        return 'Adresse email invalide.';
      case 'operation-not-allowed':
        return 'L\'inscription par email est désactivée.';
      default:
        return 'Une erreur est survenue. Veuillez réessayer.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
        backgroundColor: Colors.blue[600], // Couleur différente du login
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône d'inscription
            Icon(
              Icons.person_add,
              size: 100,
              color: Colors.blue[600],
            ),
            const SizedBox(height: 30),

            // Champ email (identique au login)
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // 🔥 AJOUT : Champ mot de passe avec indication de longueur
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Mot de passe',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
                helperText: 'Au moins 6 caractères', // Aide utilisateur
              ),
              obscureText: true,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // 🔥 AJOUT : Champ de confirmation du mot de passe
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirmer le mot de passe',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline), // Icône différente
              ),
              obscureText: true,
              enabled: !_isLoading,
              onSubmitted: (_) => _register(), // Inscription avec Entrée
            ),
            const SizedBox(height: 24),

            // Affichage des erreurs (identique au login)
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

            // 🔥 AJOUT : Bouton d'inscription (couleur verte)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('S\'inscrire', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 16),

            // 🔥 AJOUT : Lien vers la page de connexion
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () => Navigator.pushReplacementNamed(context, '/login'),
              child: const Text('Déjà un compte ? Se connecter'),
            ),
          ],
        ),
      ),
    );
  }
}
