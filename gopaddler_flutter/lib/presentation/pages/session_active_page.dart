import 'package:flutter/material.dart';

class SessionActivePage extends StatelessWidget {
  const SessionActivePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Session'),
      ),
      body: const Center(
        child: Text('Active session tracking'),
      ),
    );
  }
}
