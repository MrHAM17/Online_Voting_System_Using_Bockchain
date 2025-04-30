
import 'package:flutter/material.dart';
import 'election_list_screen.dart';
import 'results_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vote Chain Home')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ElectionListScreen())),
            child: Text('View Elections'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ResultsScreen())),
            child: Text('View Results'),
          ),
        ],
      ),
    );
  }
}
