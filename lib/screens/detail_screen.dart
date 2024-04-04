import 'package:flutter/material.dart';
import 'catalog_detail_screen.dart';
import '../db_helper.dart';
import 'edit_screen.dart';
import 'package:notebook/fb_helper.dart';

//1.Stateful widget with parameter and constructor
class DetailScreen extends StatefulWidget {
  final String recordId;
  final String? catalogName;
  const DetailScreen(this.recordId, this.catalogName);
  @override
  _DetailScreenState createState() => _DetailScreenState();
}
//2.Extension with future parameter
class _DetailScreenState extends State<DetailScreen> {
  // late Future<String?> _detailFuture;
//3.Screen state initialization with specific value from the table
  @override
  void initState() {
    super.initState();
    // _detailFuture = DatabaseHelper().getDetailById(widget.recordId);
  }
  //4.A method that returns a route to the EditScreen
  void _editRecord(BuildContext context, String recordId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditScreen(recordId, widget.catalogName!)),
    );
  }
//5.Build with Scaffold, AppBar and edit button
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Note's detail"),
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
      //6.Body with builder that returns a specific value from the table
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
