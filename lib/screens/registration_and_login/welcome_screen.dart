import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import 'registration_screen.dart';
import 'login_screen.dart';
import 'package:notebook/custom_provider.dart';

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
                Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('images/notebook-2.png'),
                    height: 100,

                  ),
                ),
                DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.w900,
                    color: Provider.of<ColorProvider>(context).selectedColor,
                  ),
                  child: Text('Notebook'),
                ),
              ],
            ),
            SizedBox(height: 48),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(),
                    ),
                  );
                },
                child: Text(AppLocalizations.of(context)!.translate('logIn'))),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegistrationScreen(),
                    ),
                  );
                },
                child: Text(AppLocalizations.of(context)!.translate('register'))),
          ],
        ),
      ),
    );
  }
}
