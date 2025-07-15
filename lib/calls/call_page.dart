
import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';
import 'package:lowkey/calls/call_service.dart';

class CallPage extends StatefulWidget {
  final String targetUserId;
  const CallPage({super.key, required this.targetUserId});

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  @override
  Widget build(BuildContext context) {
    final callService = context.read<CallService>();

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Call'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RTCVideoView(callService.remoteRenderer),
            ),
            SizedBox(
              height: 120,
              child: RTCVideoView(callService.localRenderer),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CupertinoButton.filled(
                  onPressed: () {
                    callService.startCall(widget.targetUserId);
                  },
                  child: const Text('Start Call'),
                ),
                CupertinoButton.filled(
                  onPressed: () {
                    callService.endCall();
                    Navigator.pop(context);
                  },
                  child: const Text('End Call'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
