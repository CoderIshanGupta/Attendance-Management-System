import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../mock/store.dart';

class LiveQrScreen extends StatefulWidget {
  const LiveQrScreen({super.key});

  @override
  State<LiveQrScreen> createState() => _LiveQrScreenState();
}

class _LiveQrScreenState extends State<LiveQrScreen> {
  final subject = Get.arguments?['subject'] ?? 'Subject';
  final section = Get.arguments?['section'] ?? 'Section';
  final passedSessionId = Get.arguments?['sessionId'] as String?;
  final store = DataStore.I;

  static const rotationSeconds = 10;
  String _payload = '';
  String? _sessionId;
  Timer? _nextRotation;
  final _rand = Random();

  @override
  void initState() {
    super.initState();
    // Ensure there is an active session and get its ID
    _sessionId = passedSessionId ?? store.startOrResumeSession(subject, section).id;
    _rotateAndSchedule();
  }

  void _rotateAndSchedule() {
    final nonce = List.generate(12, (_) => _rand.nextInt(36).toRadixString(36)).join();
    final now = DateTime.now().millisecondsSinceEpoch;
    final sid = _sessionId ?? '${subject.hashCode}_$section';
    setState(() {
      _payload = 'ams://attendance?sid=$sid&ts=$now&n=$nonce';
    });

    _nextRotation?.cancel();
    _nextRotation = Timer(const Duration(seconds: rotationSeconds), _rotateAndSchedule);
  }

  @override
  void dispose() {
    _nextRotation?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final header = '$subject — $section';
    final scanned = _sessionId == null ? 0 : store.scannedCount(_sessionId!);

    return Scaffold(
      appBar: AppBar(title: Text('Live QR • $header')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // QR only (no token/counter shown)
                    QrImageView(data: _payload, size: 220),
                    const SizedBox(height: 24),
                    Text('Scanned: $scanned', style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_sessionId != null) {
                        store.stopSession(_sessionId!);
                      }
                      Get.back();
                    },
                    icon: const Icon(Icons.stop_circle_outlined),
                    label: const Text('Stop Session'),
                  ),
                ),
                const SizedBox(width: 12),
                // Dev-only simulate button (remove when student flow integrated)
                IconButton(
                  onPressed: () {
                    if (_sessionId != null) {
                      store.simulateScan(_sessionId!);
                      setState(() {}); // update scanned count
                    }
                  },
                  icon: const Icon(Icons.add_task),
                  tooltip: 'Simulate Scan',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}