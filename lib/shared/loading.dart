import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  final String? label;
  const LoadingScreen({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(
            height: 48,
            width: 48,
            child: CircularProgressIndicator(),
          ),
          if (label != null) ...[
            const SizedBox(height: 12),
            Text(label!, style: const TextStyle(fontSize: 16)),
          ]
        ]),
      ),
    );
  }
}