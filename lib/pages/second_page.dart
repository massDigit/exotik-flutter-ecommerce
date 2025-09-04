import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/widgets/drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_ecommerce/guard.dart';

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});


  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Si l'utilisateur n'est pas connecté, rediriger vers la page de connexion
    if (user == null) {
      return const Guard();
    }

    // Si l'utilisateur est connecté, afficher la page
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Page'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.explore,
              size: 100,
              color: Colors.green,
            ),
            SizedBox(height: 20),
            Text(
              'Vous êtes sur la deuxième page !',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'Ceci est la page secondaire',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Action pour retourner à la page précédente
                Navigator.pushReplacementNamed(context, '/');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                'Retour',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}