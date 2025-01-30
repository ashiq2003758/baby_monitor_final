import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

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
    await _recorder.openRecorder();
  }

  Future<void> _startRecording() async {
    final tempDir = await getTemporaryDirectory();
    final filePath = "${tempDir.path}/recorded_audio.aac";

    await _recorder.startRecorder(toFile: filePath);
    setState(() {
      _isRecording = true;
      _recordedFilePath = filePath;
    });
  }

  Future<void> _stopRecording() async {
    final path = await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
      _recordedFilePath = path;
    });
  }

  Future<void> _sendAudio() async {
    if (_recordedFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No audio recorded.")),
      );
      return;
    }

    var uri = Uri.parse("http://localhost:8080/classify"); // ✅ Correct endpoint
    var request = http.MultipartRequest('POST', uri)
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
    _recorder.closeRecorder();
    super.dispose();
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



