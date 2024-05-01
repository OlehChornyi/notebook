import 'package:flutter/material.dart';
import '../main.dart';
import 'catalog_detail_screen.dart';
import 'package:notebook/fb_helper.dart';
import '../custom_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db_helper.dart';

//1.Stateful widget
class CreateNoteScreen extends StatefulWidget {
  final String catalogName;

  CreateNoteScreen(this.catalogName);
  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}
//2.Extension with controller and db values
class _CreateNoteScreenState extends State<CreateNoteScreen> {
  final myController = TextEditingController();
  bool _isDisabled = false;
//3.Build with Scaffold and AppBar
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('writeSomething')),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload_outlined),
            onPressed: _isDisabled ? null : () async {
              setState(() {
                _isDisabled = true;
              });
              String value = myController.text;
              await FirebaseHelper().insertValue(value, widget.catalogName);
              // await DatabaseHelper().insertValue(value, widget.catalogName);
              myController.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.translate('beenCreated')),
                  ));
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CatalogDetailScreen(widget.catalogName)),
              );
            },
          ),
        ],
      ),
      body: _isDisabled ? Center(child: CircularProgressIndicator()) : SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              //4.Text field for the info input
              TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: AppLocalizations.of(context)!.translate('putNote'),
                ),
                controller: myController,
                maxLines: null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
