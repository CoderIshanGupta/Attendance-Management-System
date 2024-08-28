import 'package:flutter/material.dart';
import 'package:internship1/profile_page.dart';

import 'attendance_graph.dart';
import 'attendance_screen.dart';
import 'event_page.dart';
import 'login.dart';
import 'notification_page.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          },
          child: Icon(Icons.account_circle),
        ),
        title: Text('Attendance Management'),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Icons.logout),
            ),
          ),
        ],
        backgroundColor: Colors.pink,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EventPage()));
                },
                child: Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.width * 0.5, // Adjust height to be responsive
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/img.jpg"),
                      fit: BoxFit.cover,
                      repeat: ImageRepeat.noRepeat,
                    ),
                    borderRadius: BorderRadius.circular(12), // Optional: Add rounded corners
                  ),
                ),
              ),
              SizedBox(height: 15),
              Row(
                children: <Widget>[
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AttendanceScreen()));
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.width * 0.5, // Adjust height to be responsive
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/images/img2.jpg"),
                            fit: BoxFit.cover,
                            repeat: ImageRepeat.noRepeat,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AttendanceGraph()));
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.width * 0.5, // Adjust height to be responsive
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/images/img3.jpg"),
                            fit: BoxFit.cover,
                            repeat: ImageRepeat.noRepeat,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Row(
                children: <Widget>[
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NotificationDetail(notification: '',)));
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.width * 0.5, // Adjust height to be responsive
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/images/img4.jpg"),
                            fit: BoxFit.cover,
                            repeat: ImageRepeat.noRepeat,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Container(
                      height: MediaQuery.of(context).size.width * 0.5, // Adjust height to be responsive
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/img5.jpg"),
                          fit: BoxFit.cover,
                          repeat: ImageRepeat.noRepeat,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
