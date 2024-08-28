import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:internship1/signup_page.dart';

import 'attendance_screen.dart';
import 'dashboad.dart';
import 'event_page.dart';
import 'event_registration_form.dart';
import 'login.dart';
import 'notification_page.dart';
import 'profile_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      //home: const MyHomePage(title: 'Flutter Demo Home Page'),
      home: SignUpPage(),
      //home: NotificationDetail(notification: 'dd',),
    );
  }
}

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//
//
//
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//       appBar: AppBar(
//
//         leading: Icon(Icons.account_circle),
//         title: Text('Attendance Management '),
//         actions: [
//           //Icon(Icons.account_circle),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16),
//             child: Icon(Icons.logout),
//           ),
//           //Icon(Icons.more_vert),
//         ],
//         backgroundColor: Colors.pink,
//
//
//         // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         //
//         // title: Text(widget.title),
//       ),
//       body: Center(
//
//         child: Container(
//             child: Padding(
//               padding: const EdgeInsets.all(14.0),
//               child: Column(
//                 children: <Widget>[
//                   //Row
//                   Container(
//                     width: 380,
//                     height: 200,
//                     // decoration: BoxDecoration(
//                     //     borderRadius: BorderRadius.circular(10),
//                     //     color: Colors.blue), //BoxDecoration
//                     decoration: const BoxDecoration(
//                       image: DecorationImage(
//                         image: AssetImage("assets/images/img.jpg"),
//
//                         // image: NetworkImage(
//                         //     'https://www.kindacode.com/wp-content/uploads/2022/02/beach.jpeg'),
//                         fit: BoxFit.cover,
//                         repeat: ImageRepeat.noRepeat,
//
//                       ),
//                     ),
//
//                   ),
//
//                   Row(
//                     children: <Widget>[
//                       Container(
//                         width: 180,
//                         height: 200,
//                         decoration: const BoxDecoration(
//                           image: DecorationImage(
//                             image: AssetImage("assets/images/img2.jpg"),
//                             // image: NetworkImage(
//                             //     'https://www.kindacode.com/wp-content/uploads/2022/02/beach.jpeg'),
//                             fit: BoxFit.cover,
//                             repeat: ImageRepeat.noRepeat,
//                           ),
//                         ),//BoxDecoration
//                       ),
//                       //Container
//                       SizedBox(
//                         width: 10,
//                       ), //SizedBox
//                       Container(
//                           width: 180,
//                           height: 200,
//                           // decoration: BoxDecoration(
//                           //   borderRadius: BorderRadius.circular(10),
//                           //   color: Colors.cyan,
//                           // ) //BoxedDecoration
//
//                         decoration: const BoxDecoration(
//                           image: DecorationImage(
//                             image: AssetImage("assets/images/img3.jpg"),
//                             // image: NetworkImage(
//                             //     'https://www.kindacode.com/wp-content/uploads/2022/02/beach.jpeg'),
//                             fit: BoxFit.cover,
//                             repeat: ImageRepeat.noRepeat,
//                           ),
//                         ),
//
//
//                       ) //Container
//                     ], //<Widget>[]
//                     mainAxisAlignment: MainAxisAlignment.center,
//                   ),
//                   //Container
//                   Row(
//                     children: <Widget>[
//                       Container(
//                         width: 180,
//                         height: 200,
//                         // decoration: BoxDecoration(
//                         //   borderRadius: BorderRadius.circular(10),
//                         //   color: Colors.cyan,
//                         // ), //BoxDecoration
//
//                         decoration: const BoxDecoration(
//                           image: DecorationImage(
//                             image: AssetImage("assets/images/img4.jpg"),
//                             // image: NetworkImage(
//                             //     'https://www.kindacode.com/wp-content/uploads/2022/02/beach.jpeg'),
//                             fit: BoxFit.cover,
//                             repeat: ImageRepeat.noRepeat,
//                           ),
//                         ),
//
//                       ), //Container
//                       SizedBox(
//                         width: 10,
//                       ), //SizedBox
//                       Container(
//                           width: 180,
//                           height: 200,
//                           // decoration: BoxDecoration(
//                           //   borderRadius: BorderRadius.circular(10),
//                           //   color: Colors.cyan,
//                           // ) //BoxedDecoration
//
//                         decoration: const BoxDecoration(
//                           image: DecorationImage(
//                             image: AssetImage("assets/images/img5.jpg"),
//                             // image: NetworkImage(
//                             //     'https://www.kindacode.com/wp-content/uploads/2022/02/beach.jpeg'),
//                             fit: BoxFit.cover,
//                             repeat: ImageRepeat.noRepeat,
//                           ),
//                         ),
//
//                       ) //Container
//                     ], //<Widget>[]
//                     mainAxisAlignment: MainAxisAlignment.center,
//                   ), //Row
//                 ], //<widget>[]
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//               ), //Column
//             ) //Padding
//         ), //Container
//       //Center
//       ),
//
//     );
//   }
// }
