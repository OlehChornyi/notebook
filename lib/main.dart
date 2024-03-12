import 'package:flutter/material.dart';
import 'notes_screen.dart';
import 'color_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

//1.Main method of the app
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(ChangeNotifierProvider(
      create: (context) => ColorProvider(),
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
              colorScheme:
              ColorScheme.fromSeed(seedColor: Provider.of<ColorProvider>(context).selectedColor),
              useMaterial3: true,
            ),
      home: const NotesScreen(),
    );
  }
}
