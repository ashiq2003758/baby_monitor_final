import 'package:flutter/material.dart';

class ConnectPage extends StatelessWidget {
  const ConnectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connect to Mother or Baby')),
      body: const Center(
        child: Text('This page will handle the connection to mother or baby.'),
      ),
    );
  }
}

