// import 'package:flutter/material.dart';
// import 'vote_screen.dart';
//
// class ElectionListScreen extends StatelessWidget {
//   final List<String> elections = ["Election 1", "Election 2", "Election 3"];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Available Elections'),
//       ),
//       body: ListView.builder(
//         itemCount: elections.length,
//         itemBuilder: (context, index) {
//           return ListTile(
//             title: Text(elections[index]),
//             trailing: ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => VoteScreen(electionName: elections[index])),
//                 );
//               },
//               child: Text('Vote'),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'vote_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ElectionListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Available Elections')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('elections').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final elections = snapshot.data?.docs ?? [];
          return ListView.builder(
            itemCount: elections.length,
            itemBuilder: (context, index) {
              final election = elections[index];
              return ListTile(
                title: Text(election['name']),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => VoteScreen(electionId: election.id, electionName: election['name'])),
                    );
                  },
                  child: Text('Vote'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
