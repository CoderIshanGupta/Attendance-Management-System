import 'dart:convert';

import 'package:flutter/material.dart';

import 'dashboad.dart';

class NotificationDetail extends StatelessWidget {
  final String notification;

  NotificationDetail({required this.notification});

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
        title: Text('Notification Details '),
        backgroundColor: Colors.indigo,

        // title: Text('Notification Detail'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(notification),
        ),
      ),
    );
  }
}
class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<String> notifications = [];
  List<bool> readStatus = [];

  get http => null;

  @override
  void initState() {
    super.initState();
    fetchNotifications(); // Fetch notifications when the page initializes
  }

  Future<void> fetchNotifications() async {
    try {
      final response = await http.get(Uri.parse('YOUR_API_ENDPOINT'));

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        final List<String> fetchedNotifications =
        responseData.map((data) => data['notification'].toString()).toList();
        setState(() {
          notifications = fetchedNotifications;
          readStatus = List.generate(notifications.length, (index) => false);
        });
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (error) {
      print('Error fetching notifications: $error');
      // Handle error appropriately, such as displaying a message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 54, 244, 155),
        title: Text('Notifications'),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(notifications[index]),
            subtitle: readStatus[index] ? Text('Read') : Text('Unread'),
            onTap: () {
              setState(() {
                readStatus[index] = true;
              });
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationDetail(notification: notifications[index])),
              );
            },
          );
        },
      ),
    );
  }
}