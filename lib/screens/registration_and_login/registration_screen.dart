import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notebook/screens/catalog_screen.dart';
import 'package:provider/provider.dart';
import '../../custom_provider.dart';
import '../../main.dart';
import 'login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
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
            TextFormField(
              autovalidateMode: AutovalidateMode.always,
              validator: (String? value) {
                const pattern = r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
                    r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
                    r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
                    r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
                    r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
                    r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
                    r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
                final regex = RegExp(pattern);

                return value!.isNotEmpty && !regex.hasMatch(value)
                    ? AppLocalizations.of(context)!.translate('validEmail')
                    : null;
              },
              keyboardType: TextInputType.emailAddress,
              textAlign: TextAlign.center,
              onChanged: (value) {
                email=
                value;
              },
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.translate('enterEmail'),
              ),
            ),
            SizedBox(height: 8
            ),
            TextFormField(
              autovalidateMode: AutovalidateMode.always,
              validator: (value) {
                return value!.isNotEmpty && value!.length < 6
                    ? AppLocalizations.of(context)!.translate('validPass')
                    : null;
              },
              obscureText: true,
              textAlign: TextAlign.center,
              onChanged: (value) {
                password=
                value;
              },
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.translate('enterPass'),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(onPressed: () async {
              setState(() {
                showSpinner = true;
              });
              try {
                final newUser = await _auth.createUserWithEmailAndPassword(email: email, password: password);
                Provider.of<CatalogProvider>(context, listen: false).clearCatalogNames();

                if (newUser != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CatalogScreen(),
                    ),
                  );
                }
              setState(() {
                showSpinner = false;
              });
              } catch(e) {
                print(e);
              }
            }, child: Text(AppLocalizations.of(context)!.translate('register'))),
            SizedBox(height: 24),
            TextButton(onPressed: () {Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    LoginScreen(),
              ),
            );}, child: Text(AppLocalizations.of(context)!.translate('haveAccount'))),
          ],
        ),
      ),
    );
  }
}
