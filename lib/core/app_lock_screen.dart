
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:lowkey/core/app_lock_service.dart';

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  final TextEditingController _passcodeController = TextEditingController();
  String _errorMessage = '';

  Future<void> _unlockApp() async {
    final appLockService = context.read<AppLockService>();
    final isPasscodeSet = await appLockService.isPasscodeSet();

    if (!isPasscodeSet) {
      // If no passcode is set, allow immediate unlock (e.g., first time setup)
      await appLockService.setPasscode(_passcodeController.text); // Set the entered passcode as the new one
      appLockService.unlock();
      return;
    }

    if (await appLockService.verifyPasscode(_passcodeController.text)) {
      appLockService.unlock();
    } else {
      setState(() {
        _errorMessage = 'Incorrect passcode';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'App Locked',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32.0),
              CupertinoTextField(
                controller: _passcodeController,
                placeholder: 'Enter Passcode',
                obscureText: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                onSubmitted: (_) => _unlockApp(),
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: CupertinoColors.destructiveRed),
                  ),
                ),
              const SizedBox(height: 16.0),
              CupertinoButton.filled(
                onPressed: _unlockApp,
                child: const Text('Unlock'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
