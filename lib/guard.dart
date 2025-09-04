import 'package:flutter/material.dart';

class Guard extends StatelessWidget {
  final String redirectTo;

  const Guard({
    super.key,
    this.redirectTo = '/login', // Route par défaut
  });

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, redirectTo);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.blue,
            ),
            SizedBox(height: 20),
            Text(
              'Redirection en cours...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}