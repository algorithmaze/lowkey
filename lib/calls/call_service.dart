import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CallService {
  final SupabaseClient _supabaseClient;
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  RealtimeChannel? _callChannel;

  CallService(this._supabaseClient);

  Future<void> initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  RTCVideoRenderer get localRenderer => _localRenderer;
  RTCVideoRenderer get remoteRenderer => _remoteRenderer;

  Future<void> listenForCalls() async {
    final currentUserId = _supabaseClient.auth.currentUser?.id;
    if (currentUserId == null) return;

    _callChannel = _supabaseClient.channel('calls');

    _callChannel!.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'calls',
      callback: (payload) async {
        final data = payload.newRecord;
        final type = data['type'] as String;
        final senderId = data['sender_id'] as String;
        final receiverId = data['receiver_id'] as String;
        final callData = data['data'] as Map<String, dynamic>;

        if (receiverId == currentUserId) {
          switch (type) {
            case 'offer':
              await handleCallOffer(callData, senderId);
              break;
            case 'answer':
              await handleCallAnswer(callData);
              break;
            case 'iceCandidate':
              await handleIceCandidate(callData);
              break;
          }
        }
      },
    ).subscribe();
  }

  Future<void> startCall(String targetUserId) async {
    _peerConnection = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    });

    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      _supabaseClient.from('calls').insert({
        'sender_id': _supabaseClient.auth.currentUser!.id,
        'receiver_id': targetUserId,
        'type': 'iceCandidate',
        'data': candidate.toMap(),
      });
    };

    _peerConnection!.onAddStream = (MediaStream stream) {
      _remoteStream = stream;
      _remoteRenderer.srcObject = _remoteStream;
    };

    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': true,
    });
    _localRenderer.srcObject = _localStream;
    _peerConnection!.addStream(_localStream!);

    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    _supabaseClient.from('calls').insert({
      'sender_id': _supabaseClient.auth.currentUser!.id,
      'receiver_id': targetUserId,
      'type': 'offer',
      'data': offer.toMap(),
    });
  }

  Future<void> handleCallOffer(Map<String, dynamic> offerData, String senderId) async {
    _peerConnection = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    });

    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      _supabaseClient.from('calls').insert({
        'sender_id': _supabaseClient.auth.currentUser!.id,
        'receiver_id': senderId,
        'type': 'iceCandidate',
        'data': candidate.toMap(),
      });
    };

    _peerConnection!.onAddStream = (MediaStream stream) {
      _remoteStream = stream;
      _remoteRenderer.srcObject = _remoteStream;
    };

    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': true,
    });
    _localRenderer.srcObject = _localStream;
    _peerConnection!.addStream(_localStream!);

    await _peerConnection!.setRemoteDescription(RTCSessionDescription(
      offerData['sdp'],
      offerData['type'],
    ));

    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    _supabaseClient.from('calls').insert({
      'sender_id': _supabaseClient.auth.currentUser!.id,
      'receiver_id': senderId,
      'type': 'answer',
      'data': answer.toMap(),
    });
  }

  Future<void> handleCallAnswer(Map<String, dynamic> answerData) async {
    await _peerConnection!.setRemoteDescription(RTCSessionDescription(
      answerData['sdp'],
      answerData['type'],
    ));
  }

  Future<void> handleIceCandidate(Map<String, dynamic> candidateData) async {
    await _peerConnection!.addCandidate(RTCIceCandidate(
      candidateData['candidate'],
      candidateData['sdpMid'],
      candidateData['sdpMLineIndex'],
    ));
  }

  Future<void> endCall() async {
    _localStream?.getTracks().forEach((track) => track.stop());
    _remoteStream?.getTracks().forEach((track) => track.stop());
    await _localStream?.dispose();
    await _remoteStream?.dispose();
    await _peerConnection?.close();
    _peerConnection = null;
    _localStream = null;
    _remoteStream = null;
    _callChannel?.unsubscribe();
  }

  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
  }
}
