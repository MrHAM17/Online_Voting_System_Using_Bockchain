import 'package:flutter/material.dart';

class ResultsScreen extends StatelessWidget {
  final Map<String, int> results = {
    "Candidate A": 120,
    "Candidate B": 95,
    "Candidate C": 60,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Election Results'),
      ),
      body: ListView(
        children: results.entries.map((entry) {
          return ListTile(
            title: Text(entry.key),
            trailing: Text('${entry.value} votes'),
          );
        }).toList(),
      ),
    );
  }
}
