import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Hero(tag: 'logo', child: Icon(Icons.note)),
                DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.w900,
                    color: Colors.black54,
                  ),
                  child: Text('Notebook'),
                ),
              ],
            ),
            SizedBox(height: 48),
            TextButton(onPressed: () {}, child: Text('Log In')),
            TextButton(onPressed: () {}, child: Text('Register')),
          ],
        ),
      ),
    );
  }
}
