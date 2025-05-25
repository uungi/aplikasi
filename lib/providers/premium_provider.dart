import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumProvider extends ChangeNotifier {
  bool _isPremium = false;
  
  PremiumProvider(bool initialValue) {
    _isPremium = initialValue;
  }
  
  bool get isPremium => _isPremium;

  Future<void> setPremium(bool val) async {
    _isPremium = val;
    
    // Persist premium status
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', val);
    
    notifyListeners();
  }
}
