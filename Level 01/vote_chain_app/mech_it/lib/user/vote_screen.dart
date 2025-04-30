// import 'package:flutter/material.dart';
//
// class VoteScreen extends StatelessWidget {
//   final String electionName;
//   VoteScreen({required this.electionName});
//
//   final List<String> candidates = ["Candidate A", "Candidate B", "Candidate C"];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Vote for $electionName'),
//       ),
//       body: ListView.builder(
//         itemCount: candidates.length,
//         itemBuilder: (context, index) {
//           return ListTile(
//             title: Text(candidates[index]),
//             trailing: ElevatedButton(
//               onPressed: () {
//                 // Perform voting logic
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('Voted for ${candidates[index]}')),
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
import 'package:web3dart/web3dart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/blockchain_service.dart';

class VoteScreen extends StatelessWidget {
  final String electionId;
  final String electionName;
  final BlockchainService blockchainService = BlockchainService();

  VoteScreen({required this.electionId, required this.electionName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vote for $electionName')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('elections').doc(electionId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final electionData = snapshot.data?.data() as Map<String, dynamic>;
          final candidates = List<String>.from(electionData['candidates'] ?? []);

          return ListView.builder(
            itemCount: candidates.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(candidates[index]),
                trailing: ElevatedButton(
                  onPressed: () async {
                    final result = await blockchainService.sendTransaction(
                      'castVote',
                      [candidates[index]],
                      '<privateKey>',
                    );
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Voted for ${candidates[index]}')));
                    FirebaseFirestore.instance.collection('votes').add({
                      'electionId': electionId,
                      'candidate': candidates[index],
                      'userId': '<userId>',
                      'voteHash': result,
                    });
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
