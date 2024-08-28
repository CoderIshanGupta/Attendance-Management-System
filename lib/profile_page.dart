import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dashboad.dart';

class ProfileScreen extends StatelessWidget {

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: GestureDetector(
        //     onTap: () {
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(builder: (context) => MyHomePage()),
        //       );
        //     },
        //     child: Icon(Icons.arrow_back)),
        // title: Text('Event page '),
        title: Text('Profile Page'),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ), onPressed: () {
          Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyHomePage()),
                  );
        },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Colors.white,
            ),
            onPressed: (){},
          )
        ],
        backgroundColor: Colors.indigo,

      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 70,
                backgroundImage: AssetImage('assets/images/imeg.jpg'),

              ),
            ),
            const SizedBox(height: 20,),
            // Container(
            //   decoration: BoxDecoration(
            //     color: Colors.white,
            //     boxShadow: [
            //       BoxShadow(
            //         offset: Offset(0,5),
            //         color: Colors.deepOrangeAccent.withOpacity(0.2),
            //         spreadRadius: 2,
            //         blurRadius: 10,
            //       )
            //     ]
            //   ),
            //   child: ListTile(
            //     title: const Text('Name'),
            //     subtitle: const Text('Alisha Raje'),
            //     leading: Icon(CupertinoIcons.person),
            //     trailing: Icon(Icons.arrow_forward, color: Colors.grey,),
            //     tileColor: Colors.white,
            //   ),
            // ),
            itemProfile('Name', 'Alisha Raje', CupertinoIcons.person),
            const SizedBox(height: 10,),

            itemProfile('Phone', '954215783', CupertinoIcons.phone),
            const SizedBox(height: 10,),

            itemProfile('Mail', 'alisha@gmail.com', CupertinoIcons.mail),
            const SizedBox(height: 10,),

            itemProfile('Address', 'India', CupertinoIcons.location),


          ],
        ),
      ),
    );
  }
  itemProfile(String title, String subtitle, IconData iconData) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 5),
              color: Colors.deepOrangeAccent.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
            )
          ]
      ),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        leading: Icon(iconData),
        trailing: Icon(Icons.arrow_forward, color: Colors.grey,),
        tileColor: Colors.white,
      ),
    );

  }
}
