//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../services/blockchain_service.dart';
//
// class AdminService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final BlockchainService _blockchainService = BlockchainService();
//
//   // Create a new election in Firebase and Blockchain
//   Future<String> createElection(Map<String, dynamic> electionData) async {
//     try {
//       // Verify admin authentication
//       User? user = _auth.currentUser;
//       if (user == null) {
//         return 'Admin not logged in';
//       }
//
//       // Store the election in Firebase
//       DocumentReference electionRef = await _firestore.collection('Vote Chain')
//           .doc('Admin')
//           .collection('Elections')
//           .add(electionData);
//
//       // Interact with blockchain to register the election
//       String txHash = await _blockchainService.createElectionOnBlockchain(electionData);
//
//       // Update Firebase with the blockchain transaction hash
//       await electionRef.update({'blockchainTxHash': txHash});
//
//       return 'Election created successfully';
//     } catch (e) {
//       return 'Error creating election: $e';
//     }
//   }
//
//   // Fetch all elections from Firebase
//   Future<List<Map<String, dynamic>>> fetchAllElections() async {
//     try {
//       QuerySnapshot snapshot = await _firestore.collection('Vote Chain')
//           .doc('Admin')
//           .collection('Elections')
//           .get();
//
//       List<Map<String, dynamic>> elections = snapshot.docs.map((doc) {
//         return {
//           'id': doc.id,
//           ...doc.data() as Map<String, dynamic>,
//         };
//       }).toList();
//
//       return elections;
//     } catch (e) {
//       throw 'Error fetching elections: $e';
//     }
//   }
//
//   // Generate election reports
//   Future<Map<String, dynamic>> generateElectionReport(String electionId) async {
//     try {
//       // Get election details from Firebase
//       DocumentSnapshot electionSnapshot = await _firestore.collection('Vote Chain')
//           .doc('Admin')
//           .collection('Elections')
//           .doc(electionId)
//           .get();
//
//       Map<String, dynamic> electionDetails = electionSnapshot.data() as Map<String, dynamic>;
//
//       // Fetch election results from the blockchain
//       Map<String, dynamic> blockchainResults = await _blockchainService.getElectionResults(electionId);
//
//       return {
//         'details': electionDetails,
//         'results': blockchainResults,
//       };
//     } catch (e) {
//       throw 'Error generating report: $e';
//     }
//   }
//
//   // Delete an election
//   Future<String> deleteElection(String electionId) async {
//     try {
//       // Remove the election from Firebase
//       await _firestore.collection('Vote Chain')
//           .doc('Admin')
//           .collection('Elections')
//           .doc(electionId)
//           .delete();
//
//       // Notify the blockchain to mark the election as deleted (if required)
//       await _blockchainService.deleteElectionFromBlockchain(electionId);
//
//       return 'Election deleted successfully';
//     } catch (e) {
//       return 'Error deleting election: $e';
//     }
//   }
// }



import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createElection(String name, String type, String state, DateTime startDate, DateTime endDate) async {
    try {
      await _firestore.collection('elections').add({
        'name': name,
        'type': type,
        'state': state,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'isActive': true,
        'totalCandidates': 0,
        'totalVotes': 0,
      });
      print("Election created successfully");
    } catch (e) {
      print("Error creating election: $e");
    }
  }

  Future<void> addCandidate(String electionId, String name, String party) async {
    try {
      DocumentReference electionRef = _firestore.collection('elections').doc(electionId);
      await electionRef.collection('candidates').add({
        'name': name,
        'party': party,
        'voteCount': 0,
      });

      // Update total candidates
      await electionRef.update({
        'totalCandidates': FieldValue.increment(1),
      });
      print("Candidate added successfully");
    } catch (e) {
      print("Error adding candidate: $e");
    }
  }

  Future<void> endElection(String electionId) async {
    try {
      await _firestore.collection('elections').doc(electionId).update({
        'isActive': false,
      });
      print("Election ended successfully");
    } catch (e) {
      print("Error ending election: $e");
    }
  }

  Stream<QuerySnapshot> getActiveElections() {
    return _firestore.collection('elections').where('isActive', isEqualTo: true).snapshots();
  }
}
