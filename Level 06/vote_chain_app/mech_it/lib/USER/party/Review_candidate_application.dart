

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../SERVICE/backend_connectivity/smart_contract_service.dart';
import '../../SERVICE/screen/filter_fab.dart';
import '../../SERVICE/screen/styled_widget.dart';


class ReviewTab extends StatefulWidget {

  final String partyName; // Add this field
  const ReviewTab({required this.partyName, Key? key}) : super(key: key); // Add the required parameter

  @override
  _ReviewTabState createState() => _ReviewTabState();
}

class _ReviewTabState extends State<ReviewTab> {

  String? selectedYear;
  String? selectedElectionType;
  String? selectedState;
  String? selectedConstituency;
  bool isLoading = false;
  List<Map<String, dynamic>> candidateApplications = [];
  Map<String, bool> loadingMap = {}; // Track loading state for each party



  // Function to update a specific card's loading state
  void setLoadingState(String candidateId, bool state) {
    setState(() {
      loadingMap[candidateId] = state;
    });
    print("Loading state for $candidateId: $state"); // Debugging
  }

  Widget buildFilterButton() {
    return Stack(
      children: [
        // FilterFAB(), // Pass the updateFilters method to FilterFAB
        FilterFAB(role: 'Party Head',
          onFilterApplied: (filters) {
            updateFilters(filters);
          },
        ),
      ],
    );
  }

  void updateFilters(Map<String, String?> filters) {
    print("111 hiii ................ $selectedYear");
    print("112 hiii ................ $selectedElectionType");
    print("113 hiii ................ $selectedState");
    print("114 hiii ................ $selectedConstituency");

    setState(() {
      selectedElectionType = filters['type'];
      selectedYear = filters['year'];
      selectedState = filters['state'];
      selectedConstituency = filters['constituency'];
    });

    if
    (selectedElectionType != null && selectedYear != null && selectedState != null && selectedConstituency != null )
    {
      SnackbarUtils.showSuccessMessage(context,"Loading Candidates' Applications..");
      // print('***Filters are:\n ElectionType=$selectedElectionType, \nYear=$selectedYear,\n State=$selectedState,\n Constituency=$selectedConstituency, \n Party= $widget.partyName');
      fetchApplications();
    }
    else
    {
      SnackbarUtils.showErrorMessage( context, "Please select all filter options before proceeding.");
    }
  }

  Future<void> fetchApplications() async
  {

    if
    ( selectedElectionType == null || selectedYear == null || selectedState == null || selectedConstituency == null )
    {
      // print('***Filters are incomplete:\n ElectionType=$selectedElectionType, \nYear=$selectedYear,\n State=$selectedState,\n Constituency=$selectedConstituency');
      SnackbarUtils.showErrorMessage(context, 'Filters are incomplete. Please try again.');
      return;
    }

    print("66666666666 Rendering ${candidateApplications.length} applications.");

    setState(() {
      isLoading = true;
      candidateApplications = [];
    });

    print("77777777777 Rendering ${candidateApplications.length} applications.");

    try
    {
      String electionActivityPath = "";
      String basePath = "";
      DocumentSnapshot? partySnapshot;

      if (selectedElectionType == "General (Lok Sabha)" || selectedElectionType == "Council of States (Rajya Sabha)")
      {
        electionActivityPath = "Vote Chain/Election/$selectedYear/$selectedElectionType/State/$selectedState/Admin/Election Activity";
        // Check if the party is officially registered
        partySnapshot = await FirebaseFirestore.instance
            .doc("Vote Chain/Election/$selectedYear/$selectedElectionType/State/$selectedState/Party_Candidate/${widget.partyName}")
            .get();

        basePath = "Vote Chain/Election/$selectedYear/$selectedElectionType/State/$selectedState/Party_Candidate/${widget.partyName}/$selectedConstituency/Candidate_Application/Application";
      }
      else if
      (
      selectedElectionType == "State Assembly (Vidhan Sabha)" || selectedElectionType == "Legislary Council (Vidhan Parishad)" ||
          selectedElectionType == "Municipal" || selectedElectionType == "Panchayat"
      )
      {
        electionActivityPath = "Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Admin/Election Activity";
        // Check if the party is officially registered
        partySnapshot = await FirebaseFirestore.instance
            .doc("Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Party_Candidate/${widget.partyName}")
            .get();

        basePath = "Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Party_Candidate/${widget.partyName}/$selectedConstituency/Candidate_Application/Application";
      }
      else if
      ( selectedElectionType == "Presidential" || selectedElectionType == "Vice-Presidential")
      {
        if (selectedState == "_PAN India")
        {
          electionActivityPath = "Vote Chain/Election/$selectedYear/Special Electoral Commission/$selectedElectionType/Admin/Election Activity";
          basePath = "Vote Chain/Election/$selectedYear/Special Electoral Commission/$selectedElectionType/Party_Candidate/Candidate_Application/Candidate_Application/Application";
        }
        else
        {
          SnackbarUtils.showErrorMessage(context, "Invalid state selection for $selectedElectionType.");
          return;
        }
      }
      else if
      (selectedElectionType == "By-elections")
      {
        SnackbarUtils.showErrorMessage(context,"This functionality for $selectedElectionType is under development.\nPlease choose another.");
        return;
      }

      print("***** *** Base Path: $basePath");

      // Check the current election stage
      DocumentSnapshot electionActivity = await FirebaseFirestore.instance.doc('$electionActivityPath').get();

      if (!electionActivity.exists)
      { SnackbarUtils.showErrorMessage(context, "Election has not been created yet."); return;  }         // If election does not exist (created)

      int currentStage = (electionActivity['currentStage'] ?? 1).toInt();
      // bool isStageStopped = electionActivity['stage1Completed'] ?? false;  // Assuming stage1Completed indicates if stage 1 is stopped or completed



      /// ******************    **********    *******   ***   *             ******************    **********    *******   ***   *    Can comment-out below fun to not use solidity fun          ******************    **********    *******   ***   *             ******************    **********    *******   ***   *
      /// ******************    **********    *******   ***   *             ******************    **********    *******   ***   *    Can comment-out below fun to not use solidity fun          ******************    **********    *******   ***   *             ******************    **********    *******   ***   *

      // String electionStatus = await SmartContractService().checkElectionStatus(selectedYear!, selectedElectionType!, selectedState!);
      // String partyApplication = await SmartContractService().checkPartyApplicationStatus(selectedYear!, selectedElectionType!, selectedState!);
      // String candidateApplication = await SmartContractService().checkCandidateApplicationStatus(selectedYear!, selectedElectionType!, selectedState!);

      /// ******************    **********    *******   ***   *             ******************    **********    *******   ***   *    Can comment-out above fun to not use solidity fun          ******************    **********    *******   ***   *             ******************    **********    *******   ***   *
      /// ******************    **********    *******   ***   *             ******************    **********    *******   ***   *    Can comment-out above fun to not use solidity fun          ******************    **********    *******   ***   *             ******************    **********    *******   ***   *



      if
      (
        currentStage <= 1
        // && electionStatus == 'NOT_STARTED'
      )
      { SnackbarUtils.showErrorMessage(context, "Election isn't started yet."); return null; }         // If Stage 1 has not started
      else if
      (
        currentStage == 2
        // && electionStatus == 'STARTED'
        // && partyApplication == 'NOT_STARTED'

      )
      { SnackbarUtils.showErrorMessage(context, "Party registration phase isn't started yet."); return; }         // If Stage 1 has not started
      else if
      (
        currentStage == 3
        // && electionStatus == 'STARTED'
        // && partyApplication == 'STARTED'
      )
      { SnackbarUtils.showErrorMessage(context, "Party registration phase is on.\nAfter this phase ends you can verify & approve Party-Head applications."); return; }
      else if
      (
        currentStage == 4                                  // If Stage 1 is completed (stopped)
        // && electionStatus == 'STARTED'
        // && partyApplication == 'STOPPED'
        // && candidateApplication == 'NOT_STARTED'
      )
      { SnackbarUtils.showErrorMessage(context, "Party registration phase is just stopped as of now.\nAfter this Candidate Application phase will start."); return; }
      else if
      (
        currentStage == 5
        // && electionStatus == 'STARTED'
        // && partyApplication == 'STOPPED'
        // && candidateApplication == 'STARTED'
      )
      { SnackbarUtils.showErrorMessage(context, "Candidate Application phase is on as of now.\nAfter this phase ends you can verify & approve candidate applications."); return; }
      else if
      (
        currentStage >= 6                                  // allow ph to accept candi app.
        // && electionStatus == 'STARTED'
        // && partyApplication == 'STOPPED'
        // && candidateApplication == 'STOPPED'
      )
      {
        if (partySnapshot != null && partySnapshot.exists) {
          Map<String, dynamic> partyData = partySnapshot.data() as Map<
              String,
              dynamic>;
          if (partyData['isPartyApproved'] == 'YES')
          {
            QuerySnapshot snapshot = await FirebaseFirestore.instance
                .collection(basePath).get();
            setState(() {
              candidateApplications = snapshot.docs
                  .map((doc) =>
              {
                'id': doc.id,
                // 'status': doc['Accepted'] ?? 'Pending',  // Corrected line
                ...doc.data() as Map<String, dynamic>
              })
                  .toList();

              //////////////////////

              // candidateApplications = snapshot.docs
              //     .map((doc) {
              //   final data = doc.data() as Map<String, dynamic>;  // Explicitly cast data to a Map
              //   return {
              //     'id': doc.id,
              //     // 'status': data['Accepted'] ?? 'Pending',  // Access 'status' after casting
              //     'status': data['status'] ?? 'Pending',  // Access 'status' after casting
              //     // ...data,
              //         ...doc.data() as Map<String, dynamic>
              //
              //   };}).toList();

            });

            ///////////////////////////////

            // setState(() {
            //   candidateApplications = snapshot.docs.map((doc) {
            //     final data = doc.data() as Map<String, dynamic>?;
            //     if (data != null && data.isNotEmpty
            //         // && data.containsKey('status')
            //     ) {
            //       print("Fetched ${snapshot.docs.length} ++++++++ documents from Firebase:");
            //       // for (var doc in snapshot.docs) { print("Doc ID: ${doc.id}, Data: ${doc.data()}"); }
            //
            //       return {
            //       'id': doc.id,
            //         'status': data['status'] ?? 'Pending',
            //         ...data,
            //       };
            //     }
            //     return null; // Exclude null or incomplete entries
            //   }).where((candidate) => candidate != null).cast<Map<String, dynamic>>().toList();
            // });

            print("8888888888888 Rendering ${candidateApplications
                .length} applications.");
          }
          else {
            SnackbarUtils.showErrorMessage(
                context, 'The party is not officially registered.');
          }
        }
        else { SnackbarUtils.showErrorMessage(context, 'Party does not exist.'); }
      }
    }
    catch (e)
    {
      print('Error fetching applications: $e');
      WidgetsBinding.instance.addPostFrameCallback((_)
      { SnackbarUtils.showErrorMessage(context,'Error fetching applications:\n$e');  });

    }
    finally
    {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> acceptCandidate(String candidateId) async
  {
    // setLoadingState(candidateId, true);
    try
    {
      String electionActivityPath = "";
      String  basePath = "";
      DocumentSnapshot? partySnapshot; // Declare it outside the conditionals

      if (selectedElectionType == "General (Lok Sabha)" || selectedElectionType == "Council of States (Rajya Sabha)")
      {
        electionActivityPath = "Vote Chain/Election/$selectedYear/$selectedElectionType/State/$selectedState/Admin/Election Activity";
        // Check if the party is officially registered
        partySnapshot = await FirebaseFirestore.instance
            .doc("Vote Chain/Election/$selectedYear/$selectedElectionType/State/$selectedState/Party_Candidate/${widget.partyName}")
            .get();
        basePath = "Vote Chain/Election/$selectedYear/$selectedElectionType/State/$selectedState/Party_Candidate/${widget.partyName}/$selectedConstituency/Candidate_Application/Application";
      }
      else if
      (
          selectedElectionType == "State Assembly (Vidhan Sabha)" || selectedElectionType == "Legislary Council (Vidhan Parishad)"  ||
          selectedElectionType == "Municipal" || selectedElectionType == "Panchayat"
      )
      {
        electionActivityPath = "Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Admin/Election Activity";
        // Check if the party is officially registered
        partySnapshot = await FirebaseFirestore.instance
            .doc("Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Party_Candidate/${widget.partyName}")
            .get();
        basePath = "Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Party_Candidate/${widget.partyName}/$selectedConstituency/Candidate_Application/Application";
      }
      else if
      (
      selectedElectionType == "By-elections" || selectedElectionType == "Referendum" ||
          selectedElectionType == "Confidence Motion (Floor Test)" || selectedElectionType == "No Confidence Motion")
      {
        SnackbarUtils.showErrorMessage(context,"This functionality for $selectedElectionType is under development.\nPlease choose another.");

        // // Allow only if the Winning Party field is equal to the party name
        // // get winning party status from firebase.........so code ???
        // if (winningParty == widget.partyName)
        // {
        //   if(selectedState == "_PAN India")
        //   {  partyPath = "Vote Chain/Election/$selectedYear/Special Electoral Commission/$selectedElectionType/Party_Candidate/${widget.partyName}";      }
        //   else
        //   {  partyPath = "Vote Chain/State/$selectedState/Election/$selectedYear/Special Electoral Commission/$selectedElectionType/Party_Candidate/${widget.partyName}";      }
        // }
        // else if (winningParty != widget.partyName)
        // {  _showErrorMessage("Only ruling party can apply for $selectedElectionType.");  return;  }

      }



      // Check the current election stage
      DocumentSnapshot electionActivity = await FirebaseFirestore.instance.doc('$electionActivityPath').get();

      if (!electionActivity.exists)
      { SnackbarUtils.showErrorMessage(context, "Election has not been created yet."); return;  }         // If election does not exist (created)

      int currentStage = (electionActivity['currentStage'] ?? 1).toInt();
      // bool isStageStopped = electionActivity['stage1Completed'] ?? false;  // Assuming stage1Completed indicates if stage 1 is stopped or completed



      /// ******************    **********    *******   ***   *             ******************    **********    *******   ***   *    Can comment-out below fun to not use solidity fun          ******************    **********    *******   ***   *             ******************    **********    *******   ***   *
      /// ******************    **********    *******   ***   *             ******************    **********    *******   ***   *    Can comment-out below fun to not use solidity fun          ******************    **********    *******   ***   *             ******************    **********    *******   ***   *

      // String electionStatus = await SmartContractService().checkElectionStatus(selectedYear!, selectedElectionType!, selectedState!);
      // String partyApplication = await SmartContractService().checkPartyApplicationStatus(selectedYear!, selectedElectionType!, selectedState!);
      // String candidateApplication = await SmartContractService().checkCandidateApplicationStatus(selectedYear!, selectedElectionType!, selectedState!);

      /// ******************    **********    *******   ***   *             ******************    **********    *******   ***   *    Can comment-out above fun to not use solidity fun          ******************    **********    *******   ***   *             ******************    **********    *******   ***   *
      /// ******************    **********    *******   ***   *             ******************    **********    *******   ***   *    Can comment-out above fun to not use solidity fun          ******************    **********    *******   ***   *             ******************    **********    *******   ***   *



      if
      (
        currentStage <= 1
        // && electionStatus == 'NOT_STARTED'
      )
      { SnackbarUtils.showErrorMessage(context, "Election isn't started yet."); return null; }         // If Stage 1 has not started
      else if
      (
        currentStage == 2
        // && electionStatus == 'STARTED'
        // && partyApplication == 'NOT_STARTED'
      )
      { SnackbarUtils.showErrorMessage(context, "Party registration phase isn't started yet."); return; }         // If Stage 1 has not started
      else if
      (
        currentStage == 3
        // && electionStatus == 'STARTED'
        // && partyApplication == 'STARTED'
      )
      { SnackbarUtils.showErrorMessage(context, "Party registration phase is on.\nAfter this phase ends you can verify & approve Parties' applications."); return; }
      else if
      (
        currentStage == 4                                  // If Stage 1 is completed (stopped)
        // && electionStatus == 'STARTED'
        // && partyApplication == 'STOPPED'
        // && candidateApplication == 'NOT_STARTED'
      )
      { SnackbarUtils.showErrorMessage(context, "Party registration phase is just stopped as of now.\nAfter this Candidate Application phase will start."); return; }
      else if
      (
        currentStage == 5
        // && electionStatus == 'STARTED'
        // && partyApplication == 'STOPPED'
        // && candidateApplication == 'STARTED'
      )
      { SnackbarUtils.showErrorMessage(context, "Candidate Application phase is on as of now.\nAfter this phase ends you can verify & approve candidate applications."); return; }
      else if
      (
          currentStage == 6                                  // allow ph to accept candi app.
          // && electionStatus == 'STARTED'
          // && partyApplication == 'STOPPED'
          // && candidateApplication == 'STOPPED'
          /// Voting != 'STARTED'  ...................  Not in contract
      )
      {
        // Cast doc.data() as Map<String, dynamic> and check for the 'isPartyOfficiallyRegistered' field
        if (partySnapshot != null && partySnapshot.exists)
        {
          Map<String, dynamic> partyData = partySnapshot.data() as Map<
              String,
              dynamic>;

          if (partyData['isPartyApproved'] == 'YES')
          {

            // Get candidate details first
            DocumentSnapshot candidateSnapshot = await FirebaseFirestore
                .instance
                .doc('$basePath/$candidateId')
                .get();
            Map<String, dynamic> candidateData = candidateSnapshot
                .data() as Map<String, dynamic>;


            // Step 1: Check if a candidate is already selected for the constituency or not ???
            DocumentSnapshot selectedDoc = await FirebaseFirestore.instance.doc('${partySnapshot.reference.path}/$selectedConstituency/Selected').get();

            Map<String, dynamic> selectedData = {};

            // String previousCandidateEmail = selectedDoc.data()?['email'];
            // Map<String, dynamic> selectedData = selectedDoc.data() as Map<String,dynamic> ?? {};
            // Ensure the document exists before accessing data
            if (selectedDoc.exists) {
              selectedData = selectedDoc.data() as Map<String, dynamic>? ?? {};
            }

            // String previousCandidateEmail = selectedData['selectedCandidate'] ??  '';
            // String previousCandidateEmail = selectedData.containsKey('selectedCandidate')
            //     ? selectedData['selectedCandidate'] ?? ''
            //     : ''; // Default to empty string
            String previousCandidateEmail = selectedData['selectedCandidate'] ?? '';


            // if yes (means ph is replacing previously selected candidate with new one for respective constituency).....................
            if (previousCandidateEmail.isNotEmpty)
            {
              print("/// ✅✅✅ 11");

              // Step 1A: Mark previously selected candidate status as "Pending Approval"
              await FirebaseFirestore.instance.collection(basePath)
                  .where('email', isEqualTo: previousCandidateEmail)
                  .get()
                  .then((querySnapshot) {querySnapshot.docs.forEach((doc) {doc.reference.update({'status': 'Pending Approval'});   }); });

              print("/// ✅✅✅ 11.1");

              print('\n\n-------------------------- 1 Path: ${partySnapshot.reference.path}/$selectedConstituency/Selected');


              // Step 1B: Remove(reset to empty) previously selected candidate from "Selected" from that constituency.
              await FirebaseFirestore.instance
                  .doc('${partySnapshot.reference.path}/$selectedConstituency/Selected') // Direct reference to the "Selected" document
                  .update({ 'selectedCandidate': '', })   // Resets the field to an empty string
                  .then((_) =>
                  print("Successfully deleted: $previousCandidateEmail"));

              print('\n\n--------------------------2 Path: ${partySnapshot.reference.path}/$selectedConstituency/Selected');


              // Step 1C: Remove the previously selected candidate from "Selected Candidates Over All Constituency" record
              await FirebaseFirestore.instance
                  .doc("${partySnapshot.reference.path}/Selected_Candidates_Over_All_Constituency/$previousCandidateEmail")
                  .delete()
              // .then((_) => print("Successfully deleted: $previousCandidateEmail"))
                  .catchError((error) => print("Error deleting document: $error"));


              // Step 1D: Remove the previously selected candidate from ".../Result/constituency name/party name/.." record
              /// 🔹 **Removing the Candidate from the Result Section**
              String resultPath = '';
              if (selectedElectionType == "General (Lok Sabha)" || selectedElectionType == "Council of States (Rajya Sabha)")
              { resultPath = "Vote Chain/Election/$selectedYear/$selectedElectionType/State/$selectedState/Result/Election_Result/$selectedConstituency/${widget.partyName}"; }
              else if
              (
                  selectedElectionType == "State Assembly (Vidhan Sabha)" || selectedElectionType == "Legislary Council (Vidhan Parishad)"  ||
                  selectedElectionType == "Municipal" || selectedElectionType == "Panchayat"
              )
              { resultPath = "Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Result/Election_Result/$selectedConstituency/${widget.partyName}"; }

              // { resultPath = "Vote Chain/Election/$selectedYear/$selectedElectionType/State/$selectedState/Result/$selectedConstituency/${widget.partyName}/previousCandidateEmail"; }
              // { resultPath = "Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Result/$selectedConstituency/${widget.partyName}/previousCandidateEmail"; }
              // await FirebaseFirestore.instance.doc(resultPath)
              //     .delete()
              //     .catchError((error) => print("Error deleting document: $error"));

              // { resultPath = "Vote Chain/Election/$selectedYear/$selectedElectionType/State/$selectedState/Result/Election_Result/$selectedConstituency/${widget.partyName}/previousCandidateEmail"; }
              // { resultPath = "Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Result/Election_Result/$selectedConstituency/${widget.partyName}/previousCandidateEmail"; }
              // await FirebaseFirestore.instance.collection(resultPath).doc("Vote_Record")
              //     .delete()
              //     .catchError((error) => print("Error deleting document: $error"));

              await FirebaseFirestore.instance.doc(resultPath)
                  .delete()
                  .catchError((error) => print("Error deleting document: $error"));


              // Step 1E: Remove the previously selected candidate from ".../Result/Fetched_Result/.." record
              String fetchedResultPath = '';
              if (selectedElectionType == "General (Lok Sabha)" || selectedElectionType == "Council of States (Rajya Sabha)")
              { fetchedResultPath = "Vote Chain/Election/$selectedYear/$selectedElectionType/State/$selectedState/Result/Fetched_Result/"; }
              else if
              (
                  selectedElectionType == "State Assembly (Vidhan Sabha)" || selectedElectionType == "Legislary Council (Vidhan Parishad)"  ||
                  selectedElectionType == "Municipal" || selectedElectionType == "Panchayat"
              )
              { fetchedResultPath = "Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Result/Fetched_Result/"; }

              /// Not worked...
              // await FirebaseFirestore.instance.doc(fetchedResultPath).update({
              //   'votes.$previousCandidateEmail': FieldValue.delete(),  // Remove only the previous candidate
              // }).catchError((error) => print("Error deleting candidate: $error"));

              /// Not worked...
              // await FirebaseFirestore.instance.doc(fetchedResultPath).set({
              //   'votes.$previousCandidateEmail': FieldValue.delete(),  // This will delete the previous candidate's map (email and fields inside it)
              // }, SetOptions(merge: true)).catchError((error) => print("Error deleting candidate: $error"));
              // Reference to the document

              DocumentReference docRef = FirebaseFirestore.instance.doc(fetchedResultPath);
              await FirebaseFirestore.instance.runTransaction((transaction) async {
                // Fetch the document snapshot
                DocumentSnapshot snapshot = await transaction.get(docRef);
                if (snapshot.exists)
                {
                  // Extract the current votes map
                  Map<String, dynamic> votesMap = (snapshot.data() as Map<String, dynamic>)['votes'] ?? {};

                  // Remove the candidate from the map
                  votesMap.remove(previousCandidateEmail);

                  // Update Firestore with the modified map
                  transaction.update(docRef, {'votes': votesMap});
                } else {
                  print("Document does not exist.");
                }
              }).then((_) {
                print("Candidate successfully deleted!");
              }).catchError((error) {
                print("Error deleting candidate: $error");
              });


            }


            print("/// ✅✅✅ 12");

            // if no (means ph is first time selecting candidate for respective constituency).....................
            // Step 2:
            await FirebaseFirestore.instance.doc('$basePath/$candidateId').update({'status': 'Accepted'});

            // Step 3:
            await FirebaseFirestore.instance.doc('${partySnapshot.reference.path}/$selectedConstituency/Selected').set(
                {'selectedCandidate': candidateId});

            // Step 4:
            print("");
            // if (selectedElectionType == "General (Lok Sabha)" || selectedElectionType == "Council of States (Rajya Sabha)")
            // {
            //   await FirebaseFirestore.instance
            //       // .doc('Vote Chain/Election/$selectedYear/$selectedElectionType/State/$selectedState/Party_Candidate/${widget.partyName}/Selected_Candidates_Over_All_Constituency/$candidateId')
            //       .doc('${partySnapshot.reference.path}/Selected_Candidates_Over_All_Constituency/$candidateId')
            //       .update({
            //     // 'appliedConstituency': FieldValue.arrayUnion([selectedConstituency]),
            //     // does not make sense for here actually but will for candidate --> so store in detail for candidate in his profile...
            //     'selectedConstituency': FieldValue.arrayUnion([selectedConstituency]),
            //     // 'confirmedConstituency': FieldValue.arrayUnion([answerConstituency]),
            //   });
            // }
            // else if
            // (
            //     selectedElectionType == "State Assembly (Vidhan Sabha)" || selectedElectionType == "Legislary Council (Vidhan Parishad)"  ||
            //     selectedElectionType == "Municipal" || selectedElectionType == "Panchayat"
            // )
            // {
            await FirebaseFirestore.instance
            // .doc('Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Party_Candidate/${widget.partyName}/Selected_Candidates_Over_All_Constituency/$candidateId')
                .doc('${partySnapshot.reference.path}/Selected_Candidates_Over_All_Constituency/$candidateId')
                .set({
              // 'appliedConstituency': FieldValue.arrayUnion([selectedConstituency]),
              // does not make sense for here actually but will for candidate --> so store in detail for candidate in his profile...
              'selectedConstituency': FieldValue.arrayUnion([selectedConstituency]),
              // 'confirmedConstituency': FieldValue.arrayUnion([answerConstituency]),

            });

            // Step 5:
            /// 🔹 **Adding the Candidate to the Result Section**
            String resultPath = '';
            if ( selectedElectionType == "General (Lok Sabha)" || selectedElectionType == "Council of States (Rajya Sabha)" )
            { resultPath = "Vote Chain/Election/$selectedYear/$selectedElectionType/State/$selectedState/Result/Election_Result/$selectedConstituency/${widget.partyName}"; }
            else if
            (
                selectedElectionType == "State Assembly (Vidhan Sabha)" || selectedElectionType == "Legislary Council (Vidhan Parishad)"  ||
                selectedElectionType == "Municipal" || selectedElectionType == "Panchayat"
            )
            { resultPath = "Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Result/Election_Result/$selectedConstituency/${widget.partyName}"; }

            // { resultPath = "Vote Chain/Election/$selectedYear/$selectedElectionType/State/$selectedState/Result/$selectedConstituency/${widget.partyName}/$candidateId"; }
            // { resultPath = "Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Result/$selectedConstituency/${widget.partyName}/$candidateId"; }
            // await FirebaseFirestore.instance.collection(resultPath).set({
            //   // 'name': candidateName,
            //   'email': candidateId,
            //   'vote_count': 0,
            // });

            // { resultPath = "Vote Chain/Election/$selectedYear/$selectedElectionType/State/$selectedState/Result/Election_Result/$selectedConstituency/${widget.partyName}/$candidateId"; }
            // { resultPath = "Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Result/Election_Result/$selectedConstituency/${widget.partyName}/$candidateId"; }
            // await FirebaseFirestore.instance.collection(resultPath).doc("Vote_Record").set({
            //   // 'name': candidateName,
            //   'email': candidateId,
            //   'vote_count': 0,
            // });

            // Storing the candidate's email as a field in the Vote_Record document
            await FirebaseFirestore.instance.doc(resultPath).set({
              'candidate_email': candidateId,  // Storing the email as a field
              'vote_count': '0',        // Initial vote count

              'name': candidateData['name'],
              'gender': candidateData['gender'],
              'age': candidateData['age'],
              'education': candidateData['education'],
              'profession': candidateData['profession'],
              'candidateHomeState': candidateData['candidateHomeState'],
            });

            // Step 6: Add the selected candidate from ".../Result/Fetched_Result/.." record
            String fetchedResultPath = '';
            if (selectedElectionType == "General (Lok Sabha)" || selectedElectionType == "Council of States (Rajya Sabha)")
            { fetchedResultPath = "Vote Chain/Election/$selectedYear/$selectedElectionType/State/$selectedState/Result/Fetched_Result/"; }
            else if
            (
            selectedElectionType == "State Assembly (Vidhan Sabha)" || selectedElectionType == "Legislary Council (Vidhan Parishad)"  ||
                selectedElectionType == "Municipal" || selectedElectionType == "Panchayat"
            )
            { fetchedResultPath = "Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Result/Fetched_Result/"; }


            await FirebaseFirestore.instance.doc(fetchedResultPath).set({
              'votes': {
                candidateId: {
                  'vote_count': 0,   // Initial vote count
                  'party': widget.partyName,
                  'constituency': selectedConstituency,  // Store the selected constituency

                  'name': candidateData['name'],
                  'gender': candidateData['gender'],
                  'age': candidateData['age'],
                  'education': candidateData['education'],
                  'profession': candidateData['profession'],
                  'candidateHomeState': candidateData['candidateHomeState'],
                }
              }
            }, SetOptions(merge: true));  // Merge to keep all candidates inside "votes"


            // }
            // else
            if
            (
            selectedElectionType == "By-elections" || selectedElectionType == "Referendum" ||
                selectedElectionType == "Confidence Motion (Floor Test)" || selectedElectionType == "No Confidence Motion") {
              SnackbarUtils.showErrorMessage(context,"This functionality for $selectedElectionType is under development.\nPlease choose another.");

              // // Allow only if the Winning Party field is equal to the party name
              // // get winning party status from firebase.........so code ???
              // if (winningParty == widget.partyName)
              // {
              // if (selectedElectionType == "General (Lok Sabha)" || selectedElectionType == "Council of States (Rajya Sabha)")
              //   {  partyPath = "Vote Chain/Election/$selectedYear/Special Electoral Commission/$selectedElectionType/State/$selectedState/Party_Candidate/${widget.partyName}";      }
              //   else
              //   {  partyPath = "Vote Chain/State/$selectedState/Election/$selectedYear/Special Electoral Commission/$selectedElectionType/Party_Candidate/${widget.partyName}";      }
              // }
              // else if (winningParty != widget.partyName)
              // {  _showErrorMessage("Only ruling party can apply for $selectedElectionType.");  return;  }

            }

            // // Below line is responsible for removing the candidate from the UI list after PH accepts.
            // setState(() {
            //   candidateApplications.removeWhere((app) =>
            //   app['id'] == candidateId);
            // });

            // // Update status locally in the list
            setState(() {
              candidateApplications = candidateApplications.map((candidate) {
                if (candidate['id'] == candidateId) {
                  candidate['status'] = 'Accepted';
                }
                return candidate;
              }).toList();
            });

            print("44444444444444 Rendering ${candidateApplications
                .length} applications.");
            //
            // setState(() {
            //   candidateApplications = candidateApplications.map((candidate) {
            //     // Ensure the candidate is valid before updating
            //     if (candidate != null && candidate['id'] == candidateId) {
            //       return {
            //         ...candidate, // Spread operator to create a new map
            //         'status': 'Accepted', // Update status
            //       };
            //     }
            //     return candidate; // Return the candidate unchanged
            //   }).where((candidate) => candidate != null).toList(); // Filter out null values
            // });

            print("555555555555 Rendering ${candidateApplications.length} applications.");

            // setLoadingState(candidateId, false);

            // SnackbarUtils.showSuccessMessage(context,'Candidate selected for $selectedConstituency Constituency !');
            SnackbarUtils.showErrorMessage(context,'${candidateData['name']} selected for $selectedConstituency Constituency.');

          }
          else
          {
            SnackbarUtils.showErrorMessage(context, 'The party is not officially registered.');
          }
        }
        else
        { SnackbarUtils.showErrorMessage(context, 'Party does not exist.'); }
      }
      else if
      (
        currentStage >= 7
        // && electionStatus == 'STARTED'
        // && partyApplication == 'STOPPED'
        // && candidateApplication == 'STOPPED'
        /// Voting == 'STARTED'  ...................  Not in contract
      )
      { SnackbarUtils.showErrorMessage(context, "Candidate Application verification & approval phase is stopped."); return; }
    }
    catch (e)
    {
      print("/// ✅✅✅ 13");

      SnackbarUtils.showErrorMessage(context,'Error accepting candidate:\n $e');
      print('Error accepting candidate: $e');
    }
    finally
    {
      // setLoadingState(candidateId, false);
    }
  }

  Future<void> rejectCandidate(String candidateId) async
  {
    // setLoadingState(candidateId, true);
    try
    {
      String electionActivityPath = "";
      String  basePath = "";
      DocumentSnapshot? partySnapshot; // Declare it outside the conditionals

      if (selectedElectionType == "General (Lok Sabha)" || selectedElectionType == "Council of States (Rajya Sabha)")
      {
        electionActivityPath = "Vote Chain/Election/$selectedYear/$selectedElectionType/State/$selectedState/Admin/Election Activity";
        // Check if the party is officially registered
        partySnapshot = await FirebaseFirestore.instance
            .doc("Vote Chain/Election/$selectedYear/$selectedElectionType/State/$selectedState/Party_Candidate/${widget.partyName}")
            .get();
        basePath = "Vote Chain/Election/$selectedYear/$selectedElectionType/State/$selectedState/Party_Candidate/${widget.partyName}/$selectedConstituency/Candidate_Application/Application";
      }
      else if
      (   selectedElectionType == "State Assembly (Vidhan Sabha)" || selectedElectionType == "Legislary Council (Vidhan Parishad)"  ||
          selectedElectionType == "Municipal" || selectedElectionType == "Panchayat"
      )
      {
        electionActivityPath = "Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Admin/Election Activity";
        // Check if the party is officially registered
        partySnapshot = await FirebaseFirestore.instance
            .doc("Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Party_Candidate/${widget.partyName}")
            .get();
        basePath = "Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Party_Candidate/${widget.partyName}/$selectedConstituency/Candidate_Application/Application";
      }
      else if
      (   selectedElectionType == "By-elections" || selectedElectionType == "Referendum" ||
          selectedElectionType == "Confidence Motion (Floor Test)" || selectedElectionType == "No Confidence Motion")
      {
        SnackbarUtils.showErrorMessage(context,"This functionality for $selectedElectionType is under development.\nPlease choose another.");

        // // Allow only if the Winning Party field is equal to the party name
        // // get winning party status from firebase.........so code ???
        // if (winningParty == widget.partyName)
        // {
        // if (selectedElectionType == "General (Lok Sabha)" || selectedElectionType == "Council of States (Rajya Sabha)")
        //   {  partyPath = "Vote Chain/Election/$selectedYear/Special Electoral Commission/$selectedElectionType/State/$selectedState/Party_Candidate/${widget.partyName}";      }
        //   else
        //   {  partyPath = "Vote Chain/State/$selectedState/Election/$selectedYear/Special Electoral Commission/$selectedElectionType/Party_Candidate/${widget.partyName}";      }
        // }
        // else if (winningParty != widget.partyName)
        // {  _showErrorMessage("Only ruling party can apply for $selectedElectionType.");  return;  }
      }

      // Check the current election stage
      DocumentSnapshot electionActivity = await FirebaseFirestore.instance.doc('$electionActivityPath').get();

      if (!electionActivity.exists)
      { SnackbarUtils.showErrorMessage(context, "Election has not been created yet."); return;  }         // If election does not exist (created)

      int currentStage = (electionActivity['currentStage'] ?? 1).toInt();
      // bool isStageStopped = electionActivity['stage1Completed'] ?? false;  // Assuming stage1Completed indicates if stage 1 is stopped or completed



      /// ******************    **********    *******   ***   *             ******************    **********    *******   ***   *    Can comment-out below fun to not use solidity fun          ******************    **********    *******   ***   *             ******************    **********    *******   ***   *
      /// ******************    **********    *******   ***   *             ******************    **********    *******   ***   *    Can comment-out below fun to not use solidity fun          ******************    **********    *******   ***   *             ******************    **********    *******   ***   *

      // String electionStatus = await SmartContractService().checkElectionStatus(selectedYear!, selectedElectionType!, selectedState!);
      // String partyApplication = await SmartContractService().checkPartyApplicationStatus(selectedYear!, selectedElectionType!, selectedState!);
      // String candidateApplication = await SmartContractService().checkCandidateApplicationStatus(selectedYear!, selectedElectionType!, selectedState!);

      /// ******************    **********    *******   ***   *             ******************    **********    *******   ***   *    Can comment-out above fun to not use solidity fun          ******************    **********    *******   ***   *             ******************    **********    *******   ***   *
      /// ******************    **********    *******   ***   *             ******************    **********    *******   ***   *    Can comment-out above fun to not use solidity fun          ******************    **********    *******   ***   *             ******************    **********    *******   ***   *



      if
      (
        currentStage <= 1
        // && electionStatus == 'NOT_STARTED'
      )
      { SnackbarUtils.showErrorMessage(context, "Election isn't started yet."); return null; }         // If Stage 1 has not started
      else if
      (
        currentStage == 2
        // && electionStatus == 'STARTED'
        // && partyApplication == 'NOT_STARTED'
      )
      { SnackbarUtils.showErrorMessage(context, "Party registration phase isn't started yet."); return; }         // If Stage 1 has not started
      else if
      (
        currentStage == 3
        // && electionStatus == 'STARTED'
        // && partyApplication == 'STARTED'
      )
      { SnackbarUtils.showErrorMessage(context, "Party registration phase is on.\nAfter this phase ends you can verify & approve Parties' applications."); return; }
      else if
      (
        currentStage == 4                                  // If Stage 1 is completed (stopped)
        // && electionStatus == 'STARTED'
        // && partyApplication == 'STOPPED'
        // && candidateApplication == 'NOT_STARTED'
      )
      { SnackbarUtils.showErrorMessage(context, "Party registration phase is just stopped as of now.\nAfter this Candidate Application phase will start."); return; }
      else if
      (
        currentStage == 5
        // && electionStatus == 'STARTED'
        // && partyApplication == 'STOPPED'
        // && candidateApplication == 'STARTED'
      )
      { SnackbarUtils.showErrorMessage(context, "Candidate Application phase is on as of now.\nAfter this phase ends you can verify & approve candidate applications."); return; }
      else if
      (
          currentStage == 6                                  // allow ph to reject candi app.
          // && electionStatus == 'STARTED'
          // && partyApplication == 'STOPPED'
          // && candidateApplication == 'STOPPED'
          /// Voting != 'STARTED'  ...................  Not in contract
      )
      {
        // Cast doc.data() as Map<String, dynamic> and check for the 'isPartyOfficiallyRegistered' field
        if (partySnapshot!.exists)
        {
          Map<String, dynamic> partyData = partySnapshot.data() as Map<
              String,
              dynamic>;
          if (partyData['isPartyApproved'] == 'YES')
          {
            // Get candidate details first
            DocumentSnapshot candidateSnapshot = await FirebaseFirestore
                .instance
                .doc('$basePath/$candidateId')
                .get();
            Map<String, dynamic> candidateData = candidateSnapshot
                .data() as Map<String, dynamic>;


            // Step 1: Check if a candidate is already selected for the constituency or not ???
            DocumentSnapshot selectedDoc = await FirebaseFirestore.instance.doc('${partySnapshot.reference.path}/$selectedConstituency/Selected').get();

            Map<String, dynamic> selectedData = {};

            // String previousCandidateEmail = selectedDoc.data()?['email'];
            // Map<String, dynamic> selectedData = selectedDoc.data() as Map<String,dynamic> ?? {};
            // Ensure the document exists before accessing data
            if (selectedDoc.exists) {
              selectedData = selectedDoc.data() as Map<String, dynamic>? ?? {};
            }

            // String previousCandidateEmail = selectedData['selectedCandidate'] ?? '';
            // String previousCandidateEmail = selectedData.containsKey('selectedCandidate')
            //     ? selectedData['selectedCandidate'] ?? ''
            //     : ''; // Default to empty string
            String previousCandidateEmail = selectedData['selectedCandidate'] ?? '';

            print("/// ✅✅✅ 21");

            // if yes (means ph is rejecting currently selected candidate for respective constituency).....................
            if (previousCandidateEmail != Null && previousCandidateEmail.isNotEmpty && previousCandidateEmail == candidateId)
            {
              print("/// ✅✅✅ 21.1");


              // Step 1A: Mark previously selected candidate status as "Rejected"
              await FirebaseFirestore.instance.collection(basePath)
                  .where('email', isEqualTo: previousCandidateEmail)
                  .get()
                  .then((querySnapshot) {querySnapshot.docs.forEach((doc) {doc.reference.update({'status': 'Rejected'});   }); });

              // Step 1B: Remove(reset to empty) previously selected candidate from "Selected" from that constituency.
              await FirebaseFirestore.instance
                  .doc('${partySnapshot.reference.path}/$selectedConstituency/Selected') // Direct reference to the "Selected" document
                  .update({ 'selectedCandidate': '', })   // Resets the field to an empty string
                  .then((_) =>
                  print("Successfully deleted: $previousCandidateEmail"));


              // Step 1C: Remove the previously selected candidate from "Selected Candidates Over All Constituency" record
              await FirebaseFirestore.instance
                  .doc("${partySnapshot.reference.path}/Selected_Candidates_Over_All_Constituency/$previousCandidateEmail")
                  .delete()
              // .then((_) => print("Successfully deleted: $previousCandidateEmail"))
                  .catchError((error) => print("Error deleting document: $error"));


              // Step 1D: Remove the previously selected candidate from ".../Result/constituency name/party name/.." record
              /// 🔹 **Removing the Candidate from the Result Section**
              String resultPath = '';
              if (selectedElectionType == "General (Lok Sabha)" || selectedElectionType == "Council of States (Rajya Sabha)")
              { resultPath = "Vote Chain/Election/$selectedYear/$selectedElectionType/State/$selectedState/Result/Election_Result/$selectedConstituency/${widget.partyName}"; }
              else if
              (
              selectedElectionType == "State Assembly (Vidhan Sabha)" || selectedElectionType == "Legislary Council (Vidhan Parishad)"  ||
                  selectedElectionType == "Municipal" || selectedElectionType == "Panchayat"
              )
              { resultPath = "Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Result/Election_Result/$selectedConstituency/${widget.partyName}"; }

              // { resultPath = "Vote Chain/Election/$selectedYear/$selectedElectionType/State/$selectedState/Result/$selectedConstituency/${widget.partyName}/previousCandidateEmail"; }
              // { resultPath = "Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Result/$selectedConstituency/${widget.partyName}/previousCandidateEmail"; }
              // await FirebaseFirestore.instance.doc(resultPath)
              //     .delete()
              //     .catchError((error) => print("Error deleting document: $error"));

              // { resultPath = "Vote Chain/Election/$selectedYear/$selectedElectionType/State/$selectedState/Result/Election_Result/$selectedConstituency/${widget.partyName}/previousCandidateEmail"; }
              // { resultPath = "Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Result/Election_Result/$selectedConstituency/${widget.partyName}/previousCandidateEmail"; }
              // await FirebaseFirestore.instance.collection(resultPath).doc("Vote_Record")
              //     .delete()
              //     .catchError((error) => print("Error deleting document: $error"));

              await FirebaseFirestore.instance.doc(resultPath)
                  .delete()
                  .catchError((error) => print("Error deleting document: $error"));


              // Step 1E: Remove the previously selected candidate from ".../Result/Fetched_Result/.." record
              String fetchedResultPath = '';
              if (selectedElectionType == "General (Lok Sabha)" || selectedElectionType == "Council of States (Rajya Sabha)")
              { fetchedResultPath = "Vote Chain/Election/$selectedYear/$selectedElectionType/State/$selectedState/Result/Fetched_Result/"; }
              else if
              (
                  selectedElectionType == "State Assembly (Vidhan Sabha)" || selectedElectionType == "Legislary Council (Vidhan Parishad)"  ||
                  selectedElectionType == "Municipal" || selectedElectionType == "Panchayat"
              )
              { fetchedResultPath = "Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Result/Fetched_Result/"; }

              /// Not worked...
              // await FirebaseFirestore.instance.doc(fetchedResultPath).update({
              //   'votes.$previousCandidateEmail': FieldValue.delete(),  // Remove only the previous candidate
              // }).catchError((error) => print("Error deleting candidate: $error"));

              /// Not worked...
              // await FirebaseFirestore.instance.doc(fetchedResultPath).set({
              //   'votes.$previousCandidateEmail': FieldValue.delete(),  // This will delete the previous candidate's map (email and fields inside it)
              // }, SetOptions(merge: true)).catchError((error) => print("Error deleting candidate: $error"));
              // Reference to the document

              DocumentReference docRef = FirebaseFirestore.instance.doc(fetchedResultPath);
              await FirebaseFirestore.instance.runTransaction((transaction) async {
                // Fetch the document snapshot
                DocumentSnapshot snapshot = await transaction.get(docRef);
                if (snapshot.exists)
                {
                  // Extract the current votes map
                  Map<String, dynamic> votesMap = (snapshot.data() as Map<String, dynamic>)['votes'] ?? {};

                  // Remove the candidate from the map
                  votesMap.remove(previousCandidateEmail);

                  // Update Firestore with the modified map
                  transaction.update(docRef, {'votes': votesMap});
                }
                else
                { print("Document does not exist."); }
              }).then((_)
              { print("Candidate successfully deleted!"); })
                  .catchError((error)
              { print("Error deleting candidate: $error"); });


            }


            // if no (means ph is rejecting candidate for respective constituency).....................
            // Step 2:
            // Reject candidate and show real name in Snackbar
            await FirebaseFirestore.instance.doc('$basePath/$candidateId').update({'status': 'Rejected'});

            // //   Below line is responsible for removing the candidate from the UI list after PH rejects.
            // setState(() {
            //   candidateApplications.removeWhere((app) =>
            //   app['id'] == candidateId);
            // });

            // // Update status locally in the list
            setState(() {
              candidateApplications = candidateApplications.map((candidate) {
                if (candidate['id'] == candidateId) {
                  candidate['status'] = 'Rejected'; // Change status instead of removing the card
                }
                return candidate;
              }).toList();
            });

            // setLoadingState(candidateId, false);

            // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(' Candidate rejected for $selectedConstituency Constituency !')), );
            SnackbarUtils.showErrorMessage(context,'${candidateData['name']} rejected for $selectedConstituency Constituency.');
          }
          else {
            SnackbarUtils.showErrorMessage(
                context, 'The party is not officially registered.');
          }
        }
        else
        { SnackbarUtils.showErrorMessage(context, 'Party does not exist.'); }
      }
      else if
      (
        currentStage >= 7
        // && electionStatus == 'STARTED'
        // && partyApplication == 'STOPPED'
        // && candidateApplication == 'STOPPED'
        /// Voting == 'STARTED'  ...................  Not in contract
      )
      { SnackbarUtils.showErrorMessage(context, "Candidate Application verification & approval phase is stopped."); return; }
    }
    catch (e)
    {
      print("/// ✅✅✅ 21.3");
      SnackbarUtils.showErrorMessage(context,'Error rejecting candidate:\n $e');
      print('Error rejecting candidate: $e');
    }
    finally
    {
      // setLoadingState(candidateId, false);
    }
  }

  Widget buildApplicationCard(Map<String, dynamic> application) {
    // String status = application['status'] ?? 'Pending';
    String candidateId = application['id'];

        return Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        color: application['status'] == 'Accepted' // Light teal for accepted
            ? Colors.teal.shade100 // Highlight Accepted status
            : application['status'] == 'Rejected'
            ? Colors.deepOrange.shade50 // Highlight Rejected status
            : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Candidate's photo (rectangular)
              Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/default_photo.png'),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Action buttons (Accept / Reject)
                  Column(
                    children: [
                      // Display CircularProgressIndicator if isLoading is true
                      if (loadingMap[application['id']] == true)
                        CircularProgressIndicator(),

                      if (application['status'] == 'Rejected') ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.deepOrange.shade300,
                                Colors.deepOrange.shade700
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                // color: Colors.black.withOpacity(0.15),
                                color: Colors.deepOrange.shade300.withOpacity(
                                    0.15),
                                offset: Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Text(
                            'Rejected',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: () async {
                            setState(() => isLoading = true);
                            await acceptCandidate(application['id']);
                            await fetchApplications();
                            setState(() => isLoading = false);
                          },
                          iconSize: 28,
                        ),
                      ],
                      if (application['status'] == 'Accepted') ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.teal.shade300,
                                Colors.teal.shade700
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                offset: Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Text(
                            'Accepted',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () async {
                            setLoadingState(candidateId, true); // Start loading
                            await rejectCandidate(application['id']);
                            setLoadingState(application['id'], false);
                          },
                          iconSize: 28,
                        ),
                      ],
                      if (application['status'] != 'Accepted' && application['status'] != 'Rejected' ) ...[
                        // Accept Button (Icon button)
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: () async {
                            setState(() => isLoading = true);
                            // setLoadingState(candidateId, true); // Start loading

                            // print("11111111111111  Before accepting: ${candidateApplications.length} candidates");
                            await acceptCandidate(application['id']);
                            // print("22222222222222  Before accepting: ${candidateApplications.length} candidates");
                            await fetchApplications();
                            // print("33333333333333  Before accepting: ${candidateApplications.length} candidates");

                            setState(() => isLoading = false);
                            // await Future.delayed(Duration(seconds: 2)); // Add a delay of 2 seconds before setting the loading state to false
                            // setLoadingState(application['id'], false);
                          },
                          iconSize: 28,
                        ),
                        const SizedBox(height: 1),
                        // Reject Button (Icon button)
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: () async {
                            setLoadingState(candidateId, true); // Start loading

                            // print("11111111111111  Before rejecting: ${candidateApplications.length} candidates");
                            await rejectCandidate(application['id']);
                            // print("22222222222222  Before rejecting: ${candidateApplications.length} candidates");
                            // await fetchApplications();
                            // print("33333333333333  Before rejecting: ${candidateApplications.length} candidates");

                            setLoadingState(application['id'], false);
                          },
                          iconSize: 28,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // Candidate's details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Age
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal, // Enables horizontal scrolling
                      child: Text(
                        application['name'] ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis, // Prevents name overflow
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Email and Gender with consistent styling
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal, // Enables horizontal scrolling
                      child: Row(
                        children: [
                          Text(
                            'Email:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            application['email'] ?? 'No email provided',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    // Age tag with bold style
                    Row(
                      children: [
                        Text(
                          'Age:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${application['age']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Gender:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${application['gender']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Education and Profession with bold tags
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal, // Enables horizontal scrolling
                      child: Row(
                        children: [
                          Text(
                            'Education:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${application['education']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal, // Enables horizontal scrolling
                      child: Row(
                        children: [
                          Text(
                            'Profession:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${application['profession']}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 2),
                    // Application Status
                    Row(
                      children: [
                        const Text(
                          'Status:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          application['status'] ?? 'Pending',
                          style: TextStyle(
                            fontSize: 14,
                            color: application['status'] == 'Accepted'
                                ? Colors.green
                                : application['status'] == 'Rejected'
                                ? Colors.red
                                : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }

  // Function to display a warning message if candidate is already selected
  void showReplacementWarning(String candidateName, String candidateEmail) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Candidate Already Selected"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("For this constituency, you have already selected a candidate:"),
              SizedBox(height: 10),
              Text("Name: $candidateName"),
              Text("Email: $candidateEmail"),
              SizedBox(height: 10),
              Text("Changing now will replace the previously selected candidate."),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Understand"),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : candidateApplications.isEmpty
            ? Center(
                child: Text(
                  selectedElectionType == null
                      ? 'Please apply filters to view candidates.'
                      : 'No applications found.',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
               )
            : ListView.builder(
                itemCount: candidateApplications.length,
                itemBuilder: (context, index) {
                  final application = candidateApplications[index];
                  return buildApplicationCard(application);
                },
              ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FilterFAB(
            role: 'Party Head',
            onFilterApplied: (filters) {
              updateFilters(filters);
            },
          ),
        ),
        // buildFilterButton(),
      ],
    );
  }
}
