import 'package:flutter/material.dart';
import 'package:notebook/screens/archive_detail_screen.dart';
import '../main.dart';
import 'catalog_screen.dart';
import 'package:notebook/fb_helper.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});
  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  List<Map<String, dynamic>> _values = [];

  @override
  void initState() {
    super.initState();
    _loadValues();
  }

  Future<void> _loadValues() async {
    List<Map<String, dynamic>> values =
        await FirebaseHelper().fetchValuesByCatalog('Archive');

    setState(() {
      _values = values;
    });
  }

  void _navigateToDetailScreen(String id) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ArchiveDetailScreen(recordId: id)),
    );
  }

  String formattedDateTime(DateTime dateTime) {
    return '${dateTime.day}-${dateTime.month}-${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }

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
    FirebaseHelper().deleteValue(id);
    _loadValues();
  }

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
