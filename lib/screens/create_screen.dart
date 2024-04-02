import 'package:flutter/material.dart';
import 'catalog_detail_screen.dart';
import 'package:notebook/fb_helper.dart';
import 'notes_screen.dart';
import '../color_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db_helper.dart';

//1.Stateful widget
class CreateNoteScreen extends StatefulWidget {
  final String catalogName;

  CreateNoteScreen(this.catalogName);
  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}
//2.Extension with controller and db values
class _CreateNoteScreenState extends State<CreateNoteScreen> {
  final myController = TextEditingController();
//3.Build with Scaffold and AppBar
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Write something'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              String value = myController.text;
              await FirebaseHelper().insertValue(value, widget.catalogName);
              // await DatabaseHelper().insertValue(value, widget.catalogName);
              myController.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('New note has been created'),
                  ));
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CatalogDetailScreen(widget.catalogName)),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              //4.Text field for the info input
              TextField(
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Put your note here',
                ),
                controller: myController,
                maxLines: null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
