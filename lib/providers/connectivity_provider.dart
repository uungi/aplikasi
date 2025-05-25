import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityProvider extends ChangeNotifier {
  bool _isOfflineMode = false;
  bool _hasInternetConnection = true;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  ConnectivityProvider() {
    _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  bool get isOfflineMode => _isOfflineMode;
  bool get hasInternetConnection => _hasInternetConnection;
  bool get isActuallyOffline => _isOfflineMode || !_hasInternetConnection;

  // Inisialisasi status koneksi
  Future<void> _initConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      debugPrint('Tidak dapat memeriksa konektivitas: $e');
      _hasInternetConnection = false;
      notifyListeners();
    }
  }

  // Update status koneksi berdasarkan perubahan
  void _updateConnectionStatus(ConnectivityResult result) {
    _hasInternetConnection = result != ConnectivityResult.none;
    notifyListeners();
  }

  // Toggle mode offline
  void toggleOfflineMode() {
    _isOfflineMode = !_isOfflineMode;
    notifyListeners();
  }

  // Set mode offline
  void setOfflineMode(bool value) {
    _isOfflineMode = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
}
