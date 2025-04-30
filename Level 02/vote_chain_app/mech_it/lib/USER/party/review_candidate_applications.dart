

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../SERVICE/screen/filter_fab.dart';
import '../../SERVICE/utils/app_constants.dart';

class ReviewCandidateApplication extends StatefulWidget {
  final String partyName;
  const ReviewCandidateApplication({
    Key? key,
    required this.partyName,
  }) : super(key: key);

  @override
  _ReviewCandidateApplicationState createState() =>
      _ReviewCandidateApplicationState();
}

class _ReviewCandidateApplicationState extends State<ReviewCandidateApplication> {
  String? selectedElectionType;
  String? selectedYear;
  String? selectedState;
  String? selectedConstituency;
  List<Map<String, dynamic>> candidateApplications = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchApplications();  // Fetch applications when the screen is initialized
  }


  Future<void> fetchApplications() async
  {
    setState(() { isLoading = true;  candidateApplications = [];   });

    try
    {
      String  basePath = "";
      DocumentSnapshot? partySnapshot; // Declare it outside the conditionals


      if (selectedElectionType == "General (Lok Sabha)" || selectedElectionType == "Council of States (Rajya Sabha)")
      {
        // Check if the party is officially registered
        DocumentSnapshot partySnapshot = await FirebaseFirestore.instance
            .doc("Vote Chain/Election/$selectedYear/$selectedElectionType/Party_Candidate/${widget.partyName}")
            .get();

        basePath = "Vote Chain/Election/$selectedYear/$selectedElectionType/Party_Candidate/${widget.partyName}/$selectedConstituency/Applications";
      }
      else if
      (
        selectedElectionType == "State Assembly (Vidhan Sabha)" || selectedElectionType == "Legislary Council (Vidhan Parishad)"  ||
        selectedElectionType == "Municipal" || selectedElectionType == "Panchayat" ||  selectedElectionType == "By-elections"
      )
      {
        // Check if the party is officially registered
        DocumentSnapshot partySnapshot = await FirebaseFirestore.instance
            .doc("Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Party_Candidate/${widget.partyName}")
            .get();

        basePath = "Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Party_Candidate/${widget.partyName}//$selectedConstituency/Applications";
      }


      // Cast doc.data() as Map<String, dynamic> and check for the 'isPartyOfficiallyRegistered' field
      if (partySnapshot != null && partySnapshot!.exists)
      {
        Map<String, dynamic> partyData = partySnapshot.data() as Map<String, dynamic>;
        if (partyData['isPartyOfficiallyRegistered'] == 'yes')
        {
          QuerySnapshot snapshot = await FirebaseFirestore.instance.collection(basePath).get();
          setState(() { candidateApplications = snapshot
              .docs
              .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
              .toList();
          });
        }
        else
        { ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('The party is not officially registered.')), ); }
      }
      else
      { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Party does not exist.')), );  }
    }
    catch (e) { print('Error fetching applications: $e'); }
    finally { setState(() { isLoading = false; });     }
  }

  Future<void> acceptCandidate(String candidateId) async
  {
    try
    {
      String  basePath = "";
      DocumentSnapshot? partySnapshot; // Declare it outside the conditionals

      if (selectedElectionType == "General (Lok Sabha)" || selectedElectionType == "Council of States (Rajya Sabha)")
      {
        // Check if the party is officially registered
        DocumentSnapshot partySnapshot = await FirebaseFirestore.instance
            .doc("Vote Chain/Election/$selectedYear/$selectedElectionType/Party_Candidate/${widget.partyName}")
            .get();
        basePath = "Vote Chain/Election/$selectedYear/$selectedElectionType/Party_Candidate/${widget.partyName}/$selectedConstituency";
      }
      else if
      (   selectedElectionType == "State Assembly (Vidhan Sabha)" || selectedElectionType == "Legislary Council (Vidhan Parishad)"  ||
          selectedElectionType == "Municipal" || selectedElectionType == "Panchayat" ||  selectedElectionType == "By-elections"
      )
      {
        // Check if the party is officially registered
        DocumentSnapshot partySnapshot = await FirebaseFirestore.instance
            .doc("Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Party_Candidate/${widget.partyName}")
            .get();
        basePath = "Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Party_Candidate/${widget.partyName}/$selectedConstituency";
      }

      // Cast doc.data() as Map<String, dynamic> and check for the 'isPartyOfficiallyRegistered' field
      if (partySnapshot != null  && partySnapshot!.exists)
      {
        Map<String, dynamic> partyData = partySnapshot.data() as Map<String, dynamic>;
        if (partyData['isPartyOfficiallyRegistered'] == 'yes')
        {
          await FirebaseFirestore.instance.doc('$basePath/Applications/$candidateId').update({'status': 'accepted'});

          await FirebaseFirestore.instance.doc('$basePath/Selected').set({'selectedCandidate': candidateId});

          if (selectedElectionType == "General (Lok Sabha)" || selectedElectionType == "Council of States (Rajya Sabha)")
          {
            await FirebaseFirestore.instance
                .doc('Vote Chain/Election/$selectedYear/$selectedElectionType/Party_Candidate/${widget.partyName}/Selected_Candidates_Over_All_Constituency/$candidateId')
                .update({
              // 'appliedConstituency': FieldValue.arrayUnion([selectedConstituency]),
              // does not make sense for here actually but will for candidate --> so store in detail for candidate in his profile...
              'selectedConstituency': FieldValue.arrayUnion([selectedConstituency]),
              // 'confirmedConstituency': FieldValue.arrayUnion([answerConstituency]),

            });
          }
          else if
          (   selectedElectionType == "State Assembly (Vidhan Sabha)" || selectedElectionType == "Legislary Council (Vidhan Parishad)"  ||
              selectedElectionType == "Municipal" || selectedElectionType == "Panchayat" ||  selectedElectionType == "By-elections"
          )
          {
            await FirebaseFirestore.instance
                .doc('Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Party_Candidate/${widget.partyName}/Selected_Candidates_Over_All_Constituency/$candidateId')
                .update({
              // 'appliedConstituency': FieldValue.arrayUnion([selectedConstituency]),
              // does not make sense for here actually but will for candidate --> so store in detail for candidate in his profile...
              'selectedConstituency': FieldValue.arrayUnion([selectedConstituency]),
              // 'confirmedConstituency': FieldValue.arrayUnion([answerConstituency]),

            });
          }

          setState(() { candidateApplications.removeWhere((app) => app['id'] == candidateId); });

          ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Candidate accepted successfully!')), );
        }
        else
        { ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('The party is not officially registered.')),  ); }
      }
      else
      { ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text('Party does not exist.')),  ); }
    }
    catch (e) { print('Error accepting candidate: $e'); }
  }

  Future<void> rejectCandidate(String candidateId) async
  {
    try
    {
      String  basePath = "";
      DocumentSnapshot? partySnapshot; // Declare it outside the conditionals

      if (selectedElectionType == "General (Lok Sabha)" || selectedElectionType == "Council of States (Rajya Sabha)")
      {
        // Check if the party is officially registered
        DocumentSnapshot partySnapshot = await FirebaseFirestore.instance
            .doc("Vote Chain/Election/$selectedYear/$selectedElectionType/Party_Candidate/${widget.partyName}")
            .get();
        basePath = "Vote Chain/Election/$selectedYear/$selectedElectionType/Party_Candidate/${widget.partyName}/$selectedConstituency";
      }
      else if
      (   selectedElectionType == "State Assembly (Vidhan Sabha)" || selectedElectionType == "Legislary Council (Vidhan Parishad)"  ||
          selectedElectionType == "Municipal" || selectedElectionType == "Panchayat" ||  selectedElectionType == "By-elections"
      )
      {
        // Check if the party is officially registered
        DocumentSnapshot partySnapshot = await FirebaseFirestore.instance
            .doc("Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Party_Candidate/${widget.partyName}")
            .get();
        basePath = "Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Party_Candidate/${widget.partyName}/$selectedConstituency";
      }


      // Cast doc.data() as Map<String, dynamic> and check for the 'isPartyOfficiallyRegistered' field
      if (partySnapshot!.exists)
      {
        Map<String, dynamic> partyData = partySnapshot.data() as Map<String, dynamic>;
        if (partyData['isPartyOfficiallyRegistered'] == 'yes')
        {
          await FirebaseFirestore.instance.doc('$basePath/Applications/$candidateId').update({'status': 'rejected'});

          setState(() { candidateApplications.removeWhere((app) => app['id'] == candidateId);  });

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Candidate rejected successfully!')), );
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
      child: ListTile(
        title: Text(application['name'] ?? 'Unknown'),
        subtitle: Text(application['email'] ?? 'No email provided'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: () => acceptCandidate(application['id']),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () => rejectCandidate(application['id']),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFilterButton() {
    return Stack(
      children: [
        FilterFAB(), // Pass the updateFilters method to FilterFAB
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.secondaryColor.withOpacity(0.1),
      appBar: AppBar(
        title: Center(
          child: Text(
            'Review Candidate Application',
            style: TextStyle(
              fontSize: 20,                    // Adjust font size for better visibility
              fontWeight: FontWeight.bold,     // Make the title bold
              color: Colors.white,             // Ensure the text is white for contrast
            ),
          ),
        ),
        backgroundColor: AppConstants.appBarColor,
        elevation: 4,                         // A subtle shadow for a clean, modern look
        automaticallyImplyLeading: false,     // Disable the back button if not needed
      ),

      body: isLoading ? const Center(child: CircularProgressIndicator()) : candidateApplications.isEmpty
          ? Center(
            child: Text( selectedElectionType == null ? 'Please apply filters to view candidates.' : 'No applications found.',
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                       ),
            )
          : ListView.builder(
              itemCount: candidateApplications.length,
              itemBuilder: (context, index) {
                return buildApplicationCard(candidateApplications[index]);
              },
            ),
      floatingActionButton: buildFilterButton(),
    );
  }
}

