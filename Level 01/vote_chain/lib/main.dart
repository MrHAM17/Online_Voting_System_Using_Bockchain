import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(VoteChainApp());
}

class VoteChainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vote Chain',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginScreen(),
    );
  }
}
