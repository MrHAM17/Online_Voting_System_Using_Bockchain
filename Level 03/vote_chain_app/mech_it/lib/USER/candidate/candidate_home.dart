import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../SERVICE/utils/app_constants.dart';
import 'candidate_application_for_election.dart';
import 'candidate_dashboard.dart';
import 'candidate_profile.dart';


class CandidateHome extends StatefulWidget {
  final String state;
  final String email;

  CandidateHome({required this.state, required this.email});

  @override
  _CandidateHomeState createState() => _CandidateHomeState();
}



class _CandidateHomeState extends State<CandidateHome> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String selectedState;
  late String email;
  Map<String, dynamic>? candidateData;
  bool isLoading = true;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Initialize the state and email from the widget's constructor
    // selectedState = widget.state;
    selectedState = widget.state ?? 'Default State';  // Default state
    email = widget.email;

    _fetchCandidateData();
  }

  Future<void> _fetchCandidateData() async {
    setState(() {
      isLoading = true;
    });
    try {
      DocumentSnapshot candidateDoc = await _firestore
          .collection('Vote Chain')
          .doc('Candidate')
          .collection(selectedState)
          .doc(email)
          .collection('Profile')
          .doc('Details')
          .get();

      setState(() {
        candidateData = candidateDoc.data() as Map<String, dynamic>?;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $error')),
      );
    }
  }

  List<Widget> _buildTabs() {
    return [
      CandidateApplication(),
      CandidateDashboard(),
      CandidateProfile(stateName: selectedState, email: email),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      CandidateApplication(),
      CandidateDashboard(),
      CandidateProfile(stateName: selectedState, email: email),
    ];

    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : tabs[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        backgroundColor: AppConstants.primaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: AppConstants.secondaryColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.how_to_vote), label: 'Election'),
          BottomNavigationBarItem(icon: Icon(Icons.pending_actions), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profile'),
        ],
      ),
    );
  }
}
