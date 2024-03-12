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
