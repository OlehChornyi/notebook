import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

//1. Color provider class with selectedColor parameter
class ColorProvider extends ChangeNotifier {
  Color _selectedColor = Colors.green;
  static const String _selectedColorKey = 'selectedColor';

  Color get selectedColor => _selectedColor;

  ColorProvider() {
    _loadSelectedColor();
  }
//2. Setting and saving of the selectedColor
  set selectedColor(Color color) {
    _selectedColor = color;
    _saveSelectedColor();
    notifyListeners();
  }
//3. Loading of the selectedColor with shared preferences and provider
  Future<void> _loadSelectedColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int colorValue = prefs.getInt(_selectedColorKey) ?? Colors.green.value;
    _selectedColor = Color(colorValue);
    notifyListeners();
  }
//4. Saving of the selected color with shared preferences
  Future<void> _saveSelectedColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(_selectedColorKey, _selectedColor.value);
  }
}

class CatalogProvider extends ChangeNotifier {
  List<String> _catalogNames = []; // Default catalog names
  static const String _catalogNamesKey = 'catalogNames';
  String _selectedCatalog = ''; // Selected catalog name
  CollectionReference _catalogs =
  FirebaseFirestore.instance.collection('catalogs');

  List<String> get catalogNames => _catalogNames;
  String get selectedCatalog => _selectedCatalog;

  CatalogProvider() {
    loadCatalogNames();
  }

  // Method to set the selected catalog (move note between catalogs)
  void setSelectedCatalog(String catalogName) {
    if (_catalogNames.contains(catalogName)) {
      _selectedCatalog = catalogName;
      notifyListeners();
    }
  }

  Future<void> loadCatalogNames() async {
    List<String> catalogNames = [];
    String uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      QuerySnapshot querySnapshot = await _catalogs
          .where('userId', isEqualTo: uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot docSnapshot = querySnapshot.docs.first;
        List<dynamic>? names = docSnapshot['names'];
        if (names != null) {
          catalogNames.addAll(names.map((name) => name.toString()));
        }
      } else {
        // Document does not exist for the given UID
        print('No catalog names found for the user with UID: $uid');
      }
    } catch (error) {
      print('Error loading catalog names: $error');
    }
    print(catalogNames);
    _catalogNames = catalogNames.toList();
    notifyListeners();
    // return catalogNames;
  }

  Future<void> saveCatalogNames() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    try {
      QuerySnapshot querySnapshot = await _catalogs
          .where('userId', isEqualTo: uid)
          .limit(1)
          .get();

      List<dynamic> catalogNamesArray = _catalogNames.toList();

      if (querySnapshot.docs.isEmpty) {
        // If no entry with the given UID exists, create a new one
        await _catalogs.add({'userId': uid, 'names': catalogNamesArray});
      } else {
        // If an entry with the given UID exists, update its names
        String docId = querySnapshot.docs.first.id;
        await _catalogs.doc(docId).update({'names': catalogNamesArray});
      }
    } catch (error) {
      print('Error saving catalog names: $error');
    }
  }

  void addCatalog(String name) {
    _catalogNames.add(name);
    saveCatalogNames();
    notifyListeners();
  }

  void removeCatalog(String name) {
    _catalogNames.remove(name);
    saveCatalogNames();
    notifyListeners();
  }

  void clearCatalogNames() {
    _catalogNames.clear();
    notifyListeners();
  }
}