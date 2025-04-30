import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VoteCandidateList extends StatefulWidget {
  final String state;
  final String userEmail;
  final String electionId;
  final String electionPath;
  final String electionType;


  const VoteCandidateList({ required this.state, required this.userEmail, required this.electionId, required this.electionPath, required this.electionType });

  @override
  _VoteCandidateListState createState() => _VoteCandidateListState();
}

class _VoteCandidateListState extends State<VoteCandidateList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _candidates = [];
  List<Map<String, dynamic>> fetchedCandidates = []; // Define the variable here

  String? userConstituency;

  @override
  void initState() {
    super.initState();
    _fetchUserConstituency();
  }

  /// Fetches the user's assigned constituency from their profile
  Future<void> _fetchUserConstituency() async {
    try {
      var userDoc = await _firestore.collection("Vote Chain/State/${widget.state}/Citizen/Citizen")
          .doc(widget.userEmail)
          .get();

      if (userDoc.exists) {
        setState(() {
          userConstituency = userDoc.data()?['Original_Constituency'];
        });

        if (userConstituency != null) {
          _fetchCandidates();
        }
      } else {
        print("User profile not found.");
      }
    } catch (e) {
      print("Error fetching user profile: $e");
    }
  }

  /// Fetches candidates based on the user's constituency
  // Future<void> _fetchCandidates() async {
  //   if (userConstituency == null) {
  //     print("❌ User's constituency is not set.");
  //     return;
  //   }
  //
  //   String basePath = '';
  //
  //   // Determine the correct base path
  //   if (widget.electionType == "State") {
  //     basePath =
  //     "Vote Chain/State/${widget.state}/Election/2024/${widget.electionId}/Result";
  //   } else if (widget.electionType == "National") {
  //     basePath =
  //     "Vote Chain/Election/2024/${widget.electionId}/State/${widget.state}/Result";
  //   } else {
  //     print("❌ Invalid election type");
  //     return;
  //   }
  //
  //   // Access the Election_Result document (before constituency and parties)
  //   String electionResultPath = "$basePath";
  //
  //   print("📌 Fetching candidates from: $electionResultPath");
  //
  //   try {
  //
  //     List<Map<String, dynamic>> fetchedCandidates = [];
  //
  //     // Fetch the parties for the specific constituency
  //     var partySnapshots = await _firestore
  //         .collection("$electionResultPath/Election_Result/$userConstituency")
  //         .get();
  //
  //
  //     // Traverse through the parties to fetch candidates
  //     for (var partyDoc in partySnapshots.docs) {
  //       String partyName = partyDoc.id;
  //       print("📌 Found party: $partyName");
  //
  //       // Fetch the candidates for the party (candidates are stored as collections inside the party)
  //       var candidateSnapshots = await _firestore
  //           .collection("$electionResultPath/Election_Result/$userConstituency")
  //           .doc("$partyName")
  //           .get();
  //
  //       print("❌ 1.0");
  //
  //       if (candidateSnapshots.exists) {
  //         print("❌ 1");
  //         print("candidates found under party: $partyName");
  //         // continue;
  //       }
  //
  //       print("❌ 1.1");
  //
  //
  //       // Traverse through the candidates and fetch vote records
  //       // for (var candidateDoc in candidateSnapshots.docs) {
  //       //   String candidateEmail = candidateDoc.id;
  //       String candidateEmail = candidateSnapshots.id;
  //       print("❌ email: $candidateEmail");
  //
  //       print("❌ 1.2");
  //
  //
  //       // Access the Vote_Record document inside the candidate email collection
  //       var voteRecordSnapshot = await _firestore
  //           .collection("$electionResultPath/Election_Result/$userConstituency/$partyName/$candidateEmail")
  //           .doc("Vote_Record") // Assuming Vote_Record is the document name
  //           .get();
  //
  //       print("❌ 1.3");
  //
  //       // if (!voteRecordSnapshot.exists) {
  //       //   print("❌ 2");
  //       //   print("❌ No vote record found for candidate: $candidateEmail");
  //       //   continue;
  //       // }
  //       print("❌ 1.4");
  //
  //
  //       var voteData = voteRecordSnapshot.data();
  //
  //       // Add candidate information to the list
  //       fetchedCandidates.add({
  //         'name': candidateEmail, // Candidate's email is the document ID
  //         'email': candidateEmail,
  //         'party': partyName,
  //         'constituency': userConstituency,
  //         'vote_count': voteData?['vote_count'] ?? 0,
  //       });
  //
  //       print("✅ Candidate: $candidateEmail (Party: $partyName, Constituency: $userConstituency)");
  //       // }
  //     }
  //
  //     setState(() {
  //       _candidates = fetchedCandidates;
  //     });
  //
  //     print("✅ Successfully fetched ${_candidates.length} candidates.");
  //   } catch (e) {
  //     print("❌ Error fetching candidates: $e");
  //   }
  // }

  Future<void> _fetchCandidates() async {
    if (userConstituency == null) {
      print("❌ User's constituency is not set.");
      return;
    }

    String basePath = '';

    // Determine the correct base path
    if (widget.electionType == "State") {
      basePath =
      "Vote Chain/State/${widget.state}/Election/2024/${widget.electionId}/Result";
    } else if (widget.electionType == "National") {
      basePath =
      "Vote Chain/Election/2024/${widget.electionId}/State/${widget.state}/Result";
    } else {
      print("❌ Invalid election type");
      return;
    }

    // Access the Election_Result document (before constituency and parties)
    String electionResultPath = "$basePath";

    print("📌 Fetching candidates from: $electionResultPath");

    try {

      List<Map<String, dynamic>> fetchedCandidates = [];

      // Fetch the parties for the specific constituency
      var partySnapshots = await _firestore
          .collection("$electionResultPath/Election_Result/$userConstituency")
          .get();


      // Traverse through the parties to fetch candidates
      for (var partyDoc in partySnapshots.docs)
      {
        String partyName = partyDoc.id;
        print("📌 Found party: $partyName");


        // Fetch the candidates for the party (candidates are stored as collections inside the party)
        var candidateSnapshots = await _firestore
            .collection("$electionResultPath/Election_Result/$userConstituency")
            .doc("$partyName")
            .get();


        // Fetch the party document reference
        var partyDocRef = _firestore
            .collection("$electionResultPath/Election_Result/$userConstituency")
            .doc("$partyName");

        // Get the subcollections of the party document (where the collection name is the candidate's email)
        var subcollections = await partyDocRef.get();
        String candidateEmail = subcollections.id;

        // // Traverse through the subcollections (each collection name is the candidate's email)
        // for (var subcollection in subcollections.reference.listCollections()) {
        //   String candidateEmail = subcollection.id;  // The subcollection name is the candidate's email
        //   print("✅ Candidate email found: $candidateEmail");
        //
        // }



        // Access the Vote_Record document inside the candidate email collection
        var voteRecordSnapshot = await _firestore
            .collection("$electionResultPath/Election_Result/$userConstituency/$partyName/$candidateEmail")
            .doc("Vote_Record") // Assuming Vote_Record is the document name
            .get();

        var voteData = voteRecordSnapshot.data();

        // Add candidate information to the list
        fetchedCandidates.add({
          'name': candidateEmail, // Candidate's email is the document ID
          'email': candidateEmail,
          'party': partyName,
          'constituency': userConstituency,
          'vote_count': voteData?['vote_count'] ?? 11,

        });

        print("✅ Candidate: $candidateEmail (Party: $partyName, Constituency: $userConstituency)");
        // }
      }

      setState(() {
        _candidates = fetchedCandidates;
      });

      print("✅ Successfully fetched ${_candidates.length} candidates.");
    } catch (e) {
      print("❌ Error fetching candidates: $e");
    }
  }


  /// Handles the voting action
  // Future<void> _voteForCandidate(String candidateEmail) async {
  //   String candidatePath = "${widget.electionPath}/Result/$userConstituency/$candidateEmail";
  //
  //   try {
  //     await _firestore.runTransaction((transaction) async {
  //       var candidateDoc = await transaction.get(_firestore.doc(candidatePath));
  //
  //       if (candidateDoc.exists) {
  //         int currentVotes = candidateDoc.data()?['vote_count'] ?? 0;
  //         transaction.update(candidateDoc.reference, {'vote_count': currentVotes + 1});
  //       }
  //     });
  //
  //     setState(() {
  //       _candidates.firstWhere((c) => c['email'] == candidateEmail)['vote_count']++;
  //     });
  //
  //     ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Vote cast successfully!"))
  //     );
  //   } catch (e) {
  //     print("Error voting: $e");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Candidates in $userConstituency")),
      body: _candidates.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _candidates.length,
        itemBuilder: (context, index) {
          var candidate = _candidates[index];
          return Card(
            margin: EdgeInsets.all(10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              title: Text(candidate['name'], style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                  "Party: ${candidate['party']}"
                      "\nEmail: ${candidate['email']}"
                      "\nVotes: ${candidate['vote_count']}"),
              trailing: ElevatedButton(
                onPressed: () => _voteForCandidate(candidate['email']),
                child: Text("Vote"),
              ),
            ),
          );
        },
      ),
    );
  }
}

_voteForCandidate(candidateEmail) {
}
