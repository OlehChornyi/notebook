import 'package:flutter/material.dart';
import 'package:notebook/screens/archive_detail_screen.dart';
import '../main.dart';
import 'catalog_screen.dart';
import 'notes_screen.dart';
import '../db_helper.dart';

//1. Stateful widget
class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});
  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}
//2. Extension with list of maps
class _ArchiveScreenState extends State<ArchiveScreen> {
  List<Map<String, dynamic>> _values = [];
//3. Screen state initialization with the usage of table values loading
  @override
  void initState() {
    super.initState();
    _loadValues();
  }
//4. A method to load all values from the db table
  Future<void> _loadValues() async {
    List<Map<String, dynamic>> values = await DatabaseHelper().getArchivedNotes();
    setState(() {
      _values = values;
    });
  }

//5. A method to delete a single value from the db archive table
  void _deleteNote(int id) {
    DatabaseHelper().deleteFromArchive(id);
    _loadValues();
  }
//6. Helper method to navigate to the detail screen
  void _navigateToDetailScreen(int id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ArchiveDetailScreen(recordId: id)),
    );
  }
  //7. Creation time formating
  String formattedDateTime(DateTime dateTime) {
    return '${dateTime.day}-${dateTime.month}-${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }
//8. Alert dialog with permanent delete confirmation
  void _confirmDeleteDialog(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete From Archive'),
          content: Text('Are you sure you want to delete this note forever?'),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ArchiveScreen()),
                );// Close the dialog
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
//9. Build with Scaffold and AppBar
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CatalogScreen()),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Archived notes'),
      ),
      //10. ListView builder with gesture detector
      body: ListView.builder(
        itemCount: _values.length,
        itemBuilder: (context, index) {
          DateTime updatedAt = DateTime.parse(_values[index]['updated_at']);
          return GestureDetector(
            onTap: () {
              _navigateToDetailScreen(_values[index]['id']);
            },
            //11. Card with IconButton
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
                            _confirmDeleteDialog(_values[index]['id']);
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
    );
  }
}
