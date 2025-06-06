import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../SERVICE/screen/filter_fab.dart';
import '../../SERVICE/screen/styled_widget.dart';

class ViewTab extends StatefulWidget {

  final String partyName; // Add this field
  const ViewTab({required this.partyName, Key? key}) : super(key: key); // Add the required parameter

  @override
  _ViewTabState createState() => _ViewTabState();
}

class _ViewTabState extends State<ViewTab> {
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
        FilterFAB(role: 'Party_Head_View',
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
    (selectedElectionType != null && selectedYear != null && selectedState != null && selectedConstituency != null)
    {
      SnackbarUtils.showSuccessMessage(context,"Loading Candidates' Applications..");
      // print('***Filters are:\n ElectionType=$selectedElectionType, \nYear=$selectedYear,\n State=$selectedState, \n Party= $widget.partyName');
      fetchSelectedCandidates();
    }
    else
    { SnackbarUtils.showErrorMessage(context,'Please select all filter options before proceeding.'); }
  }

  Future<void> fetchSelectedCandidates() async {
    if
    (selectedElectionType == null || selectedYear == null || selectedState == null || selectedConstituency == null)
    {
      SnackbarUtils.showErrorMessage(context,'Filters are incomplete. Please try again.');
      return;
    }

    setState(() {
      isLoading = true;
      candidateApplications = [];
    });

    try
    {
      DocumentSnapshot? partySnapshot;

      // Fetch party document based on the selected election type
      if
      (   selectedElectionType == "General (Lok Sabha)" || selectedElectionType == "Council of States (Rajya Sabha)"  )
      {
        partySnapshot = await FirebaseFirestore.instance
            .doc("Vote Chain/Election/$selectedYear/$selectedElectionType/State/$selectedState/Party_Candidate/${widget.partyName}")
            .get();
      }
      else if
      (
          selectedElectionType == "State Assembly (Vidhan Sabha)" || selectedElectionType == "Legislary Council (Vidhan Parishad)" ||
          selectedElectionType == "Municipal" || selectedElectionType == "Panchayat"
      )
      {
        partySnapshot = await FirebaseFirestore.instance
            .doc("Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Party_Candidate/${widget.partyName}")
            .get();
      }

      if (partySnapshot != null && partySnapshot.exists)
      {
        Map<String, dynamic> partyData = partySnapshot.data() as Map<String, dynamic>;

        // Ensure the party is approved before proceeding
        if (partyData['isPartyApproved'] == 'YES')
        {
          if
          (selectedConstituency == "All_Constituencies"  && selectedConstituency != null)
          {
              // Fetch documents from the Selected_Candidates_Over_All_Constituency collection
              QuerySnapshot candidateSnapshot = await FirebaseFirestore.instance
                  .collection('${partySnapshot.reference.path}/Selected_Candidates_Over_All_Constituency')
                  .get();

              List<Map<String, dynamic>> tempApplications = []; // Temporary list for sorting

              for (var doc in candidateSnapshot.docs)
              {
                // Extract email from each document (document ID is the email)
                String email = doc.id;

                // Check if selectedConstituency is a List or a String
                var constituency = doc['selectedConstituency'];
                print("1... var $constituency ") ;

                // If constituency is a list, get the first one (or handle multiple if needed)
                if (constituency is List) {
                  // Take the first element of the list if multiple constituencies are possible
                  constituency = constituency.isNotEmpty ? constituency[0] : null;
                }

                // Ensure constituency is not null
                if (constituency != null)
                {
                  // Now, fetch the application details for each candidate using their email
                  DocumentSnapshot applicationSnapshot = await FirebaseFirestore.instance
                      .doc('${partySnapshot.reference.path}/$constituency/Candidate_Application/Application/$email')
                      .get();

                  if (applicationSnapshot.exists)
                  {
                    // Combine the selectedConstituency with the application data
                    Map<String, dynamic> applicationData = applicationSnapshot.data() as Map<String, dynamic>;

                    // // Add the data to the list of candidate applications
                    // setState(() {
                    //   candidateApplications.add({
                    //     'email': email,
                    //     'constituencyName': constituency,
                    //     ...applicationData,  // Adding the rest of the application details
                    //   });
                    // });
                    // Add the data to the temporary list
                    tempApplications.add({
                      'email': email,
                      'constituencyName': constituency,
                      ...applicationData, // Adding the rest of the application details
                    });
                  }
                }
                else { SnackbarUtils.showErrorMessage(context,'Constituency is null for candidate: $email'); }
              }

              // Sort the candidate applications alphabetically by constituency name
              tempApplications.sort((a, b) {
                return (a['constituencyName'] as String).compareTo(b['constituencyName'] as String);
              });

              // Update the UI with sorted data
              setState(() {
                candidateApplications = tempApplications;
              });

              /*
              Batch Sorting: Instead of sorting inside setState, we accumulate all data in tempApplications, sort it once, and then update candidateApplications.
              Efficiency: Sorting after all candidates are added avoids unnecessary sorting on every iteration.
              Avoiding Multiple setState Calls: Updates the UI only once after sorting, preventing unnecessary re-renders.
              */
          }
          else if
          (selectedConstituency != "All_Constituencies" && selectedConstituency != null)
          {
              // Fetch the candidate document for the selected constituency
              QuerySnapshot candidateSnapshot = await FirebaseFirestore.instance
                  .collection('${partySnapshot.reference.path}/Selected_Candidates_Over_All_Constituency')
                  .where('selectedConstituency', arrayContains: selectedConstituency) // Filtering by selected constituency
                  .get();

              if (candidateSnapshot.docs.isNotEmpty)
              {
                // Extract email from the first document (document ID is the email)
                String email = candidateSnapshot.docs.first.id;

                // Now, fetch the application details for the candidate using their email
                DocumentSnapshot applicationSnapshot = await FirebaseFirestore.instance
                    .doc('${partySnapshot.reference.path}/$selectedConstituency/Candidate_Application/Application/$email')
                    .get();

                if (applicationSnapshot.exists) {
                  // Combine the selectedConstituency with the application data
                  Map<String, dynamic> applicationData = applicationSnapshot.data() as Map<String, dynamic>;

                  // Add the data to the list of candidate applications
                  setState(() {
                    candidateApplications.add({
                      'email': email,
                      'constituencyName': selectedConstituency,
                      ...applicationData, // Adding the rest of the application details
                    });
                  });
                }
              }
              else
              { SnackbarUtils.showErrorMessage(context, 'No candidate found for constituency: $selectedConstituency'); }
          }
          else
          { SnackbarUtils.showErrorMessage(context, 'No constituency found as $selectedConstituency'); }
        }
        else { SnackbarUtils.showErrorMessage(context,'The party is not officially registered.'); }
      }
      else
      { SnackbarUtils.showErrorMessage(context,'Party does not exist.'); }
    }
    catch (e)
    {
      SnackbarUtils.showErrorMessage(context,'Error fetching applications..:\n $e');
      print('Error fetching applications: $e');
    }
    finally
    {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildSelectedCandidatesCard(Map<String, dynamic> application) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      color: Colors.white, // Light teal for accepted
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
                  // Constituency Name
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal, // Enables horizontal scrolling
                    child: Row(
                      children: [
                        Text(
                          'Constituency:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          application['constituencyName'] ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 16,
                            // color: Colors.grey[700],
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
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
                      const SizedBox(width: 7),
                      Text(
                        '${application['age']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
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
                      const SizedBox(width: 7),
                      Text(
                        '${application['gender']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),

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
                        const SizedBox(width: 7),
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
                  const SizedBox(height: 7),
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
                        const SizedBox(width: 7),
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
                ],
              ),
            ),
          ],
        ),
      ),
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
                      ? 'Apply filters to view selected candidates over all constituencies.'
                      : 'No constituency-wise candidates found.',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
            : ListView.builder(
                itemCount: candidateApplications.length,
                itemBuilder: (context, index) {
                  final application = candidateApplications[index];
                  return buildSelectedCandidatesCard(application);
                },
              ),
        // Positioned directly as a child of the Stack.
        Positioned(
          bottom: 16,
          right: 16,
          child: FilterFAB(
            role: 'Party_Head_View',
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
