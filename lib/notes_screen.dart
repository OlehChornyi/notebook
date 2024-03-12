import 'package:flutter/material.dart';
import 'create_screen.dart';
import 'detail_screen.dart';
import 'db_helper.dart';
import 'package:provider/provider.dart';
import 'color_provider.dart';
import 'archive_screen.dart';

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
  //5. A method to delete from notes screen and archive note
  void _deleteNoteAndArchive(int id) {
    DatabaseHelper().deleteNoteAndArchive(id);
    // Refresh the UI or update the state to reflect the changes
    setState(() {});
  }
//6. Helper method to navigate to the detail screen
  void _navigateToDetailScreen(int id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailScreen(recordId: id)),
    );
  }
//7. Time formating
  String formattedDateTime(DateTime dateTime) {
    return '${dateTime.day}-${dateTime.month}-${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }
//8. Alert dialog with delete confirmation
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
                _deleteNoteAndArchive(id);
                // _deleteNote(id);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotesScreen()),
                ); // Close the dialog
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
//9. A route to ArchiveScreen
  void _navigateToArchive(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArchiveScreen(),
      ),
    );
  }
//10. Build with Scaffold and AppBar
  @override
  Widget build(BuildContext context) {
    ColorProvider colorProvider = Provider.of<ColorProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('All notes'),
      ),
      //11. Drawer with themes and archive
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: colorProvider.selectedColor,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Theme Color'),
              trailing: DropdownButton<Color>(
                value: colorProvider.selectedColor,
                onChanged: (color) {
                  setState(() {
                    colorProvider.selectedColor = color!;
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotesScreen()),
                  );// Close the drawer
                },
                items: [
                  DropdownMenuItem(
                    value: Color(0xff4caf50),
                    child: Text('Green'),
                  ),
                  DropdownMenuItem(
                    value: Color(0xfff44336),
                    child: Text('Red'),
                  ),
                  DropdownMenuItem(
                    value: Color(0xff2196f3),
                    child: Text('Blue'),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text('Archive'),
              onTap: () {
                _navigateToArchive(context); // Close the drawer
              },
            ),
          ],
        ),
      ),
      //12. ListView builder with gesture detector
      body: ListView.builder(
        itemCount: _values.length,
        itemBuilder: (context, index) {
          DateTime updatedAt = DateTime.parse(_values[index]['updated_at']);
          // Note note = _notes[index];
          return GestureDetector(
            onTap: () {
              _navigateToDetailScreen(_values[index]['id']);
            },
            //13. Card with IconButton (delete)
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
                            // _deleteNote(context, note.id);
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
      //14. Floating action button with route to the CreateNoteScreen
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
