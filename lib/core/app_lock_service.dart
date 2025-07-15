
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppLockService extends ChangeNotifier {
  final FlutterSecureStorage _secureStorage;
  Timer? _inactivityTimer;
  bool _isLocked = false;
  static const String _passcodeKey = 'app_lock_passcode';
  static const Duration _inactivityTimeout = Duration(minutes: 5); // Default to 5 minutes

  AppLockService(this._secureStorage);

  bool get isLocked => _isLocked;

  void startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(_inactivityTimeout, () {
      _isLocked = true;
      notifyListeners();
    });
  }

  void userActivityDetected() {
    if (_isLocked) return; // Don't reset timer if already locked
    startInactivityTimer();
  }

  Future<void> setPasscode(String passcode) async {
    await _secureStorage.write(key: _passcodeKey, value: passcode);
  }

  Future<bool> verifyPasscode(String passcode) async {
    final storedPasscode = await _secureStorage.read(key: _passcodeKey);
    return storedPasscode == passcode;
  }

  void unlock() {
    _isLocked = false;
    startInactivityTimer(); // Restart timer after unlocking
    notifyListeners();
  }

  Future<bool> isPasscodeSet() async {
    return await _secureStorage.read(key: _passcodeKey) != null;
  }

  Future<void> removePasscode() async {
    await _secureStorage.delete(key: _passcodeKey);
  }
}
