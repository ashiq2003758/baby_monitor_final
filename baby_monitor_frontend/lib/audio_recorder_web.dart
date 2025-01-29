import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';

class AudioRecorderWeb extends StatefulWidget {
  const AudioRecorderWeb({super.key});

  @override
  _AudioRecorderWebState createState() => _AudioRecorderWebState();
}

class _AudioRecorderWebState extends State<AudioRecorderWeb> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    await _recorder.openRecorder();
  }

  Future<void> _startRecording() async {
    await _recorder.startRecorder(toFile: 'audio_record.aac');
    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
    });
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audio Recorder Web')),
      body: Center(
        child: ElevatedButton(
          onPressed: _isRecording ? _stopRecording : _startRecording,
          child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
        ),
      ),
    );
  }
}
