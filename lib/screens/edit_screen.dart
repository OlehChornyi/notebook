import 'package:flutter/material.dart';
import '../main.dart';
import 'detail_screen.dart';
import 'package:notebook/fb_helper.dart';

class EditScreen extends StatefulWidget {
  final String recordId;
  final String catalogName;
  const EditScreen(this.recordId, this.catalogName);
  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  TextEditingController _textEditingController = TextEditingController();
  late Future<Map<String, dynamic>> _detail;

  @override
  void initState() {
    super.initState();
    _detail = FirebaseHelper().fetchValueById(widget.recordId)
        as Future<Map<String, dynamic>>;
  }

  void _updateRecord(BuildContext context, String recordId) {
    String newValue = _textEditingController.text;
    FirebaseHelper().updateValue(recordId, newValue);
  }

  void _navigateToDetailScreen(String id) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => DetailScreen(id, widget.catalogName)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate('edit')),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              _updateRecord(context, widget.recordId);
              _navigateToDetailScreen(widget.recordId);
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _detail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Text('Error loading detail: ${snapshot.error}');
            }
            String currentValue = snapshot.data!['value'] ?? '';
            _textEditingController.text = currentValue;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16.0),
                    TextField(
                      maxLines: null,
                      controller: _textEditingController,
                    ),
                  ],
                ),
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
