import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanScreen extends StatefulWidget {
  final Function(String) onScan;

  const ScanScreen({Key? key, required this.onScan}) : super(key: key);

  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  GlobalKey qrKey = GlobalKey();
  late QRViewController qrController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code'),
      ),
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.qrController = controller;
    controller.scannedDataStream.listen((scanData) {
      widget.onScan(scanData.code!);
      Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    qrController.dispose();
    super.dispose();
  }
}