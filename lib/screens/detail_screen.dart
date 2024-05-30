import 'package:flutter/material.dart';
import '../main.dart';
import 'catalog_detail_screen.dart';
import 'edit_screen.dart';
import 'package:notebook/fb_helper.dart';

class DetailScreen extends StatefulWidget {
  final String recordId;
  final String? catalogName;
  const DetailScreen(this.recordId, this.catalogName);
  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  void initState() {
    super.initState();
  }

  void _editRecord(BuildContext context, String recordId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditScreen(recordId, widget.catalogName!)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('detail')),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CatalogDetailScreen(widget.catalogName!)),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _editRecord(context, widget.recordId);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<Map<String, dynamic>>(
          future: FirebaseHelper().fetchValueById(widget.recordId) as Future<Map<String, dynamic>>,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.data == null) {
              return Center(child: Text('Document not found'));
            } else {
              Map<String, dynamic>? data = snapshot.data;
              return Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${data!['value']}',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  ],
                ),
              );
            }
          },
        ),

      ),
    );
  }
}
