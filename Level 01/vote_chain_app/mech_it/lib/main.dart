import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mech_it/services/login.dart';
import 'package:mech_it/services/register.dart';
import 'package:mech_it/user/home_screen.dart';

import 'admin/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vote Chain',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // theme: ThemeData(
      //   useMaterial3: true,
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      //   textTheme: TextTheme(
      //     displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      //     bodyLarge: TextStyle(fontSize: 16),
      //   ),
      // ),

      initialRoute: '/Login', // Ensure initial route is '/login'
      routes: {
        '/Login': (context) => LoginScreen(),
        '/Register': (context) => RegisterScreen(),
        '/AdminDashboard': (context) => AdminDashboard(),
        '/Home': (context) => HomeScreen(),


        // Add routes for adminDashboard and home as needed
      },
    );
  }
}
