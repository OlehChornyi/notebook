import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notebook/fb_helper.dart';
import 'package:provider/provider.dart';
import 'package:notebook/screens/registration_and_login/welcome_screen.dart';
import '../custom_provider.dart';
import '../main.dart';
import 'archive_screen.dart';
import 'catalog_detail_screen.dart';
import 'create_screen.dart';

class CatalogScreen extends StatefulWidget {
  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> _archiveValues = [];
  bool _isLoading = true;
  int _notesCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCatalogs().then((_) => _isLoading = false);
    _loadArchiveValues();
  }

  Future<void> _loadCatalogs() async{
    await Provider.of<CatalogProvider>(context, listen: false).loadCatalogNames();
    setState(() {});
  }

  Future<void> _countNotes(catalogName) async {
    int count = await FirebaseHelper().countNotesByCatalog(catalogName);
    setState(() {
      _notesCount = count;
    });
  }

  Future<void> _loadArchiveValues() async {
    List<Map<String, dynamic>> values =
    await FirebaseHelper().fetchValuesByCatalog('Archive');

    setState(() {
      _archiveValues = values;
    });
  }

  void _navigateToArchive(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArchiveScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ColorProvider colorProvider = Provider.of<ColorProvider>(context);
    bool isEng = Provider.of<LanguageProvider>(context).appLocal == Locale("en");

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(AppLocalizations.of(context)!.translate('catalogTitle')),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CreateNoteScreen('Notes')),
              );
              if (Provider.of<CatalogProvider>(context, listen: false).catalogNames.contains('Notes')){
                return;
              } else {
                Provider.of<CatalogProvider>(context, listen: false)
                    .addCatalog('Notes');
                Provider.of<CatalogProvider>(context, listen: false)
                    .saveCatalogNames();
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: colorProvider.selectedColor,
              ),
              child: Text(
                AppLocalizations.of(context)!.translate('menu'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.translate('theme')),
              trailing: DropdownButton<Color>(
                value: colorProvider.selectedColor,
                onChanged: (color) {
                  setState(() {
                    colorProvider.selectedColor = color!;
                  });
                },
                items: [
                  DropdownMenuItem(
                    value: Color(0xff4caf50),
                    child: isEng ? Text('Green') : Text('Зелений'),
                  ),
                  DropdownMenuItem(
                    value: Color(0xfff44336),
                    child: isEng ? Text('Red') : Text('Червоний'),
                  ),
                  DropdownMenuItem(
                    value: Color(0xff2196f3),
                    child: isEng ? Text('Blue') : Text('Синій'),
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.translate('language')),
              trailing: DropdownButton<String>(
                value: isEng ? 'English' : 'Українська',
                onChanged: (String? newValue) {
                  setState(() {
                    if (newValue == 'English') {
                      Provider.of<LanguageProvider>(context, listen: false).changeLanguage(Locale("en"));
                    } else if (newValue == 'Українська') {
                      Provider.of<LanguageProvider>(context, listen: false).changeLanguage(Locale("uk"));
                    }
                  });
                },
                items: <String>['English', 'Українська'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            Visibility(
              visible: _archiveValues.isEmpty ? false : true,
              child: ListTile(
                title: Text(AppLocalizations.of(context)!.translate('archive')),
                onTap: () {
                  _navigateToArchive(context); // Close the drawer
                },
              ),
            ),
            Divider(),
            ListTile(
              title: Text(_auth.currentUser!.email.toString(), style: TextStyle(color: Colors.black54)),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.translate('signOut')),
              onTap: () {
                _auth.signOut();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WelcomeScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: _isLoading ? Center(child: CircularProgressIndicator()) : RefreshIndicator(
        onRefresh: () async{
          await Provider.of<CatalogProvider>(context, listen: false).loadCatalogNames();
          setState(() {});
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    itemCount:
                        Provider.of<CatalogProvider>(context).catalogNames.length,
                    itemBuilder: (context, index) {
                      final catalogNames =
                          Provider.of<CatalogProvider>(context).catalogNames;
                      return Dismissible(
                        key: Key(catalogNames[index]),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          FirebaseHelper()
                              .deleteNotesWithCatalogName(catalogNames[index]);
                          Provider.of<CatalogProvider>(context, listen: false)
                              .removeCatalog(catalogNames[index]);
                        },
                        background: Container(
                          alignment: AlignmentDirectional.centerEnd,
                          color: Colors.red,
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        child: ListTile(
                          tileColor: Theme.of(context).colorScheme.surfaceVariant,
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(catalogNames[index]),
                              FutureBuilder<int>(
                                initialData: 0,
                                future: FirebaseHelper()
                                    .countNotesByCatalog(catalogNames[index]),
                                builder: (context, snapshot) {
                                  int? notesCount = snapshot.data;
                                  return Text('$notesCount '+AppLocalizations.of(context)!.translate('notes'));
                                },
                              )
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CatalogDetailScreen(catalogNames[index]),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) {
                          newIndex -= 1;
                        }
                        final catalogProvider =
                            Provider.of<CatalogProvider>(context, listen: false);
                        final String item =
                            catalogProvider.catalogNames.removeAt(oldIndex);
                        catalogProvider.catalogNames.insert(newIndex, item);
                        catalogProvider.saveCatalogNames();
                      });
                    },
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      // Open dialog to add a new catalog
                      String newCatalogName = await showDialog(
                        context: context,
                        builder: (context) => AddCatalogDialog(),
                      );
                      if (newCatalogName != null && newCatalogName.isNotEmpty) {
                        setState(() {
                          Provider.of<CatalogProvider>(context, listen: false)
                              .addCatalog(newCatalogName);
                          Provider.of<CatalogProvider>(context, listen: false)
                              .saveCatalogNames(); // Save catalog names to shared preferences
                          // Save catalog names to shared preferences
                        });
                      }
                    },
                    child: Text(AppLocalizations.of(context)!.translate('createCatalog')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AddCatalogDialog extends StatefulWidget {
  @override
  _AddCatalogDialogState createState() => _AddCatalogDialogState();
}

class _AddCatalogDialogState extends State<AddCatalogDialog> {
  TextEditingController _catalogNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.translate('addCatalog')),
      content: TextField(
        controller: _catalogNameController,
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.translate('catalogName'),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close dialog
          },
          child: Text(AppLocalizations.of(context)!.translate('cancel')),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(_catalogNameController.text.trim());
          },
          child: Text(AppLocalizations.of(context)!.translate('add')),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _catalogNameController.dispose();
    super.dispose();
  }
}
