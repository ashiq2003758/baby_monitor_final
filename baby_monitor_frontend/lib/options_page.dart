import 'package:flutter/material.dart';
import 'detect_emotion_page.dart'; // Import the new options page
import 'connect_page.dart'; // Import the new options page


class OptionsPage extends StatelessWidget {
  const OptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose an Option')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to the "Detect Baby's Emotion" screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DetectEmotionPage()),
                );
              },
              child: const Text('Detect Baby\'s Emotion'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the "Connect to Mother or Baby" screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ConnectPage()),
                );
              },
              child: const Text('Connect to Mother or Baby'),
            ),
          ],
        ),
      ),
    );
  }
}
