import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/widgets/drawer.dart';

class ThirdPage extends StatelessWidget {
  const ThirdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Third Page'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      drawer: const AppDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star,
              size: 100,
              color: Colors.purple,
            ),
            SizedBox(height: 20),
            Text(
              'Bienvenue sur la troisième page !',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              'Ceci est la page tertiaire',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
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
