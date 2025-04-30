


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../SERVICE/utils/app_constants.dart';

class PartyProfile extends StatelessWidget {
  final String stateName;
  final String partyName;

  PartyProfile({Key? key, required this.stateName, required this.partyName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.appBarColor,
        title: Center(
          child: Text(
            'Party Profile',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        elevation: 6,
        automaticallyImplyLeading: false,
      ),
      body: PartyProfileBody(stateName: stateName, partyName: partyName),
    );
  }
}

class PartyProfileBody extends StatelessWidget {
  final String stateName;
  final String partyName;

  PartyProfileBody({Key? key, required this.stateName, required this.partyName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Vote Chain')
            .doc('Party')
            .collection(stateName)
            .doc(partyName)
            .collection('Party Info')
            .doc('Details')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("Party not found", style: TextStyle(fontSize: 18)));
          }

          var partyData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPartyHeader(partyData),
                SizedBox(height: 24),
                _buildSectionTitle('Party Details'),
                _buildProfileCard('Party Name', partyData['partyName'] ?? 'N/A'),
                _buildProfileCard('Party Head', partyData['name'] ?? 'N/A'),
                _buildProfileCard('Total Members', partyData['totalMembers'].toString() ?? '0'),
                SizedBox(height: 24),
                _buildSectionTitle('Party Head Details'),
                _buildProfileCard('Name', partyData['name'] ?? 'N/A'),
                _buildProfileCard('Email', partyData['email'] ?? 'N/A'),
                _buildProfileCard('Phone', partyData['phone'] ?? 'N/A'),
                SizedBox(height: 24),
                _buildSectionTitle('Party Actions'),
                _buildActionButtons(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPartyHeader(Map<String, dynamic> partyData) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          partyData['logoURL'] != null
              ? ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              partyData['logoURL'],
              width: 90,
              height: 90,
              fit: BoxFit.cover,
            ),
          )
              : Icon(Icons.account_circle, size: 90, color: Colors.grey), // Default icon if no logo
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  partyData['partyName'] ?? 'N/A',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.appBarColor,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Party Head: ${partyData['name'] ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  partyData['partyDescription'] ?? 'No description available.',
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
          color: AppConstants.appBarColor,
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
                // style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.grey[700]),

              ),
            ),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                // style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.grey[700]),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),

              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () {
            // Navigator.pushNamed(
            //   context,
            //   '/manageMembers',
            //   arguments: {'stateName': stateName, 'partyName': partyName},
            // );
          },
          style: ElevatedButton.styleFrom(
            primary: AppConstants.primaryColor,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          child: Text(
            'Manage Members',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        SizedBox(height: 16), // Add spacing between the buttons
        ElevatedButton(
          onPressed: () {
            // Navigator.pushNamed(context, '/requestNameChange', arguments: {
            //   'stateName': stateName,
            //   'partyName': partyName,
            // });
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.orange,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          child: Text(
            'Request Name Change',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
