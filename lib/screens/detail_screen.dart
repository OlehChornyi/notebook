import 'package:flutter/material.dart';
import 'catalog_detail_screen.dart';
import 'package:notebook/screens/notes_screen.dart';
import '../db_helper.dart';
import 'edit_screen.dart';

//1.Stateful widget with parameter and constructor
class DetailScreen extends StatefulWidget {
  final int recordId;
  final String? catalogName;
  const DetailScreen(this.recordId, this.catalogName);
  @override
  _DetailScreenState createState() => _DetailScreenState();
}
//2.Extension with future parameter
class _DetailScreenState extends State<DetailScreen> {
  late Future<String?> _detailFuture;
//3.Screen state initialization with specific value from the table
  @override
  void initState() {
    super.initState();
    _detailFuture = DatabaseHelper().getDetailById(widget.recordId);
  }
  //4.A method that returns a route to the EditScreen
  void _editRecord(BuildContext context, int recordId) {
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
        child: FutureBuilder<String?>(
          future: _detailFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('No data found for the given ID.'));
            } else {
              return Container(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    // 'Detail for Record ID ${widget.recordId}:\n${snapshot.data}',
                    '${snapshot.data}',
                  style: const TextStyle(fontSize: 20.0),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
