import 'package:flutter/cupertino.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF007AFF); // Apple Blue
  static const Color primaryGreen = Color(0xFF34C759); // Apple Green
  static const Color incomingMessageBackground = CupertinoColors.systemGrey5;
  static const Color outgoingMessageBackground = Color(0xFF007AFF); // Use primaryBlue
  static const Color incomingMessageText = CupertinoColors.black;
  static const Color outgoingMessageText = CupertinoColors.white;

  // Dark mode colors
  static const Color darkBackground = CupertinoColors.black;
  static const Color darkSurface = Color(0xFF1C1C1E);
  static const Color darkText = CupertinoColors.white;
}