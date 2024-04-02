import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notebook/screens/catalog_screen.dart';
import 'package:provider/provider.dart';
import '../catalog_detail_screen.dart';
import 'registration_screen.dart';
import 'package:notebook/color_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  late String email;
  late String password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: Hero(
                tag: 'logo',
                child: Container(
                  height: 200,
                  child: Image.asset('images/notebook-2.png'),
                ),
              ),
            ),
            SizedBox(height: 48),
            TextField(
              keyboardType: TextInputType.emailAddress,
              textAlign: TextAlign.center,
              onChanged: (value) {
                email = value;
              },
              decoration: InputDecoration(
                hintText: 'Enter your email',
              ),
            ),
            SizedBox(height: 8),
            TextField(
              obscureText: true,
              textAlign: TextAlign.center,
              onChanged: (value) {
                password = value;
              },
              decoration: InputDecoration(
                hintText: 'Enter your password',
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
                onPressed: () async {
                  setState(() {
                    showSpinner = true;
                  });
                  try {
                    final user = await _auth.signInWithEmailAndPassword(
                        email: email, password: password);
                    Provider.of<CatalogProvider>(context, listen: false)
                        .clearCatalogNames();
                    Provider.of<CatalogProvider>(context, listen: false)
                        .loadCatalogNames();
                    Provider.of<CatalogProvider>(context, listen: false)
                        .saveCatalogNames();
                    final catalogNames =
                        Provider.of<CatalogProvider>(context, listen: false)
                            .catalogNames;
                    if (user != null) {
                      if (catalogNames.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CatalogScreen(),
                          ),
                        );
                      } else {
                        Provider.of<CatalogProvider>(context, listen: false)
                            .addCatalog('Notes');
                        Provider.of<CatalogProvider>(context, listen: false)
                            .saveCatalogNames();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CatalogDetailScreen(catalogNames[0]),
                          ),
                        );
                      }
                    }
                    setState(() {
                      showSpinner = false;
                    });
                  } catch (e) {
                    print(e);
                  }
                },
                child: Text('Log In')),
            SizedBox(height: 24),
            TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RegistrationScreen(),
                    ),
                  );
                },
                child: Text("Don't have an account? Register!")),
          ],
        ),
      ),
    );
  }
}
