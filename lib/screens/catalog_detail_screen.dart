import 'package:flutter/material.dart';
import 'package:notebook/fb_helper.dart';
import 'catalog_screen.dart';
import 'notes_screen.dart';
import '../color_provider.dart';
import 'package:provider/provider.dart';
import 'package:notebook/screens/create_screen.dart';
import '../main.dart';
import 'detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'archive_screen.dart';
import '../db_helper.dart';

class CatalogDetailScreen extends StatefulWidget {
  final String catalogName;

  CatalogDetailScreen(this.catalogName);

  @override
  State<CatalogDetailScreen> createState() => _CatalogDetailScreenState();
}

class _CatalogDetailScreenState extends State<CatalogDetailScreen> {
  List<Map<String, dynamic>> _values = [];

  @override
  void initState() {
    super.initState();
    _loadValues();
  }

  Future<void> _loadValues() async {
    List<Map<String, dynamic>> values =
        // await DatabaseHelper().getNotesByCatalogName(widget.catalogName);
    await FirebaseHelper().fetchValuesByCatalog(widget.catalogName);
    setState(() {
      _values = values;
    });
  }

  //7. Time format
  String formattedDateTime(DateTime dateTime) {
    return '${dateTime.day}-${dateTime.month}-${dateTime.year} ${dateTime.hour+3}:${dateTime.minute}';
  }

  //6. Helper method to navigate to the detail screen
  void _navigateToDetailScreen(String id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailScreen(id, widget.catalogName)),
    );
  }

  //8. Alert dialog with delete confirmation
  void _confirmDeleteDialog(String id) {
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
                // _deleteNoteAndArchive(id);
                FirebaseHelper().updateCatalogName(id, 'Archive');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CatalogDetailScreen(widget.catalogName),
                  ),
                ); // Close the dialog
                setState(() {});
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  //5. A method to delete from notes screen and archive note
  void _deleteNoteAndArchive(int id) {
    DatabaseHelper().deleteNoteAndArchive(id);
    // Refresh the UI or update the state to reflect the changes
    setState(() {});
  }

  void _confirmMoveDialog(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // final catalogNames = Provider.of<CatalogProvider>(context).catalogNames;
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
                  SizedBox(height: 8),
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
                    // DatabaseHelper().updateCatalogName(id, selectedCatalog);
                    FirebaseHelper().updateCatalogName(id, selectedCatalog);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.catalogName),
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
            //13. Card with IconButton (delete)
            // key: Key('$index'), // Add a unique key to each item for reordering
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
                                _confirmMoveDialog(_values[index]['id']);
                              },
                              icon: const Icon(Icons.drive_file_move),
                            ),
                            IconButton(
                              onPressed: () {
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
        // onReorder: (int oldIndex, int newIndex) {
        //   setState(() {
        //     if (newIndex > oldIndex) {
        //       newIndex -= 1;
        //     }
        //     final Map<String, dynamic> item = _values.removeAt(oldIndex);
        //     _values.insert(newIndex, item);
        //   });
        // },
      ),
      //14. Floating action button with route to the CreateNoteScreen
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CreateNoteScreen(widget.catalogName)),
          );
        },
        tooltip: 'Create note',
        child: const Icon(Icons.add),
      ),
    );
  }
}
