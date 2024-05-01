import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseHelper {
  //1. Insert new note into Firebase
  Future<void> insertValue(String value, String catalogName) async {
    CollectionReference notes = FirebaseFirestore.instance.collection('notes');
    String uid = FirebaseAuth
        .instance.currentUser!.uid;

    return notes
        .add({
          'value': value,
          'updated_at': DateTime.now().toUtc().toString(),
          'catalog_name': catalogName,
          'userId': uid,
        })
        .then((value) => print("Value added successfully!"))
        .catchError((error) => print("Failed to add value: $error"));
  }

//2. Get all notes from Firebase
  Future<List<Map<String, dynamic>>> fetchValues() async {
    CollectionReference notes = FirebaseFirestore.instance.collection('notes');

    try {
      QuerySnapshot snapshot = await notes.get();

      List<Map<String, dynamic>> dataList = [];

      snapshot.docs.forEach((doc) {
        Map<String, dynamic> data = {
          'id': doc.id,
          'value': doc['value'],
          'updated_at': doc['updated_at'],
          'catalog_name': doc['catalog_name'],
        };
        dataList.add(data);
      });

      return dataList;
    } catch (error) {
      print("Failed to fetch values: $error");
      return [];
    }
  }

  //2.1. Get note by id
  Future<Map<String, dynamic>> fetchValueById(String id) async {
    late Map<String, dynamic> data;
    try {
      DocumentSnapshot snapshot =
          await FirebaseFirestore.instance.collection('notes').doc(id).get();

      if (snapshot.exists) {
        data = snapshot.data()! as Map<String, dynamic>;
      } else {
        throw Exception('Document not found');
      }
    } catch (error) {
      print("Failed to fetch value: $error");
      throw Exception('Failed to fetch value');
    }
    return data;
  }

  //2.2. Get notes by catalog name
  Future<List<Map<String, dynamic>>> fetchValuesByCatalog(
      String catalogName) async {
    CollectionReference notes = FirebaseFirestore.instance.collection('notes');
    String uid = FirebaseAuth
        .instance.currentUser!.uid;

    try {
      QuerySnapshot snapshot = await notes
          .where('catalog_name', isEqualTo: catalogName)
          .where('userId', isEqualTo: uid)
          .get();

      List<Map<String, dynamic>> dataList = [];

      snapshot.docs.forEach((doc) {
        Map<String, dynamic> data = {
          'id': doc.id,
          'value': doc['value'],
          'updated_at': doc['updated_at'],
          'catalog_name': doc['catalog_name'],
        };
        dataList.add(data);
      });

      return dataList;
    } catch (error) {
      print("Failed to fetch values: $error");
      return [];
    }
  }

  //2.3. Get number of notes for catalog
  Future<int> countNotesByCatalog(String catalogName) async {
    CollectionReference notes = FirebaseFirestore.instance.collection('notes');
    String uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      QuerySnapshot snapshot = await notes
          .where('catalog_name', isEqualTo: catalogName)
          .where('userId', isEqualTo: uid)
          .get();

      // Return the number of documents in the snapshot
      return snapshot.size;
    } catch (error) {
      print("Failed to count notes: $error");
      return 0;
    }
  }

//3. Update specific value
  Future<void> updateValue(String noteId, String newValue) {
    CollectionReference notes = FirebaseFirestore.instance.collection('notes');

    return notes
        .doc(noteId)
        .update({
          'value': newValue,
          'updated_at': DateTime.now().toUtc().toString(),
        })
        .then((value) => print("Value updated successfully!"))
        .catchError((error) => print("Failed to update value: $error"));
  }

  //3.1. Update catalog name
  Future<void> updateCatalogName(String noteId, String newCatalogName) {
    CollectionReference notes = FirebaseFirestore.instance.collection('notes');

    return notes
        .doc(noteId)
        .update({'catalog_name': newCatalogName})
        .then((value) => print("Catalog name updated successfully!"))
        .catchError((error) => print("Failed to update catalog name: $error"));
  }

//4. Deleting a single value
  Future<void> deleteValue(String noteId) {
    CollectionReference notes = FirebaseFirestore.instance.collection('notes');

    return notes
        .doc(noteId)
        .delete()
        .then((value) => print("Value deleted successfully!"))
        .catchError((error) => print("Failed to delete value: $error"));
  }

  //4.1. Deleting value by catalog
  Future<void> deleteNotesWithCatalogName(String catalogName) async {
    CollectionReference notes = FirebaseFirestore.instance.collection('notes');
    String uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      QuerySnapshot querySnapshot = await notes
          .where('catalog_name', isEqualTo: catalogName)
          .where('userId', isEqualTo: uid)
          .get();

      for (DocumentSnapshot doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (error) {
      print("Error deleting notes: $error");
    }
  }
}
