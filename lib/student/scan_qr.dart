import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../utils/toast.dart';   // <--- add this import

class ScanQrScreen extends StatefulWidget {
  final void Function(String) onScan;
  const ScanQrScreen({super.key, required this.onScan});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final controller = MobileScannerController(
    facing: CameraFacing.back,
    torchEnabled: false,
    detectionSpeed: DetectionSpeed.normal, // use manual debounce below
    formats: const [BarcodeFormat.qrCode], // List<BarcodeFormat>, not Set
    autoStart: true,
  );

  bool _handled = false;
  int _lastEventMs = 0;

  bool _isValidAppQr(String? raw) {
    if (raw == null) return false;
    if (!raw.startsWith('ams://attendance')) return false;

    // Enforce 10s TTL
    final uri = Uri.tryParse(raw);
    final tsStr = uri?.queryParameters['ts'];
    if (tsStr == null) return false;
    final ts = int.tryParse(tsStr) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - ts).abs() <= 10 * 1000;
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    if (capture.barcodes.isEmpty) return;

    final code = capture.barcodes.first.rawValue;
    if (code == null) return;

    // Debounce rapid repeats (~600ms)
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastEventMs < 600) return;
    _lastEventMs = now;

    if (_isValidAppQr(code)) {
      _handled = true;
      widget.onScan(code);
      Navigator.pop(context);
    } else {
      showAppToast('Invalid QR for this app');
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final frameSize = MediaQuery.of(context).size.width * 0.7;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => controller.toggleTorch(),
            tooltip: 'Toggle torch',
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => controller.switchCamera(),
            tooltip: 'Switch camera',
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
            fit: BoxFit.cover,
          ),
          // Optional framing overlay
          IgnorePointer(
            child: Center(
              child: Container(
                width: frameSize,
                height: frameSize,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}