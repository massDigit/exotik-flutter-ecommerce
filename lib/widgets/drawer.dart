import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _go(BuildContext context, String route) {
    Navigator.pop(context);
    final current = ModalRoute.of(context)?.settings.name;
    if (current == route) return;
    Navigator.pushReplacementNamed(context, route);
  }

  Future<void> _signOut(BuildContext context) async {
    // Capture les états AVANT l'await
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    nav.pop();

    try {
      await FirebaseAuth.instance.signOut();
      messenger.showSnackBar(
        const SnackBar(content: Text('Déconnecté avec succès')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Erreur lors de la déconnexion: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // AJOUT : Récupère l'utilisateur actuellement connecté (null si pas connecté)
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // MODIFICATION : DrawerHeader intelligent qui affiche les infos utilisateur
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'lib/assets/images/logo/playstore.png',
                  height: 40,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 10),
                // 🔥 AJOUT : Affichage conditionnel selon l'état de connexion
                if (user != null) ...[
                  // Si l'utilisateur est connecté
                  // const Icon(Icons.account_circle, color: Colors.white, size: 40),
                  const SizedBox(height: 5),
                  Text(
                    user.email ?? 'Utilisateur connecté',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ] else
                // Si l'utilisateur n'est pas connecté
                  const Text(
                    'Non connecté',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
              ],
            ),
          ),

          // Section Navigation (inchangée)
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Accueil'),
            onTap: () => _go(context, '/'),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Third Page'),
            onTap: () => _go(context, '/third'),
          ),

          const Divider(),

          // AJOUT : Section Authentification intelligente
          if (user == null) ...[
            // Si pas connecté, affiche les options de connexion
            ListTile(
              leading: const Icon(Icons.login, color: Colors.grey),
              title: const Text('Se connecter'),
              onTap: () => _go(context, '/login'),
            ),
            ListTile(
              leading: const Icon(Icons.person_add, color: Colors.blueAccent),
              title: const Text('S\'inscrire'),
              onTap: () => _go(context, '/register'),
            ),
          ] else ...[
            // Si connecté, affiche l'option de déconnexion
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Se déconnecter'),
              onTap: () => _signOut(context),
            ),
          ],
        ],
      ),
    );
  }
}
