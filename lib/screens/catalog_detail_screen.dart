import 'package:flutter/material.dart';
import 'package:notebook/fb_helper.dart';
import '../main.dart';
import 'catalog_screen.dart';
import '../custom_provider.dart';
import 'package:provider/provider.dart';
import 'package:notebook/screens/create_screen.dart';
import 'detail_screen.dart';

class CatalogDetailScreen extends StatefulWidget {
  final String catalogName;

  CatalogDetailScreen(this.catalogName);

  @override
  State<CatalogDetailScreen> createState() => _CatalogDetailScreenState();
}

class _CatalogDetailScreenState extends State<CatalogDetailScreen> {
  List<Map<String, dynamic>> _values = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadValues().then((_) => _isLoading = false);
  }

  Future<void> _loadValues() async {
    List<Map<String, dynamic>> values =
    await FirebaseHelper().fetchValuesByCatalog(widget.catalogName);
    setState(() {
      _values = values;
    });
  }

  String formattedDateTime(DateTime dateTime) {
    return '${dateTime.day}-${dateTime.month}-${dateTime.year} ${dateTime.hour+3}:${dateTime.minute}';
  }

  void _navigateToDetailScreen(String id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailScreen(id, widget.catalogName)),
    );
  }

  void _confirmMoveDialog(String id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<CatalogProvider>(
          builder: (context, catalogProvider, _) {
            String selectedCatalog = catalogProvider.catalogNames.isEmpty
                ? "You have no catalogs"
                : catalogProvider.catalogNames[0];

            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.translate('confirmMove')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.translate('whichCatalog')),
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
                  child: Text(AppLocalizations.of(context)!.translate('cancel')),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Move to catalog here
                    String selectedCatalog = catalogProvider.selectedCatalog;
                    FirebaseHelper().updateCatalogName(id, selectedCatalog);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CatalogDetailScreen(selectedCatalog),
                      ),
                    );
                  },
                  child: Text(AppLocalizations.of(context)!.translate('move')),
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
      body: _isLoading ? Center(child: CircularProgressIndicator()) : RefreshIndicator(
        onRefresh: () async {
          List<Map<String, dynamic>> values =
              await FirebaseHelper().fetchValuesByCatalog(widget.catalogName);
          setState(() {
            _values = values;
          });
        },
        child: ListView.builder(
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
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text(AppLocalizations.of(context)!.translate('confirmDelete')),
                                        content: Text(AppLocalizations.of(context)!.translate('youSure')),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(); // Close the dialog
                                            },
                                            child: Text(AppLocalizations.of(context)!.translate('cancel')),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              FirebaseHelper().updateCatalogName(_values[index]['id'], 'Archive');
                                              setState(() {
                                                _values.removeAt(index);
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            child: Text(AppLocalizations.of(context)!.translate('delete')),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(Icons.delete),
                              ),
                            ],
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
      ),
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
