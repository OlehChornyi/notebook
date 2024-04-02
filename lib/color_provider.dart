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

  List<String> get catalogNames => _catalogNames;
  String get selectedCatalog => _selectedCatalog;

  CatalogProvider() {
    loadCatalogNames();
  }

  // Method to set the selected catalog
  void setSelectedCatalog(String catalogName) {
    if (_catalogNames.contains(catalogName)) {
      _selectedCatalog = catalogName;
      notifyListeners();
    }
  }

  // Load catalog names from shared preferences
  // Future<void> loadCatalogNames() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   List<String>? storedCatalogNames = prefs.getStringList(_catalogNamesKey);
  //   if (storedCatalogNames != null) {
  //     _catalogNames = storedCatalogNames;
  //   }
  //   notifyListeners();
  // }
  Future<void> loadCatalogNames() async {
    CollectionReference notes = FirebaseFirestore.instance.collection('notes');
    String? uid = FirebaseAuth
        .instance.currentUser?.uid;
    try {
      QuerySnapshot snapshot = await notes.where('userId', isEqualTo: uid).get();

      // Use a Set to store unique catalog names
      Set<String> catalogNames = Set();

      snapshot.docs.forEach((doc) {
        String catalogName = doc['catalog_name'];
        if (catalogName != 'Archive') {
          catalogNames.add(catalogName);
        }
      });

      // Convert the Set to a List
      _catalogNames = catalogNames.toList();
      notifyListeners();
    } catch (error) {
      print("Failed to load catalog names: $error");
    }
  }
  // Save catalog names to shared preferences
  Future<void> saveCatalogNames() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(_catalogNamesKey, _catalogNames);
  }

  // Add a new catalog name
  void addCatalog(String name) {
    _catalogNames.add(name);
    saveCatalogNames();
    notifyListeners();
  }

  // Remove a catalog name
  void removeCatalog(String name) {
    _catalogNames.remove(name);
    saveCatalogNames();
    notifyListeners();
  }
  // Method to delete all values from catalogNames
  void clearCatalogNames() {
    _catalogNames.clear();
    notifyListeners();
  }
}