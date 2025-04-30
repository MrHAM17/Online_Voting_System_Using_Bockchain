import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CandidateHome extends StatefulWidget {
  @override
  _CandidateHomeState createState() => _CandidateHomeState();
}

class _CandidateHomeState extends State<CandidateHome> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  Map<String, dynamic>? _candidateData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCandidateData();
  }

  // Fetch candidate data from Firestore
  Future<void> _loadCandidateData() async {
    setState(() {
      _isLoading = true;
    });

    _currentUser = _auth.currentUser;
    if (_currentUser != null) {
      try {
        // Replace 'state' with the state associated with the candidate if it's stored somewhere
        String? selectedState = "SomeState";  // This should be passed or retrieved

        // Fetch candidate's profile data from Firestore
        DocumentSnapshot candidateDoc = await _firestore
            .collection('Vote Chain')
            .doc('Candidate')
            .collection(selectedState!)  // Adjust based on the selected state
            .doc(_currentUser!.email)  // Assuming email is used as the document ID
            .collection('Profile')
            .doc('Details')  // Details document where candidate info is stored
            .get();

        if (candidateDoc.exists) {
          setState(() {
            _candidateData = candidateDoc.data() as Map<String, dynamic>;
          });
        } else {
          // Handle the case when the candidate data does not exist
          setState(() {
            _candidateData = null;
          });
        }
      } catch (e) {
        print("Error fetching candidate data: $e");
        setState(() {
          _candidateData = null;
        });
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Log out functionality
  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/Login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Candidate Home"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to the login page
            Navigator.pushReplacementNamed(context, '/Login');
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _candidateData == null
          ? Center(
        child: Text(
          "No candidate data available.",
          style: TextStyle(fontSize: 16),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Welcome, ${_candidateData!['name'] ?? 'Candidate'}!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Email: ${_candidateData!['email'] ?? 'N/A'}",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                "Phone: ${_candidateData!['phone'] ?? 'N/A'}",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                "Party Name: ${_candidateData!['partyName'] ?? 'N/A'}",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                "Party Type: ${_candidateData!['partyType'] ?? 'N/A'}",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                "State: ${_candidateData!['state'] ?? 'N/A'}",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Divider(thickness: 2),
              SizedBox(height: 16),
              Text(
                "Election Information",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                "• Election Type: ${_candidateData!['electionType'] ?? 'N/A'}",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Navigate to detailed election info page
                  Navigator.pushNamed(context, '/ElectionDetails');
                },
                child: Text("View Election Details"),
              ),
              SizedBox(height: 16),
              Divider(thickness: 2),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Navigate to candidate profile editing
                  Navigator.pushNamed(context, '/EditCandidateProfile');
                },
                child: Text("Edit Profile"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
