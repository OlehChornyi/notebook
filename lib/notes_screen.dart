import 'dart:io';

import 'package:flutter/material.dart';
import 'create_screen.dart';
import 'detail_screen.dart';
import 'db_helper.dart';

//1. Stateful widget
class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});
  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

//2. Extension with list of maps
class _NotesScreenState extends State<NotesScreen> {
  List<Map<String, dynamic>> _values = [];
//3. Screen state initialization with the usage of table values loading
  @override
  void initState() {
    super.initState();
    _loadValues();
  }

//4. A method to load all values from the db table
  Future<void> _loadValues() async {
    List<Map<String, dynamic>> values = await DatabaseHelper().getValues();
    setState(() {
      _values = values;
    });
  }

//5. A method to delete a single value from the db table
  Future<void> _deleteValue(int id) async {
    await DatabaseHelper().deleteValue(id);
    _loadValues();
  }

//6. Helper method to navigate to the detail screen
  void _navigateToDetailScreen(int id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailScreen(recordId: id)),
    );
  }

  String formattedDateTime(DateTime dateTime) {
    return '${dateTime.day}-${dateTime.month}-${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }

  void _confirmDeleteDialog(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this note?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteNote(id);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteNote(int id) {
    // Perform the delete operation here
    DatabaseHelper().deleteValue(id);
    // After deleting, you may want to refresh the list
    // _deleteValue(_values[index]['id']);
    _loadValues();
  }

//7. Build with Scaffold and AppBar
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => exit(0),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('All notes'),
      ),
      //8. ListView builder with gesture detector
      body: ListView.builder(
        itemCount: _values.length,
        itemBuilder: (context, index) {
          DateTime updatedAt = DateTime.parse(_values[index]['updated_at']);
          return GestureDetector(
            onTap: () {
              _navigateToDetailScreen(_values[index]['id']);
            },
            //9. Card with IconButton
            child: Card(
              margin: const EdgeInsets.all(16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          '${_values[index]['value']}',
                          style: const TextStyle(fontSize: 20.0),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      IconButton(
                        onPressed: () {
                          _confirmDeleteDialog(_values[index]['id']);
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                    // SizedBox(height: 8.0),
                    Text('${formattedDateTime(updatedAt)}'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      //10. Floating action button with route to the CreateNoteScreen
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateNoteScreen()),
          );
        },
        tooltip: 'Create note',
        child: const Icon(Icons.add),
      ),
    );
  }
}
