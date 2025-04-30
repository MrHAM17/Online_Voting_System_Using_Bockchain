
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../SERVICE/backend_connectivity/smart_contract_service.dart';
import '../../SERVICE/screen/styled_widget.dart';
import '../../SERVICE/utils/app_constants.dart';
import '../admin/election_details.dart';

class CandidateApplication extends StatefulWidget {
  const CandidateApplication({Key? key}) : super(key: key);

  @override
  _CandidateApplicationState createState() => _CandidateApplicationState();
}

class _CandidateApplicationState extends State<CandidateApplication> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  String? selectedElectionType;
  String? selectedYear;
  String? selectedState;
  String? selectedParty;
  String? selectedConstituency; // Added field for constituency

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();
  final TextEditingController _CandidateHomeStateController = TextEditingController();

  final _privateKeyMetaMaskController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // Tab controller for 2 tabs
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _educationController.dispose();
    _professionController.dispose();
    _CandidateHomeStateController.dispose();
    _privateKeyMetaMaskController.dispose();
    super.dispose();
  }

  // Fetch authorized parties based on the election type and year
  Future<List<String>> _getAuthorizedParties() async
  {
    if
    (
      selectedElectionType == null || selectedYear == null || selectedState == null

      /// ******************    **********    *******   ***   *             ******************    **********    *******   ***   *    Can comment-out below condition to not use take MetaMask Key for solidity fun          ******************    **********    *******   ***   *             ******************    **********    *******   ***   *

      // || _privateKeyMetaMaskController.text.isEmpty

      /// ******************    **********    *******   ***   *             ******************    **********    *******   ***   *    Can comment-out above condition to not use take MetaMask Key for solidity fun          ******************    **********    *******   ***   *             ******************    **********    *******   ***   *

    )
    { SnackbarUtils.showErrorMessage(context, "Please select all required fields.");  return[]; }


    final privateKey = _privateKeyMetaMaskController.text.trim(); //  Get private key from input
    // Store privateKeyMetaMask in the election_details.dart singleton
    ElectionDetails.instance.privateKeyMetaMask = privateKey;


    String electionActivityPath = "";
    QuerySnapshot? querySnapshot;

    if (selectedElectionType == "General (Lok Sabha)" || selectedElectionType == "Council of States (Rajya Sabha)")
    {
      electionActivityPath = "Vote Chain/Election/$selectedYear/$selectedElectionType/State/$selectedState/Admin/Election Activity";
      querySnapshot = await _firestore
          .collection("Vote Chain/Election/$selectedYear/$selectedElectionType/State/$selectedState/Party_Candidate")
          .get();
    }
    else if
    (
    selectedElectionType == "State Assembly (Vidhan Sabha)" || selectedElectionType == "Legislary Council (Vidhan Parishad)" ||
        selectedElectionType == "Municipal" || selectedElectionType == "Panchayat"
    )
    {
      electionActivityPath = "Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Admin/Election Activity";
      querySnapshot = await _firestore
          .collection("Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Party_Candidate")
          .get();
    }
    else if
    (selectedElectionType == "By-elections"
    // &&
    // (subElectionType == "General (Lok Sabha)" || subElectionType == "Council of States (Rajya Sabha)")
    ) {
      SnackbarUtils.showErrorMessage(context,"This functionality for $selectedElectionType is under development.\nPlease choose another.");

      // querySnapshot = await _firestore
      //     .collection("Vote Chain/Election/$selectedYear/Special Electoral Commission/$selectedElectionType/$subElectionType/State/$selectedState/Party_Candidate")
      //     .get();
    }
    else if
    (selectedElectionType == "By-elections"
    // &&
    // (
    //     subElectionType == "State Assembly (Vidhan Sabha)" || subElectionType == "Legislary Council (Vidhan Parishad)" ||
    //     subElectionType == "Municipal" || subElectionType == "Panchayat"
    // )
    ) {
      SnackbarUtils.showErrorMessage(context,"This functionality for $selectedElectionType is under development.\nPlease choose another.");

      // querySnapshot = await _firestore
      //     .collection("Vote Chain/State/$selectedState/Election/$selectedYear/Special Electoral Commission/$selectedElectionType$subElectionType/Party_Candidate")
      //     .get();
    }


    // Fetch the current election stage to ensure party registration phase is still open
    DocumentSnapshot electionActivity = await FirebaseFirestore.instance.doc('$electionActivityPath').get();
    if (!electionActivity.exists)
    { SnackbarUtils.showErrorMessage(context,'Election has not been created yet.');  return []; }

    int currentStage = (electionActivity['currentStage'] ?? 1).toInt();
    // bool isStageStopped = electionActivity['stage1Completed'] ?? false;



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
    { SnackbarUtils.showErrorMessage(context, "Election isn't started yet."); return[]; }         // If Stage 1 has not started
    else if
    (
      currentStage == 2
      // && electionStatus == 'STARTED'
      // && partyApplication == 'NOT_STARTED'
    )
    { SnackbarUtils.showErrorMessage(context, "Party registration phase itself isn't started yet."); return []; } // If Stage 1 has not started
    else if
    (
      currentStage == 3
      // && electionStatus == 'STARTED'
      // && partyApplication == 'STARTED'
    )
    { SnackbarUtils.showErrorMessage(context, "Party registration phase is on as of now."); return []; }
    else if
    (
      currentStage == 4
      // && electionStatus == 'STARTED'
      // && partyApplication == 'STOPPED'
      // && candidateApplication == 'NOT_STARTED'
    )
    { SnackbarUtils.showErrorMessage(context,"Candidate Application phase is not started yet, will start soon."); return []; } // cand app acceptance is not started
    else if
    (
        currentStage >= 5                                   //......show authorized parties to candidate
        // && electionStatus == 'STARTED'
        // && partyApplication == 'STOPPED'
        // && candidateApplication == 'STARTED'
    )
    {
      // Check if querySnapshot is null, return an empty list in case of failure
      if (querySnapshot == null)
      { return []; }
      // return querySnapshot.docs.map((doc) => doc.id).toList();
      // Filter only those parties with "isPartyOfficiallyRegistered" set to "YES"
      List<String> authorizedParties = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data["isPartyApproved"] == "YES") {
          authorizedParties.add(doc.id);
        } // Add party name to the list
      }
      // Add "Independent" so that candidates can apply without joining any party
      if
      (!authorizedParties.contains("Independent"))
      { authorizedParties.add("Independent"); }
      return authorizedParties;
    }
    // else if (currentStage >= 6)
    // { SnackbarUtils.showErrorMessage(context, "Candidate Application phase is stopped."); return []; }  // not allow because stopped stage 2

    // Default return in case no condition is met
    return [];
  }

  Future<void> _applyForElection() async
  {
    if
    (
      selectedElectionType == null || selectedYear == null || selectedState == null

      /// ******************    **********    *******   ***   *             ******************    **********    *******   ***   *    Can comment-out below condition to not use take MetaMask Key for solidity fun          ******************    **********    *******   ***   *             ******************    **********    *******   ***   *

      // || _privateKeyMetaMaskController.text.isEmpty

      /// ******************    **********    *******   ***   *             ******************    **********    *******   ***   *    Can comment-out above condition to not use take MetaMask Key for solidity fun          ******************    **********    *******   ***   *             ******************    **********    *******   ***   *

    )
    { SnackbarUtils.showErrorMessage(context, "Please select all required fields before applying.");  return;  }

    if (selectedElectionType != "Presidential" && selectedElectionType != "Vice-Presidential")
    {
      if (selectedParty == null)
      { SnackbarUtils.showErrorMessage(context, "Please select a Party."); return; }
      else if (selectedConstituency == null)
      { SnackbarUtils.showErrorMessage(context, "Please select a Constituency."); return; }
    }

    if (_nameController.text.isEmpty || _ageController.text.isEmpty || _genderController.text.isEmpty || _educationController.text.isEmpty || _professionController.text.isEmpty || _CandidateHomeStateController.text.isEmpty )
    { SnackbarUtils.showErrorMessage(context, "Please provide all candidate details.");  return;  }


    String? userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail == null)
    { SnackbarUtils.showErrorMessage(context, "User email not found."); return; }

    try
    {

      final privateKey = _privateKeyMetaMaskController.text.trim(); //  Get private key from input
      // Store privateKeyMetaMask in the election_details.dart singleton
      ElectionDetails.instance.privateKeyMetaMask = privateKey;

      // Declare collectionPath as a mutable variable
      String electionActivityPath = "";
      String collectionPath = "";

      if
      ( selectedElectionType == "General (Lok Sabha)" || selectedElectionType == "Council of States (Rajya Sabha)")
      {
        electionActivityPath = "Vote Chain/Election/$selectedYear/$selectedElectionType/State/$selectedState/Admin/Election Activity";
        collectionPath = "Vote Chain/Election/$selectedYear/$selectedElectionType/State/$selectedState/Party_Candidate/$selectedParty/$selectedConstituency";
      }
      else if
      (
          selectedElectionType == "State Assembly (Vidhan Sabha)" || selectedElectionType == "Legislary Council (Vidhan Parishad)" ||
          selectedElectionType == "Municipal" || selectedElectionType == "Panchayat"
      )
      {
        electionActivityPath = "Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Admin/Election Activity";
        collectionPath = "Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Party_Candidate/$selectedParty/$selectedConstituency";
      }
      else if
      (   (selectedElectionType == "Presidential" || selectedElectionType == "Vice-Presidential") &&  selectedState == "_PAN India")
      {
        electionActivityPath = "Vote Chain/Election/$selectedYear/Special Electoral Commission/$selectedElectionType/Admin/Election Activity";
        collectionPath = "Vote Chain/Election/$selectedYear/Special Electoral Commission/$selectedElectionType/Party_Candidate/Candidate_Application";
      }
      else if
      (selectedElectionType == "By-elections"
      // &&
      // (subElectionType == "General (Lok Sabha)" || subElectionType == "Council of States (Rajya Sabha)")
      )
      {
        SnackbarUtils.showErrorMessage(context,"This functionality for $selectedElectionType is under development.\nPlease choose another.");
        // collectionPath = "Vote Chain/Election/$selectedYear/Special Electoral Commission/$selectedElectionType/$subElectionType/State/$selectedState/Party_Candidate/$selectedParty/$selectedConstituency/Candidate_Application";
      }
      else if
      (selectedElectionType == "By-elections"
      // &&
      // (
      //     subElectionType == "State Assembly (Vidhan Sabha)" || subElectionType == "Legislary Council (Vidhan Parishad)" ||
      //     subElectionType == "Municipal" || subElectionType == "Panchayat"
      // )
      )
      {
        SnackbarUtils.showErrorMessage(context,"This functionality for $selectedElectionType is under development.\nPlease choose another.");
        // collectionPath = "Vote Chain/State/$selectedState/Election/$selectedYear/Special Electoral Commission/$selectedElectionType/Party_Candidate/$selectedParty/$selectedConstituency/Candidate_Application";
      }


      // Fetch the current election stage to ensure party registration phase is still open
      DocumentSnapshot electionActivity = await FirebaseFirestore.instance.doc('$electionActivityPath').get();
      if (!electionActivity.exists)
      { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Election has not been created yet.'))); return; }

      int currentStage = (electionActivity['currentStage'] ?? 1).toInt();
      // bool isStageStopped = electionActivity['stage1Completed'] ?? false;



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
      { SnackbarUtils.showErrorMessage(context, "Election isn't started yet."); return; }         // If Stage 1 has not started
      else if
      (
        currentStage == 2
        // && electionStatus == 'STARTED'
        // && partyApplication == 'NOT_STARTED'
      )
      { SnackbarUtils.showErrorMessage(context, "Party registration phase itself isn't started yet."); return; } // If Stage 1 has not started
      else if
      (
        currentStage == 3
        // && electionStatus == 'STARTED'
        // && partyApplication == 'STARTED'
      )
      { SnackbarUtils.showErrorMessage(context, "Party registration phase is on as of now."); return; }
      else if
      (
        currentStage == 4
        // && electionStatus == 'STARTED'
        // && partyApplication == 'STOPPED'
        // && candidateApplication == 'NOT_STARTED'
      )
      { SnackbarUtils.showErrorMessage(context,"Candidate Application phase is not started yet, will start soon."); return; } // cand app acceptance is not started
      else if
      (
        currentStage == 5                                  //......allow candidate to apply
        // && electionStatus == 'STARTED'
        // && partyApplication == 'STOPPED'
        // && candidateApplication == 'STARTED'
        /// Voting != 'STARTED'  ...................  Not in contract
      )
      {
        final String documentPath = "$collectionPath/Candidate_Application";

        // final String sanitizedEmail = userEmail.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
        final DocumentReference emailDocumentRef =
        FirebaseFirestore.instance.collection(collectionPath).doc(
            "Candidate_Application").collection("Application").doc("$userEmail");

        print("Generated Firestore Path: $documentPath/Application/$userEmail");

        //  Check if the document already exists
        final DocumentSnapshot existingDocument = await emailDocumentRef.get();
        if (existingDocument.exists)
        { SnackbarUtils.showErrorMessage(context,"You have already applied for this election with this party.");  return; }

        final applicationData = {
          "candidateId": FirebaseAuth.instance.currentUser?.uid,
          "state": selectedState,
          "name": _nameController.text.trim(),
          "age": _ageController.text.trim(),
          "gender": _genderController.text.trim(),
          "education": _educationController.text.trim(),
          "profession": _professionController.text.trim(),
          "candidateHomeState": _CandidateHomeStateController.text.trim(),
          "status": "Pending Approval",
          "timestamp": FieldValue.serverTimestamp(),
          "email": userEmail,
        };

        if (selectedElectionType != "Presidential" && selectedElectionType != "Vice-Presidential")
        {
          applicationData["party"] = selectedParty;
          applicationData["constituency"] = selectedConstituency;
        }

        await emailDocumentRef.set(applicationData);

        // Clear all fields after a successful submission
        _nameController.clear();
        _ageController.clear();
        _genderController.clear();
        _educationController.clear();
        _professionController.clear();
        _CandidateHomeStateController.clear();

        setState(() {
          selectedElectionType = null;
          selectedYear = null;
          selectedState = null;
          selectedParty = null;
          selectedConstituency = null;
        });

        SnackbarUtils.showSuccessMessage(context,"Application submitted successfully.\nParty head will review your application.");
      }
      else if
      (
        currentStage >= 6
        // && electionStatus == 'STARTED'
        // && partyApplication == 'STOPPED'
        // && candidateApplication == 'STOPPED'
        /// Voting == 'STARTED'  ...................  Not in contract
      )
      { SnackbarUtils.showErrorMessage(context, "Candidate Application phase is stopped."); return; }  // not allow because stopped stage 2
    }
    catch (e, stackTrace)
    {
      print("Error: $e");
      print(stackTrace);
      SnackbarUtils.showErrorMessage(context, "An unexpected error occurred. Please try again.");
    }
  }

  Future<void> _checkApplicationStatus() async
  {
    // Validate inputs for all election types
    if
    (
      selectedElectionType == null || selectedYear == null || selectedState == null

      /// ******************    **********    *******   ***   *             ******************    **********    *******   ***   *    Can comment-out below condition to not use take MetaMask Key for solidity fun          ******************    **********    *******   ***   *             ******************    **********    *******   ***   *

      // || _privateKeyMetaMaskController.text.isEmpty

      /// ******************    **********    *******   ***   *             ******************    **********    *******   ***   *    Can comment-out above condition to not use take MetaMask Key for solidity fun          ******************    **********    *******   ***   *             ******************    **********    *******   ***   *

    )
    { SnackbarUtils.showErrorMessage(context, "Please select all required fields to check status."); return; }

    // Additional validation for non-Presidential and non-Vice-Presidential elections
    if (selectedElectionType != "Presidential" && selectedElectionType != "Vice-Presidential")
    {
      if (selectedParty == null)
      { SnackbarUtils.showErrorMessage(context, "Please select a Party.");  return;  }
      else if (selectedConstituency == null)
      { SnackbarUtils.showErrorMessage(context, "Please select a Constituency.");  return; }
    }


    final privateKey = _privateKeyMetaMaskController.text.trim(); //  Get private key from input
    // Store privateKeyMetaMask in the election_details.dart singleton
    ElectionDetails.instance.privateKeyMetaMask = privateKey;


    String electionActivityPath = "";
    String partyPath = "";

    // Handle paths based on election type
    if
    (selectedElectionType == "Presidential" || selectedElectionType == "Vice-Presidential")
    {
      if (selectedState != "_PAN India")
      { SnackbarUtils.showErrorMessage(context, "Invalid state selection for $selectedElectionType.\nPlease select '_PAN India'.", );  return;  }
      // Path for Presidential and Vice-Presidential elections
      electionActivityPath = "Vote Chain/Election/$selectedYear/Special Electoral Commission/$selectedElectionType/Admin/Election Activity";
      partyPath = "Vote Chain/Election/$selectedYear/Special Electoral Commission/$selectedElectionType/Party_Candidate/Candidate_Application/Candidate_Application/Application";
    }
    else if
    ( selectedElectionType == "General (Lok Sabha)" || selectedElectionType == "Council of States (Rajya Sabha)")
    {
      electionActivityPath = "Vote Chain/Election/$selectedYear/$selectedElectionType/State/$selectedState/Admin/Election Activity";
      partyPath = "Vote Chain/Election/$selectedYear/$selectedElectionType/State/$selectedState/Party_Candidate/$selectedParty/$selectedConstituency/Candidate_Application/Application";
    }
    else if
    (
      selectedElectionType == "State Assembly (Vidhan Sabha)" ||  selectedElectionType == "Legislary Council (Vidhan Parishad)" ||
      selectedElectionType == "Municipal" || selectedElectionType == "Panchayat"
    )
    {
      electionActivityPath = "Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Admin/Election Activity";
      partyPath = "Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Party_Candidate/$selectedParty/$selectedConstituency/Candidate_Application/Application";
    }
    else if
    (
      selectedElectionType == "By-elections"
      // &&
     // (subElectionType == "General (Lok Sabha)" || subElectionType == "Council of States (Rajya Sabha)")
    )
    {
      SnackbarUtils.showErrorMessage(context,"This functionality for $selectedElectionType is under development.\nPlease choose another.");
      // partyPath = "Vote Chain/Election/$selectedYear/Special Electoral Commission/$selectedElectionType/State/$selectedState/Party_Candidate/$selectedParty/$selectedConstituency/Candidate_Application/Application";
      return;
    }
    else if
    (
        selectedElectionType == "By-elections"
        // &&
        // (
        //     subElectionType == "State Assembly (Vidhan Sabha)" || subElectionType == "Legislary Council (Vidhan Parishad)" ||
        //     subElectionType == "Municipal" || subElectionType == "Panchayat"
        // )
    )
    {
      SnackbarUtils.showErrorMessage(context,"This functionality for $selectedElectionType is under development.\nPlease choose another.");
      // partyPath = "Vote Chain/State/$selectedState/Election/$selectedYear/Special Electoral Commission/$selectedElectionType/Party_Candidate/$selectedParty/$selectedConstituency/Candidate_Application/Application";
      return;
    }

    // Validate user email
    String? userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail == null)
    { SnackbarUtils.showErrorMessage(context, "User email not found.");  return;  }

    try
    {
      // Fetch the current election stage to ensure party registration phase is still open
      DocumentSnapshot electionActivity = await FirebaseFirestore.instance.doc(
          '$electionActivityPath').get();

      if (!electionActivity.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Election has not been created yet.')));
        return;
      }

      int currentStage = (electionActivity['currentStage'] ?? 1).toInt();
      // bool isStageStopped = electionActivity['stage1Completed'] ?? false;



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
      { SnackbarUtils.showErrorMessage(context, "Election isn't started yet."); return; }         // If Stage 1 has not started
      else if
      (
        currentStage == 2
        // && electionStatus == 'STARTED'
        // && partyApplication == 'NOT_STARTED'
      )
      { SnackbarUtils.showErrorMessage( context, "Party registration phase itself isn't started yet.");  return; } // If Stage 1 has not started
      else if
      (
        currentStage == 3
        // && electionStatus == 'STARTED'
        // && partyApplication == 'STARTED'
      )
      { SnackbarUtils.showErrorMessage( context, "Party registration phase is on as of now.");  return;  }
      else if
      (
        currentStage == 4
        // && electionStatus == 'STARTED'
        // && partyApplication == 'STOPPED'
        // && candidateApplication == 'NOT_STARTED'
      )
      { SnackbarUtils.showErrorMessage(context,"Candidate Application phase itself isn't started yet.'\nAfter it ends result will available.");  return;  } // cand app acceptance is not started
      else if
      (
        currentStage == 5
        // && electionStatus == 'STARTED'
        // && partyApplication == 'STOPPED'
        // && candidateApplication == 'STARTED'
      )
      { SnackbarUtils.showErrorMessage(context,"Candidate Application phase is on as of now.'\nAfter it ends result will available."); return; } // cand app acceptance is not started
      else if
      (
          currentStage >= 6                                  // allow candidate to check status ..
          // && electionStatus == 'STARTED'
          // && partyApplication == 'STOPPED'
          // && candidateApplication == 'STOPPED'
      )
      {
        // Fetch the document for Presidential or Vice-Presidential elections
        // final DocumentReference emailDocumentRef = FirebaseFirestore.instance.collection(partyPath).doc("$userEmail");
        final DocumentReference emailDocumentRef = FirebaseFirestore.instance.doc("$partyPath/$userEmail"); // Adjust the path if necessary
        // print("001 Document Data: $partyPath");
        // print("002 Document Data: $userEmail");

        final DocumentSnapshot documentSnapshot = await emailDocumentRef.get();
        // print("**********   **** Generated Firestore Path for Status Check: $partyPath");
        // print("\n 11111: ${documentSnapshot.data()}");

        if (documentSnapshot.exists)
        {
          // Retrieve the status field
          // final String status = documentSnapshot.get('status') ?? "No Status Found";
          final String? status = documentSnapshot.get('status');
          String message = "" ;
          Color statusColor = Colors.white;

          if
          (status == "Unreviewed")
          {
            message = "$status.\n\nNot reviewed by '$selectedParty' authorities.";
            statusColor = Colors.black;
            // SnackbarUtils.showErrorMessage( context, "Application Status: $status.\nNot reviewed by party authorities.");
          }
          else if
          (status == "Accepted")
          {
            message = "$status.\n\n'$selectedParty' approved you as a candidate for '$selectedConstituency' Constituency.";
            statusColor = Colors.green;
            // SnackbarUtils.showSuccessMessage( context, "Application Status: $status");
          }
          else if
          (status == "Rejected")
          {
            message = "$status.\n\n'$selectedParty' not approved you as a candidate for '$selectedConstituency' Constituency.";
            statusColor = Colors.red;
            // SnackbarUtils.showErrorMessage( context, "Application Status: $status");
          }
          else if
          (status == "Pending Approval")
          {
            message = "$status.\n\nAwait further notification.";
            statusColor = Colors.teal;
            // SnackbarUtils.showNeutralMessage( context, "Application Status: $status");
          }

          // Show the status in the dialog with appropriate color
          await _showStatusDialog(message, statusColor);
        }
        else
        { SnackbarUtils.showErrorMessage( context, "No application found for this election."); }
      }
    }
    catch (e)
    {
      print("Error fetching application status: $e");
      SnackbarUtils.showErrorMessage(context, "Failed to check the application status. Please try again.");
    }
  }

  Future<void> updateConstituencies() async
  {
    await AppConstants.loadConstituencies(selectedState!, selectedElectionType!, "Not_Want_'All_Constituencies'_as_option" );

    if (mounted)
    { // Check if the widget is still mounted before calling setState
      setState(() { selectedConstituency = AppConstants.constituencies.isNotEmpty  ? AppConstants.constituencies.first  : ''; });
      // setState(() { selectedConstituency = AppConstants.constituencies.first  ?? ''; });
    }
  }

  Future<void> _showStatusDialog(String message, Color statusColor) async {
    await showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false, // Prevent back button dismiss
          child: AlertDialog(
            title: Center(child: const Text("Application Status")),
            content: Card(
              // color: statusColor,
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(5.0), // 16
                child: Text(
                  message,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Dismiss the dialog
                },
                child: const Text("OK"),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Candidate Application & Status',
            style: TextStyle(
              fontSize: 20,                    // Font size for better visibility
              fontWeight: FontWeight.bold,     // Bold font for emphasis
              color: Colors.white,             // White color for better contrast
            ),
          ),
        ),
        backgroundColor: AppConstants.appBarColor,
        elevation: 4,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            // Tab(text: "Apply for Election"),
            // Tab(text: "Check Status"),
            Tab(
              icon: Row(
                children: [
                  Icon(Icons.app_registration),
                  SizedBox(width: 8),  // Space between the icon and the text
                  Text('As Candidate', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Tab(
              icon: Row(
                children: [
                  Icon(Icons.check_circle_outline),
                  SizedBox(width: 8),  // Space between the icon and the text
                  Text('Approval', style: TextStyle(fontWeight: FontWeight.bold)),    // Approval Status++
                ],
              ),
            ),
          ],
          // Custom TabBar styling
          indicatorColor: Colors.white, // Color of the indicator (line under selected tab)
          labelColor: Colors.white, // Color of the selected tab text
          unselectedLabelColor: AppConstants.secondaryColor, // Color of unselected tab text
          indicatorWeight: 5.0, // Thickness of the indicator
          indicatorPadding: EdgeInsets.symmetric(horizontal: 8), // Padding for indicator
          labelStyle: TextStyle( fontWeight: FontWeight.bold, fontSize: 19 ),
          unselectedLabelStyle: TextStyle( fontWeight: FontWeight.normal, fontSize: 19),

        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Apply for Election Tab
          SingleChildScrollView
          (
            padding: const EdgeInsets.all(16.0),
            child: Column
            (
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
              [
                buildDropdownField(
                  label: "Year",
                  items: AppConstants.electionYear,
                  selectedValue: selectedYear,
                  onChanged: (value) => setState(() => selectedYear = value),
                ),
                buildDropdownField(
                  label: "Election Type",
                  items: AppConstants.electionTypesForCandidate,
                  selectedValue: selectedElectionType,
                  onChanged: (value)
                  {
                    setState(()
                    {
                      selectedElectionType = value;
                      selectedState = null; // Reset state on election type change
                      selectedParty = null; // Reset party on election type change
                      selectedConstituency = null;
                    });
                  },
                ),
                StateDropdownField(
                  label: "State",
                  selectedState: selectedState,
                  // onChanged: (value) => setState(() => selectedState = value),
                  onChanged: (value)
                  {
                    setState(()
                    {
                      selectedState = value ?? '';
                      updateConstituencies(); // Update constituencies based on the new state
                      selectedParty = null; // Reset party on election type change
                    });
                  },
                  selectedElectionType: selectedElectionType,
                ),
                const SizedBox(height: 16),
                if
                (
                  selectedElectionType != "Presidential" && selectedElectionType != "Vice-Presidential" &&
                  selectedYear != null && selectedElectionType != null && selectedState != null
                )
                  FutureBuilder<List<String>>(
                    future: _getAuthorizedParties(), // Fetch parties asynchronously
                    builder: (context, snapshot)
                    {
                        final List<String> items = snapshot.data ?? [];
                        return partyDropdownField(
                          label: "Party",
                          items: items,
                          selectedValue: selectedParty,
                          enabled: selectedElectionType != null && selectedYear != null && selectedState != null,
                          onChanged: (value) => setState(() { selectedParty = value;  }),
                        );
                    },
                  ),
                const SizedBox(height: 0),
                if ( selectedElectionType != "Presidential" && selectedElectionType != "Vice-Presidential" )
                    buildDropdownField
                    (
                      label: "Constituency",
                      items: AppConstants.constituencies, // You can populate this with the relevant constituencies
                      selectedValue: selectedConstituency,
                      // onChanged: (value) => setState(() => selectedConstituency = value),
                      onChanged: (value) { setState(() { selectedConstituency = value ?? '';  }); },
                    ),
                // if
                // (
                //     selectedElectionType != "Presidential" && selectedElectionType != "Vice-Presidential" &&
                //     selectedYear != null && selectedElectionType != null && selectedState != null
                // )
                //     FutureBuilder<List<String>>(
                //       future: updateConstituencies(), // Fetch parties asynchronously
                //       builder: (context, snapshot)
                //       {
                //         return buildDropdownField
                //         (
                //           label: "Constituency",
                //           items: snapshot.data!,
                //           selectedValue: selectedConstituency,
                //           onChanged: (value) { setState(() { selectedConstituency = value ?? ''; });  },
                //         );
                //       },
                //     ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: "Candidate Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _ageController,
                  decoration: const InputDecoration(
                    labelText: "Age",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _genderController,
                  decoration: const InputDecoration(
                    labelText: "Gender",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _educationController,
                  decoration: const InputDecoration(
                    labelText: "Education",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _professionController,
                  decoration: const InputDecoration(
                    labelText: "Profession",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _CandidateHomeStateController,
                  decoration: const InputDecoration(
                    labelText: "Home State",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                // TextField(
                //   controller: _privateKeyMetaMaskController, // New input field
                //   obscureText: true, // Hide private key for security
                //   decoration: InputDecoration(labelText: 'MetaMask Private Key', border: OutlineInputBorder()),
                // ),
                TextField(
                  controller: _privateKeyMetaMaskController,
                  obscureText: true, // Hide private key for security
                  decoration: InputDecoration(
                    labelText: 'MetaMask Private Key (Optional)',
                    labelStyle: TextStyle(color: Colors.grey), // Optional text with gray color
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey), // Lighter border for optional field
                    ),
                    hintText: 'Can be leave empty..', // Optional hint text
                    hintStyle: TextStyle(color: Colors.grey), // Hint text in gray
                  ),
                ),
                const SizedBox(height: 20),
                  Center(
                    child: buildStyledButton(
                      text: "Submit Application",
                      onPressed: _applyForElection,
                      // color: Colors.blueAccent,
                      color: AppConstants.primaryColor,
                      icon: Icons.send,
                    ),
                  ),
               ],
            ),
          ),
          // Check Status Tab
          SingleChildScrollView
          (
            padding: const EdgeInsets.all(16.0),
            child: Column
            (
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
              [
                buildDropdownField(
                  label: "Year",
                  items: AppConstants.electionYear,
                  selectedValue: selectedYear,
                  onChanged: (value) => setState(() => selectedYear = value),
                ),
                buildDropdownField(
                  label: "Election Type",
                  items: AppConstants.electionTypesForCandidate,
                  selectedValue: selectedElectionType,
                  onChanged: (value) {
                    setState(() {
                      selectedElectionType = value;
                      selectedState = null; // Reset state on election type change
                      selectedParty = null; // Reset party on election type change
                      selectedConstituency = null;
                    });
                  },
                ),
                StateDropdownField(
                  label: "State",
                  selectedState: selectedState,
                  // onChanged: (value) => setState(() => selectedState = value),
                  onChanged: (value)
                  {
                    setState(()
                    {
                      selectedState = value ?? '';
                      updateConstituencies(); // Update constituencies based on the new state
                      selectedParty = null; // Reset party on election type change
                    });
                  },
                  selectedElectionType: selectedElectionType,
                ),
                const SizedBox(height: 16),
                if
                (
                  selectedElectionType != "Presidential" && selectedElectionType != "Vice-Presidential" &&
                  selectedYear != null && selectedElectionType != null && selectedState != null
                )
                  FutureBuilder<List<String>>(
                    future: _getAuthorizedParties(), // Fetch parties asynchronously
                    builder: (context, snapshot)
                    {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // Show a loading indicator while waiting for data
                        return CircularProgressIndicator();
                      }
                      else
                      {
                        final List<String> items = snapshot.data!;
                        return partyDropdownField(
                          label: "Party",
                          items: items,
                          selectedValue: selectedParty,
                          enabled: selectedElectionType != null && selectedYear != null && selectedState != null,
                          onChanged: (value) => setState(() { selectedParty = value ?? ''; } ),
                        );
                      }
                    },
                  ),
                const SizedBox(height: 0),
                if ( selectedElectionType != "Presidential" && selectedElectionType != "Vice-Presidential" )
                     buildDropdownField
                       (
                       label: "Constituency",
                       items: AppConstants.constituencies, // You can populate this with the relevant constituencies
                       selectedValue: selectedConstituency,
                       // onChanged: (value) => setState(() => selectedConstituency = value),
                       onChanged: (value) { setState(() { selectedConstituency = value ?? '';  }); },
                     ),
                const SizedBox(height: 16),
                // TextField(
                //   controller: _privateKeyMetaMaskController, // New input field
                //   obscureText: true, // Hide private key for security
                //   decoration: InputDecoration(labelText: 'MetaMask Private Key', border: OutlineInputBorder()),
                // ),
                TextField(
                  controller: _privateKeyMetaMaskController,
                  obscureText: true, // Hide private key for security
                  decoration: InputDecoration(
                    labelText: 'MetaMask Private Key...',
                    labelStyle: TextStyle(color: Colors.grey), // Optional text with gray color
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey), // Lighter border for optional field
                    ),
                    hintText: 'Can be leave empty..', // Optional hint text
                    hintStyle: TextStyle(color: Colors.grey), // Hint text in gray
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: buildStyledButton(
                    text: "Check Application Status",
                    onPressed: _checkApplicationStatus,
                    // color: Colors.blueAccent,
                    color: AppConstants.primaryColor,
                    icon: Icons.send,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
