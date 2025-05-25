import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/custom_template.dart';
import '../services/database_helper.dart';

class TemplatesProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<CustomTemplate> _templates = [];
  bool _isLoading = false;
  String? _error;
  
  List<CustomTemplate> get templates => _templates;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  TemplatesProvider() {
    loadTemplates();
  }
  
  Future<void> loadTemplates() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _templates = await _dbHelper.getAllTemplates();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<CustomTemplate?> getTemplate(String id) async {
    try {
      return await _dbHelper.getTemplate(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
  
  Future<String> saveTemplate(CustomTemplate template) async {
    try {
      final id = await _dbHelper.insertTemplate(template);
      await loadTemplates(); // Reload templates
      return id;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> updateTemplate(CustomTemplate template) async {
    try {
      await _dbHelper.updateTemplate(template);
      await loadTemplates(); // Reload templates
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> deleteTemplate(String id) async {
    try {
      await _dbHelper.deleteTemplate(id);
      await loadTemplates(); // Reload templates
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> deleteAllTemplates() async {
    try {
      await _dbHelper.deleteAllTemplates();
      await loadTemplates(); // Reload templates
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Create a template from a predefined type
  Future<String> createTemplateFromType(
    String type, {
    required String name,
    required String description,
    required Color primaryColor,
    required Color accentColor,
  }) async {
    final template = CustomTemplate.fromType(
      type,
      name: name,
      description: description,
      primaryColor: primaryColor,
      accentColor: accentColor,
    );
    
    return saveTemplate(template);
  }
}
