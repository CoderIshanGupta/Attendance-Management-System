import 'package:flutter/material.dart';
import 'dashboad.dart';
import 'event_registration_form.dart';
import 'modal.dart';

class EventPage extends StatelessWidget {
  EventPage({super.key});

  final List _photos = [
    Data(image: "assets/images/img12.jpg", text: "Coding Contest"),
    Data(image: "assets/images/img15.jpg", text: "Hackathon"),
    Data(image: "assets/images/img17.jpg", text: "Career Fair"),
    Data(image: "assets/images/img16.jpg", text: "Cultural Event"),
    Data(image: "assets/images/img11.jpg", text: "DJ Night"),
    Data(image: "assets/images/img18.jpg", text: "Sports Day"),
    // Data(image:"assets/images/img4.jpg", text:"Attendance"),
    // Data(image:"assets/images/img5.jpg", text:"Attendance"),
  ];

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
          child: Icon(Icons.arrow_back),
        ),
        title: Text('Event Page'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0), // Padding to prevent content from touching edges
        child: GridView.builder(
          itemCount: _photos.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EventRegistrationScreen()),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.width * 0.4, // Responsive height
                    decoration: BoxDecoration(
                      color: Colors.pink,
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        image: AssetImage(_photos[index].image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.0), // Space between image and text
                Expanded(
                  child: Text(
                    _photos[index].text,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      overflow: TextOverflow.ellipsis, // Handle text overflow
                    ),
                    maxLines: 1, // Limit text to one line
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
