import 'package:flutter/material.dart';

import 'dashboad.dart';
import 'event_page.dart';

class EventRegistrationScreen extends StatefulWidget {
  @override
  _EventRegistrationScreenState createState() => _EventRegistrationScreenState();
}

class _EventRegistrationScreenState extends State<EventRegistrationScreen> {
  // Define variables to hold form input
  String name = '';
  int age = 0;
  String mobileNumber = '';
  List<String> selectedEvents = [];

  // Event options
  List<String> eventOptions = [
    'Coding Contest',
    'Hackathon',
    'Cultural Fest',
    'Carrerr Fair',
    'Sports Event',
  ];

  // Form submission handler
  void submitForm() {
    // Handle form submission here, e.g., send data to backend
    print('Name: $name');
    print('Age: $age');
    print('Mobile Number: $mobileNumber');
    print('Selected Events: $selectedEvents');
    // You can add further processing here, e.g., API calls, database updates
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EventPage()),
              );
            },
            child: Icon(Icons.arrow_back)),
        title: Text('Event Registration Form'),
        backgroundColor: Colors.indigo,

      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextFormField(
              decoration: InputDecoration(labelText: 'Name'),
              onChanged: (value) {
                setState(() {
                  name = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            TextFormField(
              decoration: InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  age = int.tryParse(value) ?? 0;
                });
              },
            ),
            SizedBox(height: 16.0),
            TextFormField(
              decoration: InputDecoration(labelText: 'Mobile Number'),
              keyboardType: TextInputType.phone,
              onChanged: (value) {
                setState(() {
                  mobileNumber = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            Text('Select events to apply for:'),
            SizedBox(height: 8.0),
            Column(
              children: eventOptions.map((event) {
                return CheckboxListTile(
                  title: Text(event),
                  value: selectedEvents.contains(event),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value != null && value) {
                        selectedEvents.add(event);
                      } else {
                        selectedEvents.remove(event);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EventRegistrationScreen()),
                );
              },
              child: ElevatedButton(
                onPressed: submitForm,
                child: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}