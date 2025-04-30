

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mech_it/SERVICE/screen/styled_widget.dart';
import 'package:mech_it/USER/citizen/vote_candidate_list.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../SERVICE/utils/app_constants.dart';
import 'dart:async';


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
  String electionYear = AppConstants.getCurrentYear();
  bool _isLoading = true;  // ✅ Loading state

  @override
  void initState() {
    super.initState();

    _fetchElections();

    // // Fetch both state-level and national-level elections when the screen opens
    // _fetchStateLevelElections(widget.state, electionYear);    // For state level
    // _fetchNationalLevelElections(widget.state, electionYear);  // For national level
  }


  /// 🔥 Fetch both state and national elections
  Future<void> _fetchElections() async {
    setState(() => _isLoading = true);  // Start loading

    // Fetch both state-level and national-level elections when the screen opens
    await _fetchStateLevelElections(widget.state, electionYear);
    await _fetchNationalLevelElections(widget.state, electionYear);
    setState(() => _isLoading = false);  // Stop loading
  }


  /// Fetch eligible state-level elections based on currentStage >= 4
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

    for (var electionDoc in yearSnapshot.docs)
    {
      var electionActivityDoc = await electionDoc.reference
          .collection("Admin")
          .doc("Election Activity")
          .get();
      var currentStage = electionActivityDoc?['currentStage'];
      print("111 --- $currentStage") ;


      if (electionActivityDoc.exists)
      {
        var data = electionActivityDoc.data() as Map<String, dynamic>?;
        var currentStage = data?['currentStage'];

        if (currentStage != null)
        {
          var parsedStage = int.tryParse(currentStage.toString());
          if
          (currentStage <= 6)
          {
            print("$currentStage") ;
            // // SnackbarUtils.showErrorMessage(context, "Voting is not started yet.");
          }
          else if
          (currentStage == 7)
          { eligibleElections.add(electionDoc); } // Add election if eligible
          else if
          (currentStage >= 8)
          {
            // // SnackbarUtils.showErrorMessage(context, "Voting is stopped.");
          }
          else
          { print("Election ${electionDoc.id} currentStage: $currentStage (not eligible)"); }
        }
      }
    }

    /*
      It stops further execution if you switch tabs or navigate away
      When you use if (!mounted) return;, it prevents further execution of the code if the widget is no longer part of the widget tree (disposed).
      Prevents UI updates on disposed widgets and avoids crashes when switching tabs or navigating away.
    */
    if (!mounted) return;  // ✅ Check if the widget is still mounted & Stop execution if widget is disposed


    setState(()
    { _eligibleStateElections = eligibleElections; });   // Update the list of eligible state elections

    print("Eligible state elections: ${_eligibleStateElections.length}");
  }


  /// Fetch eligible national-level elections based on currentStage >= 4
  Future<void> _fetchNationalLevelElections(String state, String currentYear) async {
    print("Fetching national elections for year: $currentYear");

    var yearSnapshot = await _firestore
        .collection("Vote Chain")
        .doc("Election")
        .collection(currentYear) // Use the current year directly
        .get();

    var eligibleElections = <DocumentSnapshot>[];

    for (var electionDoc in yearSnapshot.docs) {
      var electionActivityDoc = await electionDoc.reference
          .collection("State")
          .doc(state)
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
          {
            // // SnackbarUtils.showErrorMessage(context, "Voting is not started yet.");
          }
          else if
          (parsedStage != null && parsedStage == 7)
          { eligibleElections.add(electionDoc); } // Add election if eligible
          else if
          (parsedStage != null && parsedStage >= 8)
          {
            // // SnackbarUtils.showErrorMessage(context, "Voting is stopped.");
          }
          else
          { print("Election ${electionDoc.id} currentStage: $currentStage (not eligible)"); }
        }
      }
    }

    if (!mounted) return;  // ✅ Check if the widget is still mounted & Stop execution if widget is disposed

    setState(() {
      _eligibleNationalElections = eligibleElections; // Update the list of eligible national elections
    });

    print("Eligible national elections: ${_eligibleNationalElections.length}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppConstants.secondaryColor.withOpacity(0.1),
      appBar: AppBar(
        title: Center(
          child: Text(
            'VOTE',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: AppConstants.appBarColor,
        // elevation: 4,
        automaticallyImplyLeading: false,
        actions: [
          LogoutButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/Login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0), // Add padding around the body
        child:
              _isLoading
              ? const Center(child: CircularProgressIndicator())  // ✅ Show loader while fetching
              : // here direct code was as "ListView(.........)," but temp below code added to display message
                (_eligibleStateElections.isEmpty && _eligibleNationalElections.isEmpty)
                ? const Center(
                    child: Text(
                      "No election/s available for voting at this time.",
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                )
                :  ListView(
                   children: [
                      // Display state elections
                      if (_eligibleStateElections.isNotEmpty)
                        ..._eligibleStateElections.map((election) {
                          var data = election.data() as Map<String, dynamic>?;
                          // var currentStage = data?['currentStage'];
                          // String currentStageDisplay = currentStage != null ? currentStage.toString() : "Not available";
                          String electionType = '';

                          /// original one
                          // return Card(
                          //   elevation: 4, // Add shadow for a better card appearance
                          //   margin: EdgeInsets.symmetric(vertical: 8), // Add vertical margin between cards
                          //   shape: RoundedRectangleBorder(
                          //     borderRadius: BorderRadius.circular(12), // Rounded corners for card
                          //   ),
                          //   child: ListTile(
                          //     contentPadding: EdgeInsets.all(16), // Padding inside each card
                          //     title: Text(
                          //       "State Election: ${election.id}",
                          //       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Bold title
                          //     ),
                          //     subtitle: Column(
                          //       crossAxisAlignment: CrossAxisAlignment.start,
                          //       children: [
                          //         SizedBox(height: 4),
                          //         Text("Current Stage: $currentStageDisplay", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                          //         SizedBox(height: 8),
                          //         Text("Election Year: 2024", style: TextStyle(fontSize: 14, color: Colors.blue)),
                          //       ],
                          //     ),
                          //     leading: Icon(Icons.poll, color: Colors.blue, size: 30), // Add an icon for better visuals
                          //       onTap: ()
                          //       {
                          //         String electionType = '';
                          //
                          //         // Determine whether the election is state or national
                          //         if
                          //         (_eligibleStateElections.any((e) => e.id == election.id))
                          //         { electionType = "State"; }
                          //         else if
                          //         (_eligibleNationalElections.any((e) => e.id == election.id))
                          //         { electionType = "National"; }
                          //         else
                          //         { print("Error: Election not found in state or national lists!");  return;  }
                          //
                          //         // Now, we can pass the correct election ID and type
                          //         String electionPath = (electionType == "State")
                          //             ? "Vote Chain/State/${widget.state}/Election/2024/${election.id}"
                          //             : "Vote Chain/Election/2024/${election.id}/State/${widget.state}";
                          //
                          //         // Navigate to the candidate list page, passing election type and ID
                          //         Navigator.push(
                          //           context,
                          //           MaterialPageRoute( builder: (context) => VoteCandidateList
                          //             (
                          //             state: widget.state,
                          //             userEmail: widget.email,
                          //             electionId: election.id,  // Pass the election ID
                          //             electionPath: electionPath, // Pass the election type
                          //             electionType: electionType
                          //           ),
                          //           ),
                          //         );
                          //       }
                          //   ),
                          // );
                          /// updated one
                          // return Padding(
                          //   padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 8),
                          //   child: Card(
                          //     elevation: 10, // Higher elevation for a more impactful shadow
                          //     margin: EdgeInsets.symmetric(vertical: 10), // Increased margin for better spacing
                          //     shape: RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.circular(15), // Rounded corners for a more polished look
                          //     ),
                          //     child: InkWell(
                          //       onTap: () {
                          //         String electionType = '';
                          //
                          //         // Determine whether the election is state or national
                          //         if (_eligibleStateElections.any((e) => e.id == election.id)) {
                          //           electionType = "State";
                          //         } else if (_eligibleNationalElections.any((e) => e.id == election.id)) {
                          //           electionType = "National";
                          //         } else {
                          //           print("Error: Election not found in state or national lists!");
                          //           return;
                          //         }
                          //
                          //         // Construct election path for navigation
                          //         String electionPath = (electionType == "State")
                          //             ? "Vote Chain/State/${widget.state}/Election/2024/${election.id}"
                          //             : "Vote Chain/Election/2024/${election.id}/State/${widget.state}";
                          //
                          //         // Navigate to the candidate list page, passing election type and ID
                          //         Navigator.push(
                          //           context,
                          //           MaterialPageRoute(
                          //             builder: (context) => VoteCandidateList(
                          //               state: widget.state,
                          //               userEmail: widget.email,
                          //               electionId: election.id, // Pass the election ID
                          //               electionPath: electionPath, // Pass the election type
                          //               electionType: electionType,
                          //             ),
                          //           ),
                          //         );
                          //       },
                          //       child: Container(
                          //         decoration: BoxDecoration(
                          //           // color: Colors.white, // Keep the card background white for a clean look
                          //           color:  Colors.purpleAccent[80],
                          //           borderRadius: BorderRadius.circular(16), // Rounded corners for smooth edges
                          //           boxShadow: [
                          //             BoxShadow(
                          //               color: Colors.grey.withOpacity(0.1), // Subtle shadow for depth
                          //               blurRadius: 6, // Soft shadow to give a floating effect
                          //               offset: Offset(0, 2), // Slight shadow offset for realism
                          //             ),
                          //           ],
                          //         ),
                          //         child: ListTile(
                          //           contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 20), // Balanced padding for content
                          //           title: Text(
                          //             "Election:\n${election.id}",
                          //             style: TextStyle(
                          //               fontSize: 18, // Slightly smaller for clean readability
                          //               fontWeight: FontWeight.w800, // Subtle bold for emphasis
                          //               color: Colors.black87, // Dark color for clear visibility
                          //             ),
                          //           ),
                          //           subtitle: Column(
                          //             crossAxisAlignment: CrossAxisAlignment.start,
                          //             children: [
                          //               SizedBox(height: 6),
                          //               Text(
                          //                 "State: ${widget.state}",
                          //                 style: TextStyle(
                          //                   fontSize: 16,
                          //                   fontWeight: FontWeight.w700, // Subtle bold for emphasis
                          //                   color: Colors.black87, // Dark color for clear visibility
                          //                   // color: Colors.grey[600], // Soft grey for a neutral tone
                          //                 ),
                          //               ),
                          //               SizedBox(height: 10),
                          //               Text(
                          //                 "Year: 2024",
                          //                 style: TextStyle(
                          //                   fontSize: 16,
                          //                   fontWeight: FontWeight.w700, // Subtle bold for emphasis
                          //                   color: Colors.black87, // Dark color for clear visibility
                          //                   // color: Colors.blue, // Slight color emphasis on the year
                          //                 ),
                          //               ),
                          //               // SizedBox(height: 6),
                          //               // Text(
                          //               //   "Current Stage: $currentStageDisplay",
                          //               //   style: TextStyle(
                          //               //     fontSize: 16,
                          //               //     fontWeight: FontWeight.w700, // Subtle bold for emphasis
                          //               //     color: Colors.black87, // Dark color for clear visibility
                          //               //     // color: Colors.grey[600], // Soft grey for a neutral tone
                          //               //   ),
                          //               // ),
                          //             ],
                          //           ),
                          //           leading: Icon(
                          //             Icons.how_to_vote, // Relevant icon
                          //             color: Colors.blue, // Matching the text color for consistency
                          //             size: 32, // Adjusted size for prominence without overpowering
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          // );
                          /// trying...
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 10), // More padding
                            child: Card(
                              elevation: 16, // Stronger depth effect
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22), // Smoother corners
                              ),
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: InkWell(
                                onTap: () {
                                  // Determine election type
                                  if (_eligibleStateElections.any((e) => e.id == election.id)) {
                                    electionType = "State";
                                  }
                                  // else if (_eligibleNationalElections.any((e) => e.id == election.id)) {
                                  //   electionType = "National";
                                  // }
                                  else {
                                    print("Error: Election not found in state or national lists!");
                                    return;
                                  }

                                  String electionYear = AppConstants.getCurrentYear();
                                  String electionPath =
                                  // (electionType == "State")
                                  //     ?
                                  "Vote Chain/State/${widget.state}/Election/$electionYear/${election.id}"  ;
                                  //     : "Vote Chain/Election/$electionYear/${election.id}/State/${widget.state}";

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VoteCandidateList(
                                        state: widget.state,
                                        userEmail: widget.email,
                                        electionId: election.id,
                                        electionPath: electionPath,
                                        electionType: electionType,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.teal, Colors.grey.shade100],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(22),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08), // Softer, premium shadow
                                        blurRadius: 14,
                                        offset: Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 24, horizontal: 26), // More space
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // ICON AT THE TOP
                                      Container(
                                        decoration: BoxDecoration(
                                          // color: Colors.blueAccent.shade700,
                                          // color: Color(2962FFFF),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              // color: Colors.blueAccent.withOpacity(0.35),
                                              color: Color(0xFFC5965E).withOpacity(0.45),
                                              blurRadius: 12,
                                              offset: Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        padding: EdgeInsets.all(14),
                                        /// icon
                                        // child: Icon(
                                        //   Icons.how_to_vote,
                                        //   color: Colors.white,
                                        //   size: 44, // Bigger for better visibility
                                        // ),
                                        /// image
                                        // child: Image.asset(
                                        //   'assets/images/election.jpg',
                                        //   // width: 44, // Adjust size as needed
                                        //   // height: 44,
                                        //   fit: BoxFit.cover, // Ensures proper scaling
                                        // ),
                                        /// smooth image
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(30), // Makes the image circular
                                          child: Image.asset(
                                            'assets/images/election.jpg',
                                            // width: 44, // Adjust size as needed
                                            // height: 44,
                                            fit: BoxFit.cover, // Ensures proper scaling
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 16), // Space between icon and text

                                      // ELECTION DETAILS BELOW
                                      // Text(
                                      //   "Election: ${election.id}",
                                      //   style: TextStyle(
                                      //     fontSize: 18, // Bigger title
                                      //     fontWeight: FontWeight.bold,
                                      //     color: Colors.black87,
                                      //   ),
                                      // ),
                                      Center(
                                        child: Text(
                                          "Election: ${election.id}",
                                          style: TextStyle(
                                            fontSize: 18, // Bigger title
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis, // Ensures the text doesn't break into a new line
                                          maxLines: 1, // Ensures only one line is used
                                        ),
                                      ),
                                      SizedBox(height: 8), // More vertical spacing
                                      Center(
                                        child: Text(
                                          "State: ${widget.state}",
                                          style: TextStyle(
                                            fontSize: 17,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis, // Ensures the text doesn't break into a new line
                                          maxLines: 1, // Ensures only one line is used
                                        ),
                                      ),
                                      SizedBox(height: 6),
                                      Center(
                                        child: Text(
                                          // "Year: 2024",
                                          "Year: $electionYear",
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis, // Ensures the text doesn't break into a new line
                                          maxLines: 1, // Ensures only one line is used
                                        ),
                                      ),
                                      SizedBox(height: 10), // More spacing

                                      // ARROW INDICATING NAVIGATION
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.grey.shade600,
                                        size: 24, // Bigger arrow for better UI balance
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );

                        }).toList(),

                      /// Display national elections
                      // Below is old code not w.r.t. final state election fun code
                      // if (_eligibleNationalElections.isNotEmpty)
                      //    ..._eligibleNationalElections.map((election) {
                      //     var data = election.data() as Map<String, dynamic>?;
                      //     var currentStage = data?['currentStage'];
                      //     String currentStageDisplay = currentStage != null ? currentStage.toString() : "Not available";
                      //
                      //     return Card(
                      //       elevation: 4, // Add shadow for a better card appearance
                      //       margin: EdgeInsets.symmetric(vertical: 8), // Add vertical margin between cards
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(12), // Rounded corners for card
                      //       ),
                      //       child: ListTile(
                      //         contentPadding: EdgeInsets.all(16), // Padding inside each card
                      //         title: Text(
                      //           "National Election: ${election.id}",
                      //           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Bold title
                      //         ),
                      //         subtitle: Column(
                      //           crossAxisAlignment: CrossAxisAlignment.start,
                      //           children: [
                      //             SizedBox(height: 4),
                      //             Text("Current Stage: $currentStageDisplay", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      //             SizedBox(height: 8),
                      //             Text("Election Year: 2024", style: TextStyle(fontSize: 14, color: Colors.blue)),
                      //           ],
                      //         ),
                      //         leading: Icon(Icons.poll, color: Colors.blue, size: 30), // Add an icon for better visuals
                      //           onTap: ()
                      //           {
                      //             String electionType = '';
                      //
                      //             // Determine whether the election is state or national
                      //             if
                      //             (_eligibleStateElections.any((e) => e.id == election.id))
                      //             { electionType = "State"; }
                      //             else if
                      //             (_eligibleNationalElections.any((e) => e.id == election.id))
                      //             { electionType = "National"; }
                      //             else
                      //             { print("Error: Election not found in state or national lists!");  return;  }
                      //
                      //             // Now, we can pass the correct election ID and type
                      //             String electionPath = (electionType == "State")
                      //                 ? "Vote Chain/State/${widget.state}/Election/2024/${election.id}"
                      //                 : "Vote Chain/Election/2024/${election.id}/State/${widget.state}";
                      //
                      //             // Navigate to the candidate list page, passing election type and ID
                      //             Navigator.push(
                      //               context,
                      //               MaterialPageRoute( builder: (context) => VoteCandidateList
                      //                 (
                      //                   state: widget.state,
                      //                   userEmail: widget.email,
                      //                   electionId: election.id,  // Pass the election ID
                      //                   electionPath: electionPath,
                      //                   electionType: electionType, // Pass the election type
                      //                 ),
                      //               ),
                      //             );
                      //           }
                      //       ),
                      //     );
                      //   }).toList(),
                      // Below is updated one  w.r.t. final state election fun code
                      if (_eligibleNationalElections.isNotEmpty)
                        ..._eligibleNationalElections.map((election) {
                         var data = election.data() as Map<String, dynamic>?;
                         // var currentStage = data?['currentStage'];
                         // String currentStageDisplay = currentStage != null ? currentStage.toString() : "Not available";
                         String electionType = '';

                         /// original one
                         /// updated one
                         /// trying...
                         return Padding(
                           padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 10), // More padding
                           child: Card(
                             elevation: 16, // Stronger depth effect
                             shape: RoundedRectangleBorder(
                               borderRadius: BorderRadius.circular(22), // Smoother corners
                             ),
                             clipBehavior: Clip.antiAliasWithSaveLayer,
                             child: InkWell(
                               onTap: () {
                                 // // Determine election type
                                 // if (_eligibleStateElections.any((e) => e.id == election.id)) {
                                 //   electionType = "State";
                                 // } else
                                   if (_eligibleNationalElections.any((e) => e.id == election.id)) {
                                   electionType = "National";
                                 } else {
                                   print("Error: Election not found in national lists!");
                                   return;
                                 }

                                 String electionYear = AppConstants.getCurrentYear();
                                 String electionPath =
                                 // (electionType == "State")
                                 //     ? "Vote Chain/State/${widget.state}/Election/$electionYear/${election.id}"
                                 //     :
                                 "Vote Chain/Election/$electionYear/${election.id}/State/${widget.state}";

                                 Navigator.push(
                                   context,
                                   MaterialPageRoute(
                                     builder: (context) => VoteCandidateList(
                                       state: widget.state,
                                       userEmail: widget.email,
                                       electionId: election.id,
                                       electionPath: electionPath,
                                       electionType: electionType,
                                     ),
                                   ),
                                 );
                               },
                               child: Container(
                                 decoration: BoxDecoration(
                                   gradient: LinearGradient(
                                     colors: [Colors.teal, Colors.grey.shade100],
                                     begin: Alignment.topLeft,
                                     end: Alignment.bottomRight,
                                   ),
                                   borderRadius: BorderRadius.circular(22),
                                   boxShadow: [
                                     BoxShadow(
                                       color: Colors.black.withOpacity(0.08), // Softer, premium shadow
                                       blurRadius: 14,
                                       offset: Offset(0, 6),
                                     ),
                                   ],
                                 ),
                                 padding: EdgeInsets.symmetric(vertical: 24, horizontal: 26), // More space
                                 child: Column(
                                   mainAxisAlignment: MainAxisAlignment.center,
                                   crossAxisAlignment: CrossAxisAlignment.center,
                                   children: [
                                     // ICON AT THE TOP
                                     Container(
                                       decoration: BoxDecoration(
                                         // color: Colors.blueAccent.shade700,
                                         // color: Color(2962FFFF),
                                         shape: BoxShape.circle,
                                         boxShadow: [
                                           BoxShadow(
                                             // color: Colors.blueAccent.withOpacity(0.35),
                                             color: Color(0xFFC5965E).withOpacity(0.45),
                                             blurRadius: 12,
                                             offset: Offset(0, 5),
                                           ),
                                         ],
                                       ),
                                       padding: EdgeInsets.all(14),
                                       /// icon
                                       // child: Icon(
                                       //   Icons.how_to_vote,
                                       //   color: Colors.white,
                                       //   size: 44, // Bigger for better visibility
                                       // ),
                                       /// image
                                       // child: Image.asset(
                                       //   'assets/images/election.jpg',
                                       //   // width: 44, // Adjust size as needed
                                       //   // height: 44,
                                       //   fit: BoxFit.cover, // Ensures proper scaling
                                       // ),
                                       /// smooth image
                                       child: ClipRRect(
                                         borderRadius: BorderRadius.circular(30), // Makes the image circular
                                         child: Image.asset(
                                           'assets/images/election.jpg',
                                           // width: 44, // Adjust size as needed
                                           // height: 44,
                                           fit: BoxFit.cover, // Ensures proper scaling
                                         ),
                                       ),
                                     ),
                                     SizedBox(height: 16), // Space between icon and text

                                     // ELECTION DETAILS BELOW
                                     // Text(
                                     //   "Election: ${election.id}",
                                     //   style: TextStyle(
                                     //     fontSize: 18, // Bigger title
                                     //     fontWeight: FontWeight.bold,
                                     //     color: Colors.black87,
                                     //   ),
                                     // ),
                                     Center(
                                       child: Text(
                                         "Election: ${election.id}",
                                         style: TextStyle(
                                           fontSize: 18, // Bigger title
                                           fontWeight: FontWeight.bold,
                                           color: Colors.black87,
                                         ),
                                         overflow: TextOverflow.ellipsis, // Ensures the text doesn't break into a new line
                                         maxLines: 1, // Ensures only one line is used
                                       ),
                                     ),
                                     SizedBox(height: 8), // More vertical spacing
                                     Center(
                                       child: Text(
                                         "State: ${widget.state}",
                                         style: TextStyle(
                                           fontSize: 17,
                                           color: Colors.black,
                                           fontWeight: FontWeight.bold,
                                         ),
                                         overflow: TextOverflow.ellipsis, // Ensures the text doesn't break into a new line
                                         maxLines: 1, // Ensures only one line is used
                                       ),
                                     ),
                                     SizedBox(height: 6),
                                     Center(
                                       child: Text(
                                         // "Year: 2024",
                                         "Year: $electionYear",
                                         style: TextStyle(
                                           fontSize: 17,
                                           fontWeight: FontWeight.w600,
                                           color: Colors.black87,
                                         ),
                                         overflow: TextOverflow.ellipsis, // Ensures the text doesn't break into a new line
                                         maxLines: 1, // Ensures only one line is used
                                       ),
                                     ),
                                     SizedBox(height: 10), // More spacing

                                     // ARROW INDICATING NAVIGATION
                                     Icon(
                                       Icons.arrow_forward_ios,
                                       color: Colors.grey.shade600,
                                       size: 24, // Bigger arrow for better UI balance
                                     ),
                                   ],
                                 ),
                               ),
                             ),
                           ),
                         );

                       }).toList(),

                   ],
                  ),
      ),
    );
  }
}


