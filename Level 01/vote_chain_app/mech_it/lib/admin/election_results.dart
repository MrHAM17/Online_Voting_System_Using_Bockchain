import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ElectionResults extends StatelessWidget {
  final String electionId;

  const ElectionResults({Key? key, required this.electionId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Election Results"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('elections')
            .doc(electionId)
            .collection('candidates')
            .orderBy('voteCount', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final candidates = snapshot.data!.docs;

          return ListView.builder(
            itemCount: candidates.length,
            itemBuilder: (context, index) {
              final candidate = candidates[index];
              return ListTile(
                title: Text(candidate['name']),
                subtitle: Text('Votes: ${candidate['voteCount']}'),
              );
            },
          );
        },
      ),
    );
  }
}
