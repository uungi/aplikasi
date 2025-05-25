import 'package:flutter/foundation.dart';
import '../models/offline_template.dart';
import '../services/database_helper.dart';

class OfflineTemplatesProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<OfflineTemplate> _templates = [];
  bool _isLoading = false;
  String? _error;
  
  List<OfflineTemplate> get templates => _templates;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  OfflineTemplatesProvider() {
    _initialize();
  }
  
  Future<void> _initialize() async {
    await _dbHelper.initializeDefaultOfflineTemplates();
    await loadTemplates();
  }
  
  Future<void> loadTemplates() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _templates = await _dbHelper.getAllOfflineTemplates();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<List<OfflineTemplate>> getTemplatesByType(String type) async {
    try {
      return await _dbHelper.getOfflineTemplatesByType(type);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }
  
  Future<OfflineTemplate?> getTemplate(String id) async {
    try {
      return await _dbHelper.getOfflineTemplate(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
  
  Future<String> saveTemplate(OfflineTemplate template) async {
    try {
      final id = await _dbHelper.insertOfflineTemplate(template);
      await loadTemplates();
      return id;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> updateTemplate(OfflineTemplate template) async {
    try {
      await _dbHelper.updateOfflineTemplate(template);
      await loadTemplates();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> deleteTemplate(String id) async {
    try {
      await _dbHelper.deleteOfflineTemplate(id);
      await loadTemplates();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
