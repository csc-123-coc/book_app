import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart'; // Ensure you have this package in your pubspec.yaml

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: const Text('Team Busog Library'),
        backgroundColor: Colors.brown,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.brown[300],
                ),
                child: const Icon(
                  LineAwesomeIcons.book_open_solid,
                  size: 100, // Adjust the size as needed
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20), // Space between icon and text
            const Text(
              'Rent a Book',
              style: TextStyle(
                fontSize: 24, // Adjust the font size as needed
                color: Colors.brown,
                fontStyle: FontStyle.italic, // Set the font style to italic
              ),
            ), // Closing the Text widget
          ],
        ),
      ),
    );
  }
}
