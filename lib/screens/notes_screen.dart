import 'package:flutter/material.dart';
import 'package:notebook/main.dart';
import 'catalog_screen.dart';
import 'create_screen.dart';
import 'package:notebook/screens/detail_screen.dart';
import '../db_helper.dart';
import 'package:provider/provider.dart';
import '../color_provider.dart';
import 'catalog_detail_screen.dart';

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
//   Future<void> _loadValues() async {
//     List<Map<String, dynamic>> values = await DatabaseHelper().getValues();
//     setState(() {
//       _values = values;
//     });
//   }
  Future<void> _loadValues() async {
    List<Map<String, dynamic>> values = await DatabaseHelper().getNotesByCatalogName('General notes');
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
      MaterialPageRoute(builder: (context) => DetailScreen(id, 'General notes')),
    );
  }

//7. Time format
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

  void _confirmMoveDialog(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final catalogNames = Provider.of<CatalogProvider>(context).catalogNames;
        return Consumer<CatalogProvider>(
          builder: (context, catalogProvider, _) {
            String selectedCatalog = catalogProvider.catalogNames.isEmpty
                ? "You have no catalogs"
                : catalogProvider.catalogNames[0];

            return AlertDialog(
              title: Text('Confirm Move'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('To which catalog move this note?'),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: Provider.of<CatalogProvider>(context)
                        .catalogNames
                        .map((catalogName) {
                      bool isSelected = catalogName == catalogProvider.selectedCatalog;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: TextButton(
                          onPressed: () {
                            catalogProvider.setSelectedCatalog(catalogName);
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            alignment: Alignment.bottomLeft,
                            // backgroundColor: isSelected ? Colors.grey : null,
                          ),
                          child: Text(catalogName, style: TextStyle(
                            color: isSelected ? Colors.black : Colors.grey,
                          ),),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    // Move to catalog here
                    String selectedCatalog = catalogProvider.selectedCatalog;
                    DatabaseHelper().updateCatalogName(id, selectedCatalog);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CatalogDetailScreen(selectedCatalog),
                      ),
                    );
                  },
                  child: Text('Move'),
                ),
              ],
            );
          },
        );
      },
    );
  }

//10. Build with Scaffold and AppBar
  @override
  Widget build(BuildContext context) {
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
      //11. Drawer with themes and archive

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

                        // const SizedBox(width: 8.0),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                // _deleteNote(context, note.id);
                                _confirmMoveDialog(_values[index]['id']);
                              },
                              icon: const Icon(Icons.drive_file_move),
                            ),
                            IconButton(
                              onPressed: () {
                                // _deleteNote(context, note.id);
                                _confirmDeleteDialog(_values[index]['id']);
                              },
                              icon: const Icon(Icons.delete),
                            ),
                          ],
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
            MaterialPageRoute(builder: (context) => CreateNoteScreen('General notes')),
          );
        },
        tooltip: 'Create note',
        child: const Icon(Icons.add),
      ),
    );
  }
}
