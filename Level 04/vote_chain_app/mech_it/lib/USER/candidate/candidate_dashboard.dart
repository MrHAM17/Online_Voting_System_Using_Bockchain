import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../SERVICE/screen/filter_fab.dart';
import '../../SERVICE/utils/app_constants.dart';

class CandidateDashboard extends StatefulWidget {
  const CandidateDashboard({Key? key}) : super(key: key);

  @override
  State<CandidateDashboard> createState() => _CandidateDashboardState();
}

class _CandidateDashboardState extends State<CandidateDashboard> {


  void updateFilters(Map<String, String?> filters) {
    // setState(() {
    //   selectedElectionType = filters['type'];
    //   selectedYear = filters['year'];
    //   selectedState = filters['state'];
    //   selectedConstituency = filters['constituency'];
    // });
    //
    // fetchApplications(); // Fetch applications based on the updated filters
  }

  List<Map<String, dynamic>> results = [];
  bool isLoading = false;

  // This method will receive the filters and handle the results fetching logic.
  Future<void> fetchElectionResults({
    required String electionType,
    required String state,
    required String year,
    required String constituency,
  }) async
  {
    setState(() => isLoading = true);

    try
    {
      // Determine if the election type is Lok Sabha or Rajya Sabha
      final isLokSabhaOrRajyaSabha = electionType == "General (Lok Sabha)" || electionType == "Council of States (Rajya Sabha)";

      // Build Firestore reference based on election type
      final resultRef = isLokSabhaOrRajyaSabha
          ? FirebaseFirestore.instance
          .collection("Vote Chain")
          .doc("Election")
          .collection(year)
          .doc(electionType)
          .collection("Result")

          : FirebaseFirestore.instance
          .collection("Vote Chain")
          .doc("State")
          .collection(state)
          .doc("Election")
          .collection(year)
          .doc(electionType)
          .collection("Result");

      // Fetch results for the selected constituency
      final resultSnapshot = await resultRef.doc(constituency).get();

      if (resultSnapshot.exists) {
        final data = resultSnapshot.data() as Map<String, dynamic>;
        final currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
        List<Map<String, dynamic>> fetchedResults = [];

        // Extract and store election results
        data.forEach((email, candidateData)
        {
          if (candidateData is Map<String, dynamic>)
          {
            fetchedResults.add({
              "email": email,
              "votes": candidateData['voteCount'] ?? 0,
              "partyName": candidateData['partyName'] ?? "Unknown",
            });
          }
        });

        // Sort results by votes in descending order
        fetchedResults.sort((a, b) => b['votes'].compareTo(a['votes']));

        // Check if the current user is the top candidate
        final isSelected = fetchedResults.isNotEmpty &&
            fetchedResults.first['email'] == currentUserEmail;

        setState(() { results = fetchedResults; }); // Update the 'results' variable

        // Display the selection status
        final selectionMessage = isSelected
            ? "You are Selected for the election."
            : "You are Not Selected for the election.";
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(selectionMessage)));
      } else {
        // No results found
        setState(() => results = []);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(
          content: Text("No results found for the selected filters."),
        ));
      }
    } catch (e) {
      print("Error fetching results: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("An error occurred while fetching results."),
      ));
    } finally {
      setState(() => isLoading = false);
    }
  }



  Widget buildResultList() {
    if (results.isEmpty) {
      return const Center(
        child: Text("No results to display. Apply filters to view results."),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        final isCurrentUser =
            result['email'] == FirebaseAuth.instance.currentUser?.email;

        return Card(
          elevation: 4.0,
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ListTile(
            title: Text(
              result['email'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isCurrentUser ? Colors.green : Colors.black,
              ),
            ),
            subtitle: Text("Votes: ${result['votes']}"),
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
            'Candidate Dashboard',
            style: TextStyle(
              fontSize: 20,                    // Font size for better visibility
              fontWeight: FontWeight.bold,     // Bold font for emphasis
              color: Colors.white,             // White color for better contrast
            ),
          ),
        ),
        backgroundColor: AppConstants.appBarColor,  // Use your custom color constant
        elevation: 4,                               // Add shadow for a modern look
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : buildResultList(),
            floatingActionButton: FilterFAB(role: "Candidate",
              onFilterApplied: (filters)
              {
                updateFilters(filters);
              },
      ),
    );
  }
}
