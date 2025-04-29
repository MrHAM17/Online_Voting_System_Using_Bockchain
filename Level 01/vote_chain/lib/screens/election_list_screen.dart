import 'package:flutter/material.dart';
import 'vote_screen.dart';

class ElectionListScreen extends StatelessWidget {
  final List<String> elections = ["Election 1", "Election 2", "Election 3"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Available Elections'),
      ),
      body: ListView.builder(
        itemCount: elections.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(elections[index]),
            trailing: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VoteScreen(electionName: elections[index])),
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
