
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../SERVICE/screen/styled_widget.dart';
import '../../SERVICE/utils/app_constants.dart';
import 'election_details.dart';
import 'package:mech_it/SERVICE/backend_connectivity/smart_contract_service.dart';

class ManagePartyApplication extends StatefulWidget {
  @override
  _ManagePartyApplicationState createState() => _ManagePartyApplicationState();
}

class _ManagePartyApplicationState extends State<ManagePartyApplication> {

  String? selectedYear;
  String? selectedElectionType;
  String? selectedState;
  bool isLoading = false; // Loading state variable
  List<Map<String, dynamic>> partyApplications = [];
  String electionActivityPath = "";
  Map<String, bool> loadingMap = {}; // Track loading state for each party


  @override
  void initState()
  {
    super.initState();
    selectedYear = ElectionDetails.instance.year;
    selectedElectionType = ElectionDetails.instance.electionType;
    selectedState = ElectionDetails.instance.state;

    // Set isLoading to true before fetching data
    setState(() {
      isLoading = true;
    });

    String basePath = buildBasePath(); // Generate basePath here
    if (basePath.isNotEmpty) {
      fetchApplications(basePath); // Pass the basePath to fetchApplications
    }
  }

  // Function to update a specific card's loading state
  void setLoadingState(String partyId, bool state) {
    setState(() {
      loadingMap[partyId] = state;
    });
    print("Loading state for $partyId: $state"); // Debugging
  }

  String buildBasePath()
  {
    var electionDetails = ElectionDetails.instance;

    if
    ( electionDetails.electionType == "General (Lok Sabha)" || electionDetails.electionType == "Council of States (Rajya Sabha)")
    {
      electionActivityPath = "Vote Chain/Election/${electionDetails.year}/${electionDetails.electionType}/State/${electionDetails.state}/Admin/Election Activity";
      return "Vote Chain/Election/${electionDetails.year}/${electionDetails.electionType}/State/${electionDetails.state}/Party_Candidate";
    }
    else if
    (
      electionDetails.electionType == "State Assembly (Vidhan Sabha)" || electionDetails.electionType == "Legislary Council (Vidhan Parishad)" ||
      electionDetails.electionType == "Municipal" || electionDetails.electionType == "Panchayat"
    )
    {
      electionActivityPath = "Vote Chain/State/${electionDetails.state}/Election/${electionDetails.year}/${electionDetails.electionType}/Admin/Election Activity";
      return "Vote Chain/State/${electionDetails.state}/Election/${electionDetails.year}/${electionDetails.electionType}/Party_Candidate";
    }
    else if
    (electionDetails.electionType == "Presidential" || electionDetails.electionType == "Vice-Presidential")
    {
      if (electionDetails.state == "_PAN India")
      {
        electionActivityPath = "Vote Chain/Election/${electionDetails.year}/Special Electoral Commission/${electionDetails.electionType}/Admin/Election Activity";
        return "Vote Chain/Election/${electionDetails.year}/Special Electoral Commission/${electionDetails.electionType}/Party_Candidate";
      }
      else
      { return ''; }
    }
    else { return ''; }
  }

  Future<void> fetchApplications(String basePath) async
  {
    try
    {
      // Check the current election stage
      DocumentSnapshot electionActivity = await FirebaseFirestore.instance.doc('$electionActivityPath').get();

      if (!electionActivity.exists)
      {
        setState(() { isLoading = false; });
        SnackbarUtils.showErrorMessage(context, "Election has not been created yet."); return;
      }         // If election does not exist (created)

      int currentStage = (electionActivity['currentStage'] ?? 1).toInt();
      // bool isStageStopped = electionActivity['stage1Completed'] ?? false;  // Assuming stage1Completed indicates if stage 1 is stopped or completed



      /// ******************    **********    *******   ***   *             ******************    **********    *******   ***   *    Can comment-out below fun to not use solidity fun          ******************    **********    *******   ***   *             ******************    **********    *******   ***   *
      /// ******************    **********    *******   ***   *             ******************    **********    *******   ***   *    Can comment-out below fun to not use solidity fun          ******************    **********    *******   ***   *             ******************    **********    *******   ***   *

      // String electionStatus = await SmartContractService().checkElectionStatus(selectedYear!, selectedElectionType!, selectedState!);
      // String partyApplication = await SmartContractService().checkPartyApplicationStatus(selectedYear!, selectedElectionType!, selectedState!);

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
          // && electionStatus == 'NOT_STARTED'
      )
      {
          setState(() { isLoading = false; });
          SnackbarUtils.showErrorMessage(context, "Party registration phase isn't started yet."); return;
      }         // If Stage 1 has not started
      else if
      (
          currentStage == 3
          // && electionStatus == 'STARTED'
          // && partyApplication == 'STARTED'
      )
      {
          setState(() { isLoading = false; });
          SnackbarUtils.showErrorMessage(context, "Party registration phase is on.\nAfter this phase ends you can verify & approve Parties' applications."); return;
      }
      else if
      (
          currentStage >= 4                                  // If Stage 1 is completed (stopped)
          // && electionStatus == 'STARTED'
          // && partyApplication == 'STOPPED'
      )
      {
        print("Fetching data from: $basePath");

        // Fetch all party documents under the Party_Candidate collection
        QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(basePath).get();

        if (snapshot.docs.isEmpty)
        {
          print("No party applications found at: $basePath");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No applications found.')),);
          setState(() {
            isLoading = false;
          }); // Set loading to false when data is fetched
          return;
        }

        // Map each document to a list of applications, including the home_state
        setState(() {
          partyApplications = snapshot.docs
              .map((doc) =>
          {
            'id': doc.id,
            ...doc.data() as Map<String, dynamic>,
            'home_state': doc['home_state'],  // Fetch the home_state field
          })
              .toList();
          isLoading = false; // Set loading to false when data is fetched
        });

        print("Fetched applications: $partyApplications");
      }
      // else if (currentStage >= 5)
      // { SnackbarUtils.showErrorMessage(context, "Party verification & approval phase is stopped."); return; }
    }
    catch (e)
    {
      print("Error fetching applications: $e");
      SnackbarUtils.showErrorMessage(context,"Failed to fetch parties' applications." );
      setState(() { isLoading = false; }); // Set loading to false in case of error
    }
  }

  Future<Map<String, dynamic>?> fetchPartyDetails(String homeState, String state, String partyName) async
  {
    try
    {
      // Check the current election stage
      DocumentSnapshot electionActivity = await FirebaseFirestore.instance.doc('$electionActivityPath').get();

      if (!electionActivity.exists)
      {
        setState(() { isLoading = false; });
        SnackbarUtils.showErrorMessage(context, "Election has not been created yet."); return null;
      }         // If election does not exist (created)

      int currentStage = (electionActivity['currentStage'] ?? 1).toInt();
      // bool isStageStopped = electionActivity['stage1Completed'] ?? false;  // Assuming stage1Completed indicates if stage 1 is stopped or completed



      /// ******************    **********    *******   ***   *             ******************    **********    *******   ***   *    Can comment-out below fun to not use solidity fun          ******************    **********    *******   ***   *             ******************    **********    *******   ***   *
      /// ******************    **********    *******   ***   *             ******************    **********    *******   ***   *    Can comment-out below fun to not use solidity fun          ******************    **********    *******   ***   *             ******************    **********    *******   ***   *

      // String electionStatus = await SmartContractService().checkElectionStatus(selectedYear!, selectedElectionType!, selectedState!);
      // String partyApplication = await SmartContractService().checkPartyApplicationStatus(selectedYear!, selectedElectionType!, selectedState!);

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
        // && electionStatus == 'NOT_STARTED'
      )
      {
        setState(() { isLoading = false; });
        SnackbarUtils.showErrorMessage(context, "Party registration phase isn't started yet."); return null;
      }         // If Stage 1 has not started
      else if
      (
        currentStage == 3
        // && electionStatus == 'STARTED'
        // && partyApplication == 'STARTED'
      )
      {
        setState(() { isLoading = false; });
        SnackbarUtils.showErrorMessage(context, "Party registration phase is on.\nAfter this phase ends you can verify & approve Parties' applications."); return null;
      }
      else if
      (
        currentStage >= 4                                  // If Stage 1 is completed (stopped)
        // && electionStatus == 'STARTED'
        // && partyApplication == 'STOPPED'
      )
      {
        if (homeState.isEmpty  || state.isEmpty || partyName.isEmpty)
        {
          print('\n\n\n ****************** \nFetching party details for state: $state, partyName: $partyName');
          return null;
        }

        // Construct the path to fetch the party details

        // String path = 'Vote Chain/Party/$selectedState/$partyName/Party Info/Details/';  // also works @ direct by basis of admin's selected state
        // String path = 'Vote Chain/Party/$state/$partyName/Party Info/Details/';
        String path = 'Vote Chain/Party/$homeState/$partyName/Party Info/Details/';

        // print('1111111111111 Fetching party details for state: $path');

        DocumentSnapshot snapshot = await FirebaseFirestore.instance.doc(path)
            .get();

        // If data exists, return the details
        if (snapshot.exists)
        { return snapshot.data() as Map<String, dynamic>; }
        else
        { return null; } // No data found for this party
      }
      // else if (currentStage >= 5)
      // { SnackbarUtils.showErrorMessage(context, "Party verification & approval phase is stopped."); return null; }
    }
    catch (e)
    {
      print("Error fetching parties' details: $e");
      SnackbarUtils.showErrorMessage(context,"Failed to fetch parties' details.");
      return null; // Return null if there's an error
    }
  }

  Future<void> acceptParty(String applicationId) async
  {
    setLoadingState(applicationId, true);
    try
    {
      String basePath = buildBasePath();
      if (basePath.isEmpty)
      {
        setState(() { isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Invalid election type or state.')),); return;
      }

      // Fetch the current election stage to ensure party registration phase is still open
      DocumentSnapshot electionActivity = await FirebaseFirestore.instance.doc('$electionActivityPath').get();
      if (!electionActivity.exists)
      {
        setState(() { isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Election has not been created yet.'))); return;
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
      { SnackbarUtils.showErrorMessage(context, "Election isn't started yet."); return null; }         // If Stage 1 has not started
      else if
      (
        currentStage == 2
        // && electionStatus == 'NOT_STARTED'
      )
      {
        setState(() { isLoading = false; });
        SnackbarUtils.showErrorMessage(context, "Party registration phase isn't started yet."); return;
      }         // If Stage 1 has not started
      else if
      (
        currentStage == 3
        // && electionStatus == 'STARTED'
        // && partyApplication == 'STARTED'
      )
      {
        setState(() { isLoading = false; });
        SnackbarUtils.showErrorMessage(context, "Party registration phase is on.\nAfter this phase ends you can verify & approve Parties' applications."); return;
      }
      else if
      (
        currentStage == 4                                  // If Stage 1 is completed (stopped)
        // && electionStatus == 'STARTED'
        // && partyApplication == 'STOPPED'
        // && candidateApplication == 'NOT_STARTED'
      )
      {
        // Update application status to 'Accepted'
        await FirebaseFirestore.instance.collection(basePath).doc(applicationId).update({ 'status': 'Accepted', 'isPartyApproved': 'YES',});
        // SnackbarUtils.showSuccessMessage( context, 'Application accepted successfully!');

        // Refresh the applications list
        fetchApplications(basePath); // Pass basePath here
        // setLoadingState(applicationId, false);
      }
      else if
      (
        currentStage >= 5
        // && electionStatus == 'STARTED'
        // && partyApplication == 'STOPPED'
        // && candidateApplication == 'STARTED'
      )
      {
        setState(() { isLoading = false; });
        SnackbarUtils.showErrorMessage(context, "Party verification & approval phase is stopped."); return;
      }
    }
    catch (e)
    {
      print("Error accepting application: $e");
      ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Failed to accept the application.')),);
    }
    finally
    {
      // setLoadingState(applicationId, false);
    }
  }

  Future<void> rejectParty(String applicationId) async
  {
    setLoadingState(applicationId, true);
    try
    {
      String basePath = buildBasePath();
      if (basePath.isEmpty)
      {
        setState(() { isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Invalid election type or state.')),); return;
      }

      // Fetch the current election stage to ensure party registration phase is still open
      DocumentSnapshot electionActivity = await FirebaseFirestore.instance.doc('$electionActivityPath').get();
      if (!electionActivity.exists)
      {
        setState(() { isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Election has not been created yet.'))); return;
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
      { SnackbarUtils.showErrorMessage(context, "Election isn't started yet."); return null; }         // If Stage 1 has not started
      else if
      (
        currentStage == 2
        // && electionStatus == 'NOT_STARTED'
      )
      {
        setState(() { isLoading = false; });
        SnackbarUtils.showErrorMessage(context, "Party registration phase isn't started yet."); return;
      }         // If Stage 1 has not started
      else if
      (
        currentStage == 3
        // && electionStatus == 'STARTED'
        // && partyApplication == 'STARTED'
      )
      {
        setState(() { isLoading = false; });
        SnackbarUtils.showErrorMessage(context, "Party registration phase is on.\nAfter this phase ends you can verify & approve Party-Head applications."); return;
      }
      else if
      (
          currentStage == 4                                  // If Stage 1 is completed (stopped)
          // && electionStatus == 'STARTED'
          // && partyApplication == 'STOPPED'
          // && candidateApplication == 'NOT_STARTED'
      )
      {
        await FirebaseFirestore.instance.collection(basePath).doc(applicationId).update({ 'status': 'Rejected', 'isPartyApproved': 'NO',});
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Application rejected successfully!')),);

        // Refresh the applications list
        fetchApplications(basePath); // Pass basePath here
        // setLoadingState(applicationId, false);

      }
      else if
      (
        currentStage >= 5
        // && electionStatus == 'STARTED'
        // && partyApplication == 'STOPPED'
        // && candidateApplication == 'STOPPED'
      )
      {
        setState(() { isLoading = false; });
        SnackbarUtils.showErrorMessage(context, "Party verification & approval phase is stopped."); return;
      }
    }
    catch (e)
    {
      print("Error rejecting application: $e");
      ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Failed to reject the application.')),);
    }
    finally
    {
      // setLoadingState(applicationId, false);
    }
  }

  // Widget buildPartyApplicationCard(Map<String, dynamic> application) {
  //   return Card(
  //     margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(12),
  //     ),
  //     elevation: 4,
  //     color: application['status'] == 'Accepted'
  //         ? Colors.teal.shade50
  //         : Colors.white, // Highlight Accepted status
  //     child: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Row(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Column(
  //             children: [
  //               Container(
  //                 width: 80,
  //                 height: 80,
  //                 decoration: BoxDecoration(
  //                   image: DecorationImage(
  //                     image: AssetImage('assets/images/default_photo.png'), // Placeholder logo
  //                     fit: BoxFit.cover,
  //                   ),
  //                   borderRadius: BorderRadius.circular(8),
  //                 ),
  //               ),
  //               const SizedBox(height: 12),
  //               // Status or Action Buttons
  //               if (application['status'] == 'Accepted')
  //                 Container(
  //                   padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
  //                   decoration: BoxDecoration(
  //                     gradient: LinearGradient(
  //                       colors: [Colors.teal.shade300, Colors.teal.shade700],
  //                       begin: Alignment.topLeft,
  //                       end: Alignment.bottomRight,
  //                     ),
  //                     borderRadius: BorderRadius.circular(12),
  //                     boxShadow: [
  //                       BoxShadow(
  //                         color: Colors.black.withOpacity(0.15),
  //                         offset: Offset(0, 2),
  //                         blurRadius: 4,
  //                       ),
  //                     ],
  //                   ),
  //                   child: const Text(
  //                     'Accepted',
  //                     style: TextStyle(
  //                       color: Colors.white,
  //                       fontWeight: FontWeight.w600,
  //                       fontSize: 14,
  //                     ),
  //                   ),
  //                 )
  //               else ...[
  //                 IconButton(
  //                   icon: Icon(Icons.check, color: Colors.green),
  //                   onPressed: () => acceptParty(application['id']),
  //                   iconSize: 28,
  //                 ),
  //                 const SizedBox(height: 8),
  //               ],
  //               // Always show the reject button
  //               IconButton(
  //                 icon: Icon(Icons.close, color: Colors.red),
  //                 onPressed: () => rejectParty(application['id']),
  //                 iconSize: 28,
  //               ),
  //             ],
  //           ),
  //           const SizedBox(width: 16),
  //           // Party Details
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 // Party Name
  //                 Text(
  //                   application['partyName'] ?? 'Unknown Party',
  //                   style: const TextStyle(
  //                     fontSize: 22,
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.black87,
  //                   ),
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //                 const SizedBox(height: 8),
  //                 // Party Symbol
  //                 Text(
  //                   'Symbol: ${application['symbol']}',
  //                   style: TextStyle(
  //                     fontSize: 14,
  //                     color: Colors.grey[700],
  //                   ),
  //                 ),
  //                 const SizedBox(height: 8),
  //                 // Party Members
  //                 Text(
  //                   'Members: ${application['members']}',
  //                   style: TextStyle(
  //                     fontSize: 14,
  //                     color: Colors.grey[700],
  //                   ),
  //                 ),
  //                 const SizedBox(height: 8),
  //                 // Application Status
  //                 Row(
  //                   children: [
  //                     const Text(
  //                       'Status:',
  //                       style: TextStyle(
  //                         fontSize: 14,
  //                         fontWeight: FontWeight.bold,
  //                         color: Colors.black87,
  //                       ),
  //                     ),
  //                     const SizedBox(width: 8),
  //                     Text(
  //                       application['status'] ?? 'Pending',
  //                       style: TextStyle(
  //                         fontSize: 14,
  //                         color: application['status'] == 'Accepted'
  //                             ? Colors.green
  //                             : Colors.red,
  //                         fontWeight: FontWeight.w500,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 8),
  //                 // Additional Details Section
  //                 const Divider(),
  //                 const Text(
  //                   'Additional Info:',
  //                   style: TextStyle(
  //                     fontSize: 16,
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.black87,
  //                   ),
  //                 ),
  //                 const SizedBox(height: 4),
  //                 Text(
  //                   'ID: ${application['id'] ?? 'Not available'}',
  //                   style: TextStyle(
  //                     fontSize: 14,
  //                     color: Colors.grey[700],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  Widget buildPartyApplicationCard(Map<String, dynamic> application) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: fetchPartyDetails(application['home_state'], ElectionDetails.instance.state ?? '', application['partyName'] ?? ''),
      builder: (context, snapshot)
      {

        // if (snapshot.hasError) {
        //   return Card(
        //     margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(12),
        //     ),
        //     elevation: 4,
        //     child: Padding(
        //       padding: const EdgeInsets.all(16.0),
        //       child: Center(child: Text("Error loading party details.")),
        //     ),
        //   );
        // }

        // If party details are fetched successfully, show them
        Map<String, dynamic>? partyDetails = snapshot.data;
        print("Fetching party details for card view..: $partyDetails");

        String partyId = application['id'];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          // Setting the color based on the status
          color: application['status'] == 'Accepted'
              ? Colors.teal.shade50 // Highlight Accepted status
              : application['status'] == 'Rejected'
                ? Colors.deepOrange.shade50 // Highlight Rejected status
                : Colors.white, // Default to white if status is neither Accepted nor Rejected

          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/default_party_logo.png'),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Status or Action Buttons

                    // Display CircularProgressIndicator if isLoading is true
                    if (loadingMap[application['id']] == true)
                      CircularProgressIndicator(),

                    if (application['status'] == 'Rejected') ...[
                          Container(
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.deepOrange.shade300, Colors.deepOrange.shade700],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                // color: Colors.black.withOpacity(0.15),
                                color: Colors.deepOrange.shade300.withOpacity(0.15),
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
                              onPressed: ()
                              async {
                                setLoadingState(partyId, true); // Start loading
                                await acceptParty(application['id']);
                                setLoadingState(application['id'], false);
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
                              colors: [ Colors.teal.shade300,Colors.teal.shade700 ],
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
                          onPressed: ()
                          async {
                            setLoadingState(partyId, true); // Start loading
                            await rejectParty(application['id']);
                            setLoadingState(application['id'], false);
                          },
                          iconSize: 28,
                        ),
                    ],
                    if (application['status'] != 'Rejected' && application['status'] != 'Accepted') ...[
                        // Always show the accept & reject button
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: ()
                          async {
                            setLoadingState(partyId, true); // Start loading

                            await acceptParty(application['id']);
                            // acceptParty(application['id']);
                            // await Future.delayed(Duration(seconds: 2));            // Add a delay of 2 seconds before setting the loading state to false

                            setLoadingState(application['id'], false);
                          },
                          iconSize: 28,
                        ),
                        const SizedBox(height: 8),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.red),
                          onPressed: ()
                          async {
                            setLoadingState(partyId, true); // Start loading
                            await rejectParty(application['id']);
                            setLoadingState(application['id'], false);
                          },
                          iconSize: 28,
                        ),
                    ],

                  ],
                ),
                const SizedBox(width: 16),
                // Party Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Party Name
                      Text(
                        application['partyName'] ?? 'Unknown Party',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Party Head:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      partyDetails != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Email: ${partyDetails['email'] ?? 'Not Available'}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Name: ${partyDetails['name'] ?? 'Not Available'}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Phone: ${partyDetails['phone'] ?? 'Not Available'}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 2),
                              ],
                            )

                          : const Text(
                            'Party details not available.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                             ),
                      const Divider(),
                      // Additional Party Details
                      const Text(
                        'Other Info:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Party Symbol
                      Text(
                        'Symbol: ${application['symbol'] ?? 'Unknown'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Party Members
                      Text(
                        'Members: ${application['members'] ?? 'Unknown'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
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
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.appBarColor,
        title: Center(
          child: Text(
            'Manage Party Applications', // Update title text as needed
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        elevation: 6,
        // automaticallyImplyLeading: false,
      ),

      body: isLoading // Show loading indicator if isLoading is true
          ? Center( child: CircularProgressIndicator(), )
          : partyApplications.isEmpty
          ? Center(  child: Text('No applications to display.'), )
          : ListView.builder(
              itemCount: partyApplications.length,
              itemBuilder: (context, index) {
                final application = partyApplications[index];
                return buildPartyApplicationCard(application);
              },
            ),
    );
  }
}
