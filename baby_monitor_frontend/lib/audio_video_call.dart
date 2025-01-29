import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class AudioVideoCall extends StatefulWidget {
  const AudioVideoCall({super.key});

  @override
  _AudioVideoCallState createState() => _AudioVideoCallState();
}

class _AudioVideoCallState extends State<AudioVideoCall> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

  @override
  void initState() {
    super.initState();
    initRenderers();
    startCall();
  }

  Future<void> initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<void> startCall() async {
    // Get user media (audio and video)
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': true,
    });
    _localRenderer.srcObject = _localStream;

    // Create a PeerConnection
    _peerConnection = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ]
    });

    // Add local stream to the connection
    _localStream?.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
    });

    // Listen for remote stream
    _peerConnection?.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        _remoteRenderer.srcObject = event.streams[0];
      }
    };

    // Handle ICE candidates
    _peerConnection?.onIceCandidate = (candidate) {
      // Send candidate to the remote peer via signaling server
      print('New ICE Candidate: ${candidate.toMap()}');
    };

    // Handle connection state
    _peerConnection?.onConnectionState = (state) {
      print('Connection state: $state');
    };

    // Create an offer
    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    print('Offer SDP: ${offer.sdp}');
    // Send the offer to the remote peer via signaling server

    // TODO: Receive the remote SDP (answer) and ICE candidates via signaling server
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _peerConnection?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audio & Video Call')),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: RTCVideoView(_localRenderer, mirror: true),
                ),
                Expanded(
                  child: RTCVideoView(_remoteRenderer),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => print('End Call'), // Replace with end call logic
              child: const Text('End Call'),
            ),
          ),
        ],
      ),
    );
  }
}
