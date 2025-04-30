


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../SERVICE/backend_connectivity/smart_contract_service.dart';
import '../../SERVICE/screen/styled_widget.dart';
import '../../SERVICE/utils/app_constants.dart';
import 'election_details.dart';

class ManageElection extends StatefulWidget {
  @override
  _ManageElectionState createState() => _ManageElectionState();
}

class _ManageElectionState extends State<ManageElection> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String electionPath;
  int currentStage = 1;

  @override
  void initState() {
    super.initState();
    electionPath = getBasePath();
    _fetchCurrentStage();
  }

  Future<void> _fetchCurrentStage() async {
    try {
      DocumentSnapshot electionDoc =
      await _firestore.doc('$electionPath/Admin/Election Activity').get();
      if (electionDoc.exists) {
        setState(() {
          currentStage = (electionDoc['currentStage'] ?? 1).toInt();
        });
      }
      print("currentStage : $currentStage");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching stage: $e")));
    }
  }

  // Function to determine Firestore path based on election details
  String getElectionPath(ElectionDetails electionDetails) {
    if
    ( electionDetails.electionType == "General (Lok Sabha)" || electionDetails.electionType == "Council of States (Rajya Sabha)")
    { return "Vote Chain/Election/${electionDetails.year}/${electionDetails.electionType}/State/${electionDetails.state}/Party_Candidate"; }

    if
    (
    electionDetails.electionType == "State Assembly (Vidhan Sabha)" || electionDetails.electionType == "Legislary Council (Vidhan Parishad)" ||
        electionDetails.electionType == "Municipal" || electionDetails.electionType == "Panchayat"
    )
    {
      print("2 ✅ Vote Chain/State/${electionDetails.state}/Election/${electionDetails.year}/${electionDetails.electionType}/Party_Candidate");
      return "Vote Chain/State/${electionDetails.state}/Election/${electionDetails.year}/${electionDetails.electionType}/Party_Candidate";
    }
    if
    (
    electionDetails.electionType == "Presidential" || electionDetails.electionType == "Vice-Presidential"
        && electionDetails.state == "_PAN India"
    )
    { return "Vote Chain/Election/${electionDetails.year}/Special Electoral Commission/${electionDetails.electionType}/Party_Candidate"; }

    throw Exception("Invalid election type or state.");
  }
  Future<void> updateUnreviewedParties(ElectionDetails electionDetails) async {
    // Determine the correct Firestore path based on the election type
    String basePath = getElectionPath(electionDetails);

    // Reference to Party_Candidate collection
    CollectionReference partyCandidatesRef = FirebaseFirestore.instance.collection(basePath);

    try {
      // Get all party documents
      QuerySnapshot querySnapshot = await partyCandidatesRef.get();

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Check if "status" is missing and "isPartyApproved" is "Pending Verification"
        if (!data.containsKey('status') && data['isPartyApproved'] == "Pending Verification") {
          await partyCandidatesRef.doc(doc.id).update({
            'isPartyApproved': "Unreviewed",
            'status': "Unreviewed",
          });
        }
      }
    } catch (e) {
      print("Error updating party approvals: $e");
    }
  }

  /// starting one  with doc-collection path scene..
  /// by hardcoded...
  /// by constituencies map inside party name as field...
  /// using Selected_Candidates_Over_All_Constituency to get all constituencies  ---> Worked (below is code of this approach)...
  Future<void> updatePendingCandidateApplications(ElectionDetails electionDetails) async {
    final db = FirebaseFirestore.instance;

    final electionPath = getElectionPath(electionDetails);
    print("✅ Election Path: $electionPath");

    try {
      // Step 1: Get all parties
      final partySnapshot = await db.collection(electionPath).get();
      print("✅ Total Parties: ${partySnapshot.docs.length}");

      for (var partyDoc in partySnapshot.docs) {
        final partyId = partyDoc.id;
        print("🎯 Processing Party: $partyId");

        // Step 2: Get all selected candidates
        final selectedCandidatesPath = '$electionPath/$partyId/Selected_Candidates_Over_All_Constituency';
        final selectedCandidatesSnapshot = await db.collection(selectedCandidatesPath).get();

        print("✅ Total Selected Candidates: ${selectedCandidatesSnapshot.docs.length}");

        List<String> constituencies = [];

        // Step 3: Extract selectedConstituency values
        for (var candidateDoc in selectedCandidatesSnapshot.docs) {
          List<dynamic>? selectedConstituencies = candidateDoc.data()['selectedConstituency'];
          if (selectedConstituencies != null) {
            constituencies.addAll(selectedConstituencies.map((e) => e.toString()));
          }
        }

        // Remove duplicates
        constituencies = constituencies.toSet().toList();
        print("✅ Constituencies under $partyId: $constituencies");

        // Step 4: Loop through constituencies and update applications
        for (var constituencyId in constituencies) {
          final applicationsPath = '$electionPath/$partyId/$constituencyId/Candidate_Application/Application';
          final candidateApplications = await db.collection(applicationsPath).get();

          print("📌 Checking Applications in $constituencyId...");

          for (var candidateDoc in candidateApplications.docs) {
            if (candidateDoc.data()['status'] == 'Pending Approval') {
              await db.collection(applicationsPath).doc(candidateDoc.id).update({'status': 'Unreviewed'});
              print("✅ Updated status for: ${candidateDoc.id}");
            }
          }
        }
      }
    } catch (e) {
      print("❌ Error updating applications: $e");
    }
  }
  Future<bool> _showConfirmationDialog(int stage) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Action"),
        content: Text(
            "Are you sure you want to proceed with ${AppConstants.stageLabels[stage - 1]}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Yes"),
          ),
        ],
      ),
    ) ??
        false;
  }
  Future<void> _updateStage(int stage) async {
    // Load the contract
    SmartContractService contractService = SmartContractService();
    await contractService.loadContract();

    bool confirmAction = await _showConfirmationDialog(stage);
    if (!confirmAction) return;

    try
    {
      await _firestore.doc('$electionPath/Admin/Election Activity')
          .set({
              'currentStage': stage + 1,
              '${AppConstants.stageFirestoreNames[stage - 1]}': 'Completed',
              '${AppConstants.stageFirestoreNames[stage - 1]}_timestamp':
              DateTime.now().toIso8601String(),
            }, SetOptions(merge: true));
      setState(() { currentStage = stage + 1; });


      ///  ************** ********  ****   ***   **   *                         ************** ********  ****   ***   **   *
      ///  ************** ********  ****   ***   **   *                         ************** ********  ****   ***   **   *
      // Ensure the contract is loaded before calling any function
      // Fetch election details
      final electionDetails = ElectionDetails.instance;

      // await SmartContractService().loadContract();
      // // Load the contract
      // SmartContractService contractService = SmartContractService();
      // await contractService.loadContract();


      // GET the status from blockchain of respective election everytime, when the stage is updated.
      // await SmartContractService().checkElectionStatus(
      //     electionDetails.year!,
      //     // BigInt.from(int.parse(electionDetails.year!)), // Convert year to BigInt
      //     // int.parse(electionDetails.year!),        // FAILS && NOT WORKS
      //     // BigInt.from(year) as BigInt,             // FAILS && NOT WORKS
      //     electionDetails.electionType!,electionDetails.state!);
      // await SmartContractService().checkElectionStatus(electionDetails.year!,electionDetails.electionType!,electionDetails.state!);        //  Final syntax for this function


      /// ******************    **********    *******   ***   *             ******************    **********    *******   ***   *    Can comment-out below fun to not use solidity fun          ******************    **********    *******   ***   *             ******************    **********    *******   ***   *
      /// ******************    **********    *******   ***   *             ******************    **********    *******   ***   *    Can comment-out below fun to not use solidity fun          ******************    **********    *******   ***   *             ******************    **********    *******   ***   *

      // String electionStatus = await SmartContractService().checkElectionStatus(electionDetails.year!, electionDetails.electionType!, electionDetails.state!);
      // String partyApplication = await SmartContractService().checkPartyApplicationStatus(electionDetails.year!, electionDetails.electionType!, electionDetails.state!);
      // String candidateApplication = await SmartContractService().checkCandidateApplicationStatus(electionDetails.year!, electionDetails.electionType!, electionDetails.state!);

      /// ******************    **********    *******   ***   *             ******************    **********    *******   ***   *    Can comment-out above fun to not use solidity fun          ******************    **********    *******   ***   *             ******************    **********    *******   ***   *
      /// ******************    **********    *******   ***   *             ******************    **********    *******   ***   *    Can comment-out above fun to not use solidity fun          ******************    **********    *******   ***   *             ******************    **********    *******   ***   *


      // // Call respective functions based on the stage
      if
      (
          currentStage == 2
          // && electionStatus == 'NOT_STARTED'
      )
      {
        // Call startPartyApplication  --> Means Create election
        // int year =  electionDetails.year!.runtimeType as int ;
        // await SmartContractService().startElection(
        //     // BigInt.from(int.parse(electionDetails.year!)), // Convert year to BigInt
        //     // int.parse(electionDetails.year!),       // FAILS && NOT WORKS
        //     // BigInt.from(year) as BigInt,       // FAILS && NOT WORKS
        //     electionDetails.electionType!,electionDetails.state!);
        await SmartContractService().startElection(electionDetails.year!,electionDetails.electionType!,electionDetails.state!);
      }
      else if
      (
         currentStage == 3
         // && electionStatus == 'STARTED'
         // && partyApplication == 'NOT_STARTED'
      )
      {
        // Call startPartyApplication
        await SmartContractService().startPartyApplication(electionDetails.year!, electionDetails.electionType!,electionDetails.state!);
      }
      else if
      (
         currentStage == 4
         // && electionStatus == 'STARTED'
         // && partyApplication == 'STARTED'
      )
      {
        // print("Calling stopPartyApplication...");
        // Call stopPartyApplication
        await SmartContractService().stopPartyApplication(electionDetails.year!, electionDetails.electionType!,electionDetails.state!);
      }
      else if
      (
        currentStage == 5
        // && electionStatus == 'STARTED'
        // && partyApplication == 'STOPPED'
        // && candidateApplication == 'NOT_STARTED'
      )
      {
        // print("Calling startCandidateApplication...");
        // Call startCandidateApplication
        await SmartContractService().startCandidateApplication(electionDetails.year!, electionDetails.electionType!,electionDetails.state!);

        // Update unreviewed party applications
        await updateUnreviewedParties(electionDetails);

      }
      else if
      (
        currentStage == 6
        // && electionStatus == 'STARTED'
        // && partyApplication == 'STOPPED'
        // && candidateApplication == 'STARTED'
      )
      {
        // print("Calling stopCandidateApplication...");
        // Call stopCandidateApplication
        await SmartContractService().stopCandidateApplication(electionDetails.year!, electionDetails.electionType!,electionDetails.state!);
      }
      else if
      (
        currentStage == 7
        // && electionStatus == 'STARTED'
        // && partyApplication == 'STOPPED'
        // && candidateApplication == 'STOPPED'
        /// Voting != 'STARTED'  ...................  Not in contract
      )
      {
        // Update unreviewed candidate applications
        await updatePendingCandidateApplications(electionDetails);

        FirebaseService.markVotingStartedInFirebase(electionDetails.year!, electionDetails.electionType!,electionDetails.state!);  // isElectionActive
      }
      else if
      (
        currentStage == 8
        // && electionStatus == 'STARTED'
        // && partyApplication == 'STOPPED'
        // && candidateApplication == 'STOPPED'
        /// Voting == 'STARTED'  ...................  Not in contract  // But not needed as such because we're checking electionStatus == 'STARTED' if true means election i.e., voting is started
      )
      {
        // print("Calling stopElection...");

        // // Sync/get all complete results/data/voteCounts
        try
        { await SmartContractService().syncVotesInFirebase(  electionDetails.year!, electionDetails.electionType!,electionDetails.state!,); }
        catch (e)
        {
          // If syncing fails, show error message and stop further execution.
          // SnackbarUtils.showErrorMessage(context, "Syncing Failed: $e");
          print("❌❌ Syncing Failed");
          print("❌ Error in Sync function: $e");
          // return;
        }
        // // Call stopCandidateApplication
        await SmartContractService().stopElection( electionDetails.year!, electionDetails.electionType!,electionDetails.state!);
      }
    }
    catch (e)
    {
      SnackbarUtils.showErrorMessage(context, "Error updating stage: $e");
      print("❌ 00000000 Error starting election: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.appBarColor,
        title: Center(
          child: Text(
            'Manage Election',
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Image
          // Positioned(
          //   top: 0,
          //   left: 0,
          //   right: 0,
          //   child: Container(
          //     height: 200,
          //     decoration: BoxDecoration(
          //       image: DecorationImage(
          //         image: AssetImage("assets/images/election_banner.jpg"), // Change image path
          //         fit: BoxFit.cover,
          //       ),
          //     ),
          //   ),
          // ),

          // Card with Buttons
          Positioned(
            top: 40,
            bottom: 40,
            left: 0,
            right: 0,
            child: Card(
              color: Colors.white,
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(7, (index) {
                    int stage = index + 1;
                    // print("stage : $stage");
                    return Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: ElevatedButton(
                        onPressed: (stage == currentStage)
                            ? () => _updateStage(stage)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          (stage == currentStage) ? Colors.teal : Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: Text(
                          AppConstants.stageLabels[index],
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
