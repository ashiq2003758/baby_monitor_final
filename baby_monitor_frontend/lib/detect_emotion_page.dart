import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DetectEmotionPage extends StatefulWidget {
  const DetectEmotionPage({super.key});

  @override
  _DetectEmotionPageState createState() => _DetectEmotionPageState();
}

class _DetectEmotionPageState extends State<DetectEmotionPage> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  String? _recordedFilePath;
  String? _responseMessage;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    try {
      // Request microphone permission
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        debugPrint("Microphone permission denied");
        return;
      }

      await _recorder.openRecorder();
      _recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
    } catch (e) {
      debugPrint("Error initializing recorder: $e");
    }
  }

  Future<void> _startRecording() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final filePath = "${tempDir.path}/recorded_audio.aac";

      await _recorder.startRecorder(toFile: filePath);
      setState(() {
        _isRecording = true;
        _recordedFilePath = filePath;
      });
    } catch (e) {
      debugPrint("Error starting recording: $e");
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _recorder.stopRecorder();
      setState(() {
        _isRecording = false;
        _recordedFilePath = path;
      });
    } catch (e) {
      debugPrint("Error stopping recording: $e");
    }
  }

  Future<void> _sendAudio() async {
    if (_recordedFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No audio recorded.")),
      );
      return;
    }

    // Replace 'localhost' with your PC's IP address if testing on a real device
    var uri = Uri.parse("http://192.168.X.X:8080/classify"); // Change this IP

    var request = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        "Content-Type": "multipart/form-data"
      })
      ..files.add(await http.MultipartFile.fromPath('audio', _recordedFilePath!));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseData);

        setState(() {
          _responseMessage =
              "Label: ${jsonResponse['label']}, Confidence: ${jsonResponse['confidence'].toStringAsFixed(2)}";
        });
      } else {
        setState(() {
          _responseMessage = "Error: ${response.reasonPhrase}";
        });
      }
    } catch (e) {
      setState(() {
        _responseMessage = "Request failed: $e";
      });
    }
  }

  @override
  void dispose() {
    _recorder.closeRecorder().then((_) {
      super.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detect Baby's Emotion")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendAudio,
              child: const Text('Send Audio'),
            ),
            const SizedBox(height: 20),
            _responseMessage != null
                ? Text(_responseMessage!,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}




