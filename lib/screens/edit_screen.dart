import 'package:flutter/material.dart';
import '../db_helper.dart';
import 'detail_screen.dart';

//1.Stateful widget with a parameter and constructor
class EditScreen extends StatefulWidget {
  final int recordId;
  final String catalogName;
  const EditScreen(this.recordId, this.catalogName);
  @override
  _EditScreenState createState() => _EditScreenState();
}
//2. Extension with future parameter and controller
class _EditScreenState extends State<EditScreen> {
  TextEditingController _textEditingController = TextEditingController();
  Future<String?>? _detail;
//3. Screen state initialization with a record from the table to edit
  @override
  void initState() {
    super.initState();
    _detail = DatabaseHelper().getDetailById(widget.recordId);
  }
//4. A method to update record and go to the details screen
  void _updateRecord(BuildContext context, int recordId) {
    String newValue = _textEditingController.text;
    DatabaseHelper().updateRecord(recordId, newValue);
     // Return to the previous screen after updating
  }
  //4.1. Helper method to navigate to the detail screen
  void _navigateToDetailScreen(int id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailScreen(id, widget.catalogName)),
    );
  }
//5. Build with Scaffold and AppBar
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit my note'),
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
      //6. Body with builder and error handler
      body: FutureBuilder<String?>(
        future: _detail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Text('Error loading detail: ${snapshot.error}');
            }
//7. Value from the table that is added to the text field
            String currentValue = snapshot.data ?? '';
            _textEditingController.text = currentValue;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text('Editing Record ID ${widget.recordId}'),
                    const SizedBox(height: 16.0),
                    //8. Text field with controller
                    TextField(
                      maxLines: null,
                      controller: _textEditingController,
                      // decoration: const InputDecoration(labelText: 'Enter new value'),
                    ),
                  ],
                ),
              ),
            );
            //9. In case the value from the table is still loading
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