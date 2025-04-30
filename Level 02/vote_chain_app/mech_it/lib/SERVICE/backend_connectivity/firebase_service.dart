import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createElection(String state, String year, String electionName, Map<String, dynamic> electionData) async {
    await _firestore
        .collection('Vote Chain')
        .doc('State')
        .collection(state)
        .doc('Election')
        .collection(year)
        .doc(electionName)
        .set(electionData);
  }

  Future<QuerySnapshot> getElections(String state, String year) async {
    return await _firestore
        .collection('Vote Chain')
        .doc('State')
        .collection(state)
        .doc('Election')
        .collection(year)
        .get();
  }
}