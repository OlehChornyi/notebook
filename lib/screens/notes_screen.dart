import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notebook/main.dart';
import 'catalog_screen.dart';
import 'create_screen.dart';
import 'package:notebook/screens/detail_screen.dart';
import '../db_helper.dart';
import 'package:provider/provider.dart';
import '../custom_provider.dart';
import 'catalog_detail_screen.dart';
import 'package:notebook/fb_helper.dart';

//1. Stateful widget
class NotesScreen extends StatefulWidget {
  NotesScreen();

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Map<String, dynamic>> _values = [];

  @override
  void initState() {
    _loadValues();
    super.initState();
  }

  Future<void> _loadValues() async {
    List<Map<String, dynamic>> values = await FirebaseHelper().fetchValues();
    setState(() {
      _values = values;
    });
  }

  String formattedDateTime(DateTime dateTime) {
    return '${dateTime.day}-${dateTime.month}-${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }

  void _navigateToDetailScreen(String id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailScreen(id, 'General notes')),
    );
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference notes = FirebaseFirestore.instance.collection('notes');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('All notes'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CatalogScreen()),
            );
          },
        ),
      ),

      body: ListView.builder(
        itemCount: _values.length,
        itemBuilder: (context, index) {
          DateTime updatedAt = DateTime.parse(_values[index]['updated_at']);
          return GestureDetector(
            onTap: () {
              _navigateToDetailScreen(_values[index]['id']);
            },
            child: Card(
              margin: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            // note.value,
                            '${_values[index]['value']}',
                            style: const TextStyle(fontSize: 20.0),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        IconButton(
                          onPressed: () {
                            // _confirmDeleteDialog(_values[index]['id']);
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                    Text('${formattedDateTime(updatedAt)}'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      //14. Floating action button with route to the CreateNoteScreen
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CreateNoteScreen('General notes')),
          );
        },
        tooltip: 'Create note',
        child: const Icon(Icons.add),
      ),
    );
  }
}
