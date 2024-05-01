import 'package:flutter/material.dart';
import 'package:notebook/screens/archive_detail_screen.dart';
import '../main.dart';
import 'catalog_screen.dart';
import '../db_helper.dart';
import 'package:notebook/fb_helper.dart';

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
    List<Map<String, dynamic>> values =
        await FirebaseHelper().fetchValuesByCatalog('Archive');

    setState(() {
      _values = values;
    });
  }

//6. Helper method to navigate to the detail screen
  void _navigateToDetailScreen(String id) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ArchiveDetailScreen(recordId: id)),
    );
  }

  //7. Creation time formating
  String formattedDateTime(DateTime dateTime) {
    return '${dateTime.day}-${dateTime.month}-${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }

//8. Alert dialog with permanent delete confirmation
  void _confirmDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.translate('deleteArchive')),
          content: Text(AppLocalizations.of(context)!.translate('deleteForever')),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(AppLocalizations.of(context)!.translate('cancel')),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteNote(id);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ArchiveScreen()),
                ); // Close the dialog
              },
              child: Text(AppLocalizations.of(context)!.translate('delete')),
            ),
          ],
        );
      },
    );
  }

  void _deleteNote(String id) {
    // DatabaseHelper().deleteFromArchive(id);
    FirebaseHelper().deleteValue(id);
    _loadValues();
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
        title: Text(AppLocalizations.of(context)!.translate('archivedNotes')),
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
