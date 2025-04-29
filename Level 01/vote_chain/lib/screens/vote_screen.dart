import 'package:flutter/material.dart';

class VoteScreen extends StatelessWidget {
  final String electionName;
  VoteScreen({required this.electionName});

  final List<String> candidates = ["Candidate A", "Candidate B", "Candidate C"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vote for $electionName'),
      ),
      body: ListView.builder(
        itemCount: candidates.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(candidates[index]),
            trailing: ElevatedButton(
              onPressed: () {
                // Perform voting logic
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Voted for ${candidates[index]}')),
                );
              },
              child: Text('Vote'),
            ),
          );
        },
      ),
    );
  }
}