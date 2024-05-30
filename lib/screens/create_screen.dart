import 'package:flutter/material.dart';
import '../main.dart';
import 'catalog_detail_screen.dart';
import 'package:notebook/fb_helper.dart';

class CreateNoteScreen extends StatefulWidget {
  final String catalogName;

  CreateNoteScreen(this.catalogName);
  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  final myController = TextEditingController();
  bool _isDisabled = false;

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
