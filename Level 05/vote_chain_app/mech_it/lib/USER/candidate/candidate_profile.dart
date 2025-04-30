import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mech_it/SERVICE/utils/app_constants.dart';

import '../../SERVICE/screen/styled_widget.dart';
import '../../SERVICE/utils/app_constants.dart';

class CandidateProfile extends StatelessWidget {
  final String stateName;
  final String email;

  CandidateProfile({Key? key, required this.stateName, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.appBarColor,
        title: Center(
          child: Text(
            'Candidate Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        elevation: 6,
        automaticallyImplyLeading: false,
        actions: [
          LogoutButton( onPressed: () { Navigator.pushReplacementNamed(context, '/Login'); }, ),
        ],
      ),
      body: CandidateProfileBody(stateName: stateName, email: email),
    );
  }
}

class CandidateProfileBody extends StatelessWidget {
  final String stateName;
  final String email;

  CandidateProfileBody({Key? key, required this.stateName, required this.email}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Vote Chain')
            .doc('Candidate')
            .collection(stateName)
            .doc(email)
            .collection('Profile')
            .doc('Details')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("Candidate not found", style: TextStyle(fontSize: 18)));
          }

          var candidateData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCandidateHeader(candidateData),
                SizedBox(height: 24),
                _buildSectionTitle('Candidate Details'),
                _buildProfileCard('Name', candidateData['name'] ?? 'N/A'),
                _buildProfileCard('Party', candidateData['party'] ?? 'Independent'),
                _buildProfileCard('Constituency', candidateData['constituency'] ?? 'N/A'),
                _buildProfileCard('Experience', '${candidateData['experience'] ?? '0'} years'),
                SizedBox(height: 24),
                _buildSectionTitle('Contact Details'),
                _buildProfileCard('Email', candidateData['email'] ?? 'N/A'),
                _buildProfileCard('Phone', candidateData['phone'] ?? 'N/A'),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCandidateHeader(Map<String, dynamic> candidateData) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          candidateData['photoURL'] != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    candidateData['photoURL'],
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                )
              : Icon(Icons.account_circle, size: 90, color: Colors.grey), // Default icon if no photo
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        candidateData['name'] ?? 'N/A',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Party: ${candidateData['party'] ?? 'Independent'}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        candidateData['bio'] ?? 'No bio available.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          // color: Colors.blueAccent,
          color: AppConstants.primaryColor,

        ),
      ),
    );
  }

  Widget _buildProfileCard(String title, String value) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.0),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.grey[700]),
              ),
            ),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
