import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _appLocale = const Locale('en');
  String _contentLanguage = 'en'; // Language for generated content
  
  LanguageProvider() {
    _loadSavedLanguages();
  }
  
  Locale get appLocale => _appLocale;
  String get contentLanguage => _contentLanguage;
  
  Future<void> _loadSavedLanguages() async {
    final prefs = await SharedPreferences.getInstance();
    
    final savedAppLocale = prefs.getString('app_locale');
    if (savedAppLocale != null) {
      _appLocale = Locale(savedAppLocale);
    }
    
    final savedContentLanguage = prefs.getString('content_language');
    if (savedContentLanguage != null) {
      _contentLanguage = savedContentLanguage;
    }
    
    notifyListeners();
  }
  
  Future<void> setAppLocale(Locale locale) async {
    if (_appLocale == locale) return;
    
    _appLocale = locale;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_locale', locale.languageCode);
    
    notifyListeners();
  }
  
  Future<void> setContentLanguage(String languageCode) async {
    if (_contentLanguage == languageCode) return;
    
    _contentLanguage = languageCode;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('content_language', languageCode);
    
    notifyListeners();
  }
  
  // Get language name from language code
  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en': return 'English';
      case 'id': return 'Bahasa Indonesia';
      case 'es': return 'Español';
      case 'fr': return 'Français';
      case 'de': return 'Deutsch';
      case 'zh': return '中文';
      case 'ja': return '日本語';
      case 'ko': return '한국어';
      default: return 'English';
    }
  }
  
  // Get all supported app languages
  List<Locale> get supportedLocales => const [
    Locale('en'), // English
    Locale('id'), // Indonesian
    Locale('es'), // Spanish
  ];
  
  // Get all supported content languages
  List<String> get supportedContentLanguages => const [
    'en', // English
    'id', // Indonesian
    'es', // Spanish
    'fr', // French
    'de', // German
    'zh', // Chinese
    'ja', // Japanese
    'ko', // Korean
  ];
}
