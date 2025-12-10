import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DailyLogDetailScreen extends StatelessWidget {
  final String logId;

  const DailyLogDetailScreen({super.key, required this.logId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Detail'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Log Detail Screen'),
            Text('Log ID: $logId'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
