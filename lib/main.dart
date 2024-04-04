import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notebook/firebase_options.dart';
import 'screens/catalog_screen.dart';
import 'screens/registration_and_login/welcome_screen.dart';
import 'custom_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

//1.Main method of the app
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ColorProvider()),
      ChangeNotifierProvider(create: (_) => CatalogProvider())
    ],
      child: NoteApp(prefs)));
}

//2.Stateless widget
class NoteApp extends StatelessWidget {
  final SharedPreferences prefs;

  const NoteApp(this.prefs);
//3. Build with theme and home
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Notebook',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Provider.of<ColorProvider>(context).selectedColor),
        useMaterial3: true,
      ),
      // home: WelcomeScreen(),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else {
          if (snapshot.hasData && snapshot.data != null) {
            return CatalogScreen();
          } else {
            return WelcomeScreen();
          }
        }
      },
    );
  }
}