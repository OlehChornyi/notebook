import 'package:flutter/material.dart';
import '../db_helper.dart';
import 'archive_screen.dart';

//1.Stateful widget with parameter and constructor
class ArchiveDetailScreen extends StatefulWidget {
  final int recordId;
  const ArchiveDetailScreen({super.key, required this.recordId});
  @override
  _ArchiveDetailScreenState createState() => _ArchiveDetailScreenState();
}

//2.Extension with future parameter
class _ArchiveDetailScreenState extends State<ArchiveDetailScreen> {
  late Future<String?> _detailFuture;
//3.Screen state initialization with specific value from the table
  @override
  void initState() {
    super.initState();
    _detailFuture = DatabaseHelper().getArchiveDetailById(widget.recordId);
  }
//4.Build with Scaffold, AppBar
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Archive detail"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ArchiveScreen()),
            );
          },
        ),
      ),
      //5.Body with builder that returns a specific value from the table
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
