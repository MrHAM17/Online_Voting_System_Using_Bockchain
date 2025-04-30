import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mech_it/SERVICE/screen/styled_widget.dart';
import 'package:mech_it/USER/citizen/vote_candidate_list.dart';

class EligibleElections extends StatefulWidget {
  final String state; // Add state as a parameter
  final String email; // Add state as a parameter

  EligibleElections({required this.state, required this.email}); // Pass state to constructor

  @override
  _EligibleElectionsState createState() => _EligibleElectionsState();
}

class _EligibleElectionsState extends State<EligibleElections> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<DocumentSnapshot> _eligibleStateElections = [];
  List<DocumentSnapshot> _eligibleNationalElections = [];

  @override
  void initState() {
    super.initState();
    // Fetch both state-level and national-level elections when the screen opens
    _fetchStateLevelElections(widget.state, "2024");  // Example with year 2024, you can modify as needed
    // _fetchNationalLevelElections("2024");  // Same for national level
  }

  // Fetch eligible state-level elections based on currentStage >= 4
  Future<void> _fetchStateLevelElections(String state, String currentYear) async {
    print("Fetching state elections for state: $state");

    var yearSnapshot = await _firestore
        .collection("Vote Chain")
        .doc("State")
        .collection(state)
        .doc("Election")
        .collection(currentYear) // Use the current year directly
        .get();

    var eligibleElections = <DocumentSnapshot>[];

    for (var electionDoc in yearSnapshot.docs) {
      var electionActivityDoc = await electionDoc.reference
          .collection("Admin")
          .doc("Election Activity")
          .get();

      if (electionActivityDoc.exists) {
        var data = electionActivityDoc.data() as Map<String, dynamic>?;
        var currentStage = data?['currentStage'];

        if (currentStage != null) {
          var parsedStage = int.tryParse(currentStage.toString());
          if
          (parsedStage != null && parsedStage <= 6)
          { SnackbarUtils.showErrorMessage(context, "Voting is not started yet."); }
          else if
          (parsedStage != null && parsedStage == 7)
          { eligibleElections.add(electionDoc); } // Add election if eligible
          else if
          (parsedStage != null && parsedStage >= 8)
          { SnackbarUtils.showErrorMessage(context, "Voting is stopped."); }
          else { print("Election ${electionDoc.id} currentStage: $currentStage (not eligible)"); }
        }
      }
    }

    setState(() {
      _eligibleStateElections = eligibleElections; // Update the list of eligible state elections
    });

    print("Eligible state elections: ${_eligibleStateElections.length}");
  }

  // Fetch eligible national-level elections based on currentStage >= 4
  Future<void> _fetchNationalLevelElections(String currentYear) async {
    print("Fetching national elections for year: $currentYear");

    var yearSnapshot = await _firestore
        .collection("Vote Chain")
        .doc("Election")
        .collection(currentYear) // Use the current year directly
        .get();

    var eligibleElections = <DocumentSnapshot>[];

    for (var electionDoc in yearSnapshot.docs) {
      var electionActivityDoc = await electionDoc.reference
          .collection("Admin")
          .doc("Election Activity")
          .get();

      if (electionActivityDoc.exists) {
        var data = electionActivityDoc.data() as Map<String, dynamic>?;
        var currentStage = data?['currentStage'];

        if (currentStage != null) {
          var parsedStage = int.tryParse(currentStage.toString());
          if
          (parsedStage != null && parsedStage <= 6)
          { SnackbarUtils.showErrorMessage(context, "Voting is not started yet."); }
          else if
          (parsedStage != null && parsedStage == 7)
          { eligibleElections.add(electionDoc); } // Add election if eligible
          else if
          (parsedStage != null && parsedStage >= 8)
          { SnackbarUtils.showErrorMessage(context, "Voting is stopped."); }
          else
          { print("Election ${electionDoc.id} currentStage: $currentStage (not eligible)"); }
        }
      }
    }

    setState(() {
      _eligibleNationalElections = eligibleElections; // Update the list of eligible national elections
    });

    print("Eligible national elections: ${_eligibleNationalElections.length}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(8.0), // Add padding around the body
        child: ListView(
          children: [
            // Display state elections
            if (_eligibleStateElections.isNotEmpty)
              ..._eligibleStateElections.map((election) {
                var data = election.data() as Map<String, dynamic>?;
                var currentStage = data?['currentStage'];
                String currentStageDisplay = currentStage != null ? currentStage.toString() : "Not available";

                return Card(
                  elevation: 4, // Add shadow for a better card appearance
                  margin: EdgeInsets.symmetric(vertical: 8), // Add vertical margin between cards
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners for card
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16), // Padding inside each card
                    title: Text(
                      "State Election: ${election.id}",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Bold title
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text("Current Stage: $currentStageDisplay", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                        SizedBox(height: 8),
                        Text("Election Year: 2024", style: TextStyle(fontSize: 14, color: Colors.blue)),
                      ],
                    ),
                    leading: Icon(Icons.poll, color: Colors.blue, size: 30), // Add an icon for better visuals
                      onTap: ()
                      {
                        String electionType = '';

                        // Determine whether the election is state or national
                        if
                        (_eligibleStateElections.any((e) => e.id == election.id))
                        { electionType = "State"; }
                        else if
                        (_eligibleNationalElections.any((e) => e.id == election.id))
                        { electionType = "National"; }
                        else
                        { print("Error: Election not found in state or national lists!");  return;  }

                        // Now, we can pass the correct election ID and type
                        String electionPath = (electionType == "State")
                            ? "Vote Chain/State/${widget.state}/Election/2024/${election.id}"
                            : "Vote Chain/Election/2024/${election.id}/State/${widget.state}";

                        // Navigate to the candidate list page, passing election type and ID
                        Navigator.push(
                          context,
                          MaterialPageRoute( builder: (context) => VoteCandidateList
                            (
                            state: widget.state,
                            userEmail: widget.email,
                            electionId: election.id,  // Pass the election ID
                            electionPath: electionPath, // Pass the election type
                            electionType: electionType
                          ),
                          ),
                        );
                      }
                  ),
                );
              }).toList(),

            // Display national elections
            if (_eligibleNationalElections.isNotEmpty)
              ..._eligibleNationalElections.map((election) {
                var data = election.data() as Map<String, dynamic>?;
                var currentStage = data?['currentStage'];
                String currentStageDisplay = currentStage != null ? currentStage.toString() : "Not available";

                return Card(
                  elevation: 4, // Add shadow for a better card appearance
                  margin: EdgeInsets.symmetric(vertical: 8), // Add vertical margin between cards
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Rounded corners for card
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16), // Padding inside each card
                    title: Text(
                      "National Election: ${election.id}",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Bold title
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text("Current Stage: $currentStageDisplay", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                        SizedBox(height: 8),
                        Text("Election Year: 2024", style: TextStyle(fontSize: 14, color: Colors.blue)),
                      ],
                    ),
                    leading: Icon(Icons.poll, color: Colors.blue, size: 30), // Add an icon for better visuals
                      onTap: ()
                      {
                        String electionType = '';

                        // Determine whether the election is state or national
                        if
                        (_eligibleStateElections.any((e) => e.id == election.id))
                        { electionType = "State"; }
                        else if
                        (_eligibleNationalElections.any((e) => e.id == election.id))
                        { electionType = "National"; }
                        else
                        { print("Error: Election not found in state or national lists!");  return;  }

                        // Now, we can pass the correct election ID and type
                        String electionPath = (electionType == "State")
                            ? "Vote Chain/State/${widget.state}/Election/2024/${election.id}"
                            : "Vote Chain/Election/2024/${election.id}/State/${widget.state}";

                        // Navigate to the candidate list page, passing election type and ID
                        Navigator.push(
                          context,
                          MaterialPageRoute( builder: (context) => VoteCandidateList
                            (
                              state: widget.state,
                              userEmail: widget.email,
                              electionId: election.id,  // Pass the election ID
                              electionPath: electionPath,
                              electionType: electionType, // Pass the election type
                            ),
                          ),
                        );
                      }
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}


