import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dashboad.dart';
import 'scan_screen.dart'; // Importing separated ScanScreen widget

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String qrText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyHomePage()),
              );
            },
            child: Icon(Icons.arrow_back)),
        title: Text('Mark Attendance '),
       // title: Text('Mark Attendance'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            QrImageView(
              data: qrText,
              size: 200.0,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScanScreen(onScan: (value) {
                setState(() {
                  qrText = value;
                });
              }),
            ),
          );
        },
        child: Icon(Icons.qr_code),
      ),
    );
  }
}

