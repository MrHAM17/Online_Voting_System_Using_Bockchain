import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
    setState(() {
      selectedElectionType = filters['type'];
      selectedYear = filters['year'];
      selectedState = filters['state'];
      selectedConstituency = filters['constituency'];
    });

    if
    (selectedElectionType != null && selectedYear != null && selectedState != null && selectedConstituency != null )
    {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Loading Candidates' Applications..........")),  );
      // print('***Filters are:\n ElectionType=$selectedElectionType, \nYear=$selectedYear,\n State=$selectedState,\n Constituency=$selectedConstituency, \n Party= $widget.partyName');
      fetchApplications();
    }
    else
    {
      ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Please select all filter options before proceeding.')),
      );
    }
  }
  Future<void> fetchApplications() async {

    if
    ( selectedElectionType == null || selectedYear == null || selectedState == null || selectedConstituency == null )
    {
      // print('***Filters are incomplete:\n ElectionType=$selectedElectionType, \nYear=$selectedYear,\n State=$selectedState,\n Constituency=$selectedConstituency');
      ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Filters are incomplete. Please try again.')), );
      return;
    }

    print("66666666666 Rendering ${candidateApplications.length} applications.");

    setState(() {
      isLoading = true;
      candidateApplications = [];
    });

    print("77777777777 Rendering ${candidateApplications.length} applications.");

    try {
      String basePath = "";
      DocumentSnapshot? partySnapshot;

      if (selectedElectionType == "General (Lok Sabha)" || selectedElectionType == "Council of States (Rajya Sabha)")
      {
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
        SnackbarUtils.showSuccessMessage(
            context, "Application-checking logic isn't ready for $selectedElectionType.\n Select other Election type.");
        return;
      }

      print("***** *** Base Path: $basePath");

      if (partySnapshot != null && partySnapshot.exists)
      {
        Map<String, dynamic> partyData = partySnapshot.data() as Map<String, dynamic>;
        if (partyData['isPartyApproved'] == 'YES')
        {
          QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(basePath).get();
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


          print("8888888888888 Rendering ${candidateApplications.length} applications.");

        }
        else
        {
          ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('The party is not officially registered.')), );
        }
      }
      else
      { ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Party does not exist.')),  );     }
    }
    catch (e)
    {
      print('Error fetching applications: $e');
      WidgetsBinding.instance.addPostFrameCallback((_)
      { ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Error fetching applications..')), ); });

    }
    finally
    {
      setState(() {
        isLoading = false;
      });
    }
  }
  Future<void> acceptCandidate(String candidateId) async {
    try
    {
      String  basePath = "";
      DocumentSnapshot? partySnapshot; // Declare it outside the conditionals

      if (selectedElectionType == "General (Lok Sabha)" || selectedElectionType == "Council of States (Rajya Sabha)")
      {
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
        SnackbarUtils.showSuccessMessage(context,"Accepting logic isn't ready for $selectedElectionType.\n Select other Election type.");

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

      // Cast doc.data() as Map<String, dynamic> and check for the 'isPartyOfficiallyRegistered' field
      if (partySnapshot != null  && partySnapshot.exists)
      {
        Map<String, dynamic> partyData = partySnapshot.data() as Map<String, dynamic>;

        if (partyData['isPartyApproved'] == 'YES')
        {
          // Step 1: Check if a candidate is already selected for the constituency or not ???
          DocumentSnapshot selectedDoc = await FirebaseFirestore.instance.doc('${partySnapshot.reference.path}/$selectedConstituency/Selected').get();

          // if yes (means ph is replacing previously selected candidate with new one for respective constituency).....................
          if (selectedDoc.exists)
          {
            // String previousCandidateEmail = selectedDoc.data()?['email'];
            Map<String, dynamic> selectedData = selectedDoc.data() as Map<String, dynamic>;
            String previousCandidateEmail = selectedData['selectedCandidate'] ?? '';

            // Step 1A: Mark previously selected candidate status as "Pending Approval"
            await FirebaseFirestore.instance.collection(basePath)
                .where('email', isEqualTo: previousCandidateEmail)
                .get()
                .then((querySnapshot) {
              querySnapshot.docs.forEach((doc) {
                doc.reference.update({'status': 'Pending Approval'});
              });
            });

            print('\n\n-------------------------- 1 Path: ${partySnapshot.reference.path}/$selectedConstituency/Selected');


            // Step 1B: Remove(reset to empty) previously selected candidate from "Selected" from that constituency.
            await FirebaseFirestore.instance
                .doc('${partySnapshot.reference.path}/$selectedConstituency/Selected') // Direct reference to the "Selected" document
                .update({ 'selectedCandidate': '', // Resets the field to an empty string
            })
                .then((_) => print("Successfully deleted: $previousCandidateEmail"))
            ;

            print('\n\n--------------------------2 Path: ${partySnapshot.reference.path}/$selectedConstituency/Selected');


            // Step 1C: Remove the previously selected candidate from "Selected Candidates Over All Constituency" record
            await FirebaseFirestore.instance
                .doc("${partySnapshot.reference.path}/Selected_Candidates_Over_All_Constituency/$previousCandidateEmail")
                .delete()
            // .then((_) => print("Successfully deleted: $previousCandidateEmail"))
                .catchError((error) => print("Error deleting document: $error"));
          }

          // if no (means ph is first time selecting candidate for respective constituency).....................
          // Step 2:
          await FirebaseFirestore.instance.doc('$basePath/$candidateId').update({'status': 'Accepted'});

          // Step 3:
          await FirebaseFirestore.instance.doc('${partySnapshot.reference.path}/$selectedConstituency/Selected').set({'selectedCandidate': candidateId});

          // Step 4:
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
          // }
          // else
          if
          (
          selectedElectionType == "By-elections" || selectedElectionType == "Referendum" ||
              selectedElectionType == "Confidence Motion (Floor Test)" || selectedElectionType == "No Confidence Motion")
          {
            SnackbarUtils.showSuccessMessage(context,"Accepting logic isn't ready for $selectedElectionType.\n Select other Election type.");

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

          // Below line is responsible for removing the candidate from the UI list after PH accepts.
          setState(() { candidateApplications.removeWhere((app) => app['id'] == candidateId); });

          // // Update status locally in the list
          setState(() {
            candidateApplications = candidateApplications.map((candidate) {
              if (candidate['id'] == candidateId) {
                candidate['status'] = 'Accepted';
              }
              return candidate;
            }).toList();
          });

          print("44444444444444 Rendering ${candidateApplications.length} applications.");
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



          ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Candidate selected for $selectedConstituency Constituency !')), );
        }
        else
        { ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('The party is not officially registered.')),  ); }
      }
      else
      { ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Party does not exist.')),  ); }
    }
    catch (e) { print('Error accepting candidate: $e'); }
  }
  Future<void> rejectCandidate(String candidateId) async {
    try
    {
      String  basePath = "";
      DocumentSnapshot? partySnapshot; // Declare it outside the conditionals

      if (selectedElectionType == "General (Lok Sabha)" || selectedElectionType == "Council of States (Rajya Sabha)")
      {
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
        SnackbarUtils.showSuccessMessage(context,"Rejecting logic isn't ready for $selectedElectionType.\n Select other Election type.");

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


      // Cast doc.data() as Map<String, dynamic> and check for the 'isPartyOfficiallyRegistered' field
      if (partySnapshot!.exists)
      {
        Map<String, dynamic> partyData = partySnapshot.data() as Map<String, dynamic>;
        if (partyData['isPartyApproved'] == 'YES')
        {
          // Get candidate details first
          DocumentSnapshot candidateSnapshot = await FirebaseFirestore.instance
              .doc('$basePath/$candidateId')
              .get();
          Map<String, dynamic> candidateData = candidateSnapshot.data() as Map<String, dynamic>;

          // Reject candidate and show real name in Snackbar
          await FirebaseFirestore.instance.doc('$basePath/$candidateId').update({'status': 'Not Selected'});

          // Below line is responsible for removing the candidate from the UI list after PH rejects.
          // setState(() { candidateApplications.removeWhere((app) => app['id'] == candidateId);  });
          // Update status locally in the list
          // setState(() {
          //   var candidate = candidateApplications.firstWhere((app) => app['id'] == candidateId);
          //   candidate['status'] = 'Rejected';  // Update the status field of the candidate
          // });

          // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(' Candidate rejected for $selectedConstituency Constituency !')), );
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${candidateData['name']} rejected for $selectedConstituency Constituency!')));

        }
        else
        { ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('The party is not officially registered.')), ); }
      }
      else
      { ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Party does not exist.')), ); }
    }
    catch (e) { print('Error rejecting candidate: $e'); }
  }
  Widget buildApplicationCard(Map<String, dynamic> application) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      color: application['status'] == 'Accepted' ? Colors.teal.shade100 : Colors.white, // Light teal for accepted
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
                    if (application['status'] == 'Accepted')
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.orange.shade300, Colors.deepOrangeAccent.shade700],
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
                      )
                    else ...[
                      // Accept Button (Icon button)
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: () async {
                          setState(() => isLoading = true);
                          print("11111111111111  Before accepting: ${candidateApplications.length} candidates");
                          await acceptCandidate(application['id']);
                          print("22222222222222  Before accepting: ${candidateApplications.length} candidates");
                          fetchApplications();
                          print("33333333333333  Before accepting: ${candidateApplications.length} candidates");
                          setState(() => isLoading = false);
                        },
                        iconSize: 28,
                      ),
                      const SizedBox(height: 1),
                      // Reject Button (Icon button)
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () => rejectCandidate(application['id']),
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
                  Text(
                    application['name'] ?? 'Unknown',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis, // Prevents name overflow
                  ),
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

                  // Email and Gender with consistent styling
                  Row(
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
                  Row(
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
                  const SizedBox(height: 8),
                  Row(
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
        buildFilterButton(),
      ],
    );
  }
}
