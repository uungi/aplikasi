import 'package:flutter/foundation.dart';
import '../models/resume_draft.dart';
import '../models/user_input.dart';
import '../services/database_helper.dart';

class DraftsProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<ResumeDraft> _drafts = [];
  bool _isLoading = false;
  String? _error;
  
  List<ResumeDraft> get drafts => _drafts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  DraftsProvider() {
    loadDrafts();
  }
  
  Future<void> loadDrafts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _drafts = await _dbHelper.getAllDrafts();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<ResumeDraft?> getDraft(String id) async {
    try {
      return await _dbHelper.getDraft(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
  
  Future<String> saveDraft({
    required String name,
    required UserInput input,
    String? resumeContent,
    String? coverLetterContent,
  }) async {
    try {
      final draft = ResumeDraft(
        name: name,
        input: input,
        resumeContent: resumeContent,
        coverLetterContent: coverLetterContent,
      );
      
      final id = await _dbHelper.insertDraft(draft);
      await loadDrafts(); // Reload drafts
      return id;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> updateDraft(ResumeDraft draft) async {
    try {
      await _dbHelper.updateDraft(draft);
      await loadDrafts(); // Reload drafts
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> deleteDraft(String id) async {
    try {
      await _dbHelper.deleteDraft(id);
      await loadDrafts(); // Reload drafts
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  Future<void> deleteAllDrafts() async {
    try {
      await _dbHelper.deleteAllDrafts();
      await loadDrafts(); // Reload drafts
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
