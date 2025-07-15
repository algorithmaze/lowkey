
import 'package:flutter/cupertino.dart';

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Text(
          'Typing...',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: CupertinoColors.systemGrey,
          ),
        ),
      ),
    );
  }
}
