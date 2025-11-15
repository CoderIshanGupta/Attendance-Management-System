import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Attendance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        navigationBarTheme: NavigationBarThemeData(
          elevation: 3,
          indicatorColor: Colors.deepPurple.withOpacity(0.12),
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            final selected = states.contains(MaterialState.selected);
            return TextStyle(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            );
          }),
        ),
      ),
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.pages,
    );
  }
}
