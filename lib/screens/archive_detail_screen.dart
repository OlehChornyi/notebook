import 'package:flutter/material.dart';
import '../fb_helper.dart';
import '../main.dart';
import 'archive_screen.dart';

class ArchiveDetailScreen extends StatefulWidget {
  final String recordId;
  const ArchiveDetailScreen({super.key, required this.recordId});
  @override
  _ArchiveDetailScreenState createState() => _ArchiveDetailScreenState();
}

class _ArchiveDetailScreenState extends State<ArchiveDetailScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('archiveDetail')),
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
      body: SingleChildScrollView(
        child: FutureBuilder<Map<String, dynamic>>(
          future: FirebaseHelper().fetchValueById(widget.recordId) as Future<Map<String, dynamic>>,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('No data found for the given ID.'));
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
