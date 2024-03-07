import 'package:flutter/material.dart';
import 'notes_screen.dart';

//1.Main method of the app
void main() {
  runApp(const NoteApp());
}
//2.Stateless widget
class NoteApp extends StatelessWidget {
  const NoteApp({super.key});
//3. Build with theme and home
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Notebook',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const NotesScreen(),
    );
  }
}
