import 'package:flutter/material.dart';

class SessionSummaryPage extends StatelessWidget {
  final String sessionId;

  const SessionSummaryPage({
    Key? key,
    required this.sessionId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Summary'),
      ),
      body: Center(
        child: Text('Summary for session: $sessionId'),
      ),
    );
  }
}
