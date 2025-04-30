import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../SERVICE/screen/styled_widget.dart';
import '../../SERVICE/utils/app_constants.dart';

class AdminProfile extends StatelessWidget {
  final String state;
  final String email;

  // Constructor accepting state and email
  AdminProfile({required this.state, required this.email});

  // Fetch admin details from Firestore
  Future<Map<String, dynamic>> fetchAdminDetails() async
  {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('Vote Chain')
          .doc('Admin')
          .collection(state)
          .doc(email)
          .collection('Profile')
          .doc('Details');

      final docSnapshot = await docRef.get();

      if (docSnapshot.exists)
      { return docSnapshot.data()!;}
      else
      { throw Exception('Admin details not found'); }
    }
    catch (e)
    { throw Exception('Error fetching admin details: $e'); }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchAdminDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No data found'));
          }

          // Extract admin details from the snapshot
          final adminDetails = snapshot.data!;
          final adminName = adminDetails['name'] ?? 'Admin Name';
          final adminEmail = adminDetails['email'] ?? 'admin@example.com';
          final adminPhone = adminDetails['phone'] ?? 'Not Available';

          // Always return a widget
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  // child: CircleAvatar(
                  //   radius: 50,
                  //   backgroundColor: AppConstants.primaryColor,
                  //   child: Icon(
                  //     Icons.person,
                  //     size: 50,
                  //     color: Colors.white,
                  //   ),
                  // ),
                  //////////////////////////////////////
                  child: CircleAvatar(
                    radius: 60, // Increased size for better visibility
                    backgroundColor: AppConstants.primaryColor,
                    child: ClipOval(
                      child: adminDetails['imageUrl'] != null && adminDetails['imageUrl'].isNotEmpty
                          ? Image.network(
                        adminDetails['imageUrl'], // Assuming the URL is stored in Firestore
                        fit: BoxFit.cover,
                        width: 120,
                        height: 120,
                      )
                          : Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  

                ),
                SizedBox(height: 20),

                // Admin Details Cards
                _buildProfileCard('Name', adminName),
                _buildProfileCard('Email', adminEmail),
                _buildProfileCard('Phone', adminPhone),

                SizedBox(height: 90),

                // Action Buttons
                _buildActionButtons(context),
              ],
            ),
          );
        },
      ),
    );
  }

  // Profile Card Method
  Widget _buildProfileCard(String title, String value) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.0),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[700],
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Action Button Method
  // Updated Action Buttons
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () {
            // Navigate to edit profile screen
            Navigator.pushNamed(context, '/EditProfile', arguments: {
              'state': state,
              'email': email,
            });
          },
          style: ElevatedButton.styleFrom(
            primary: AppConstants.primaryColor, // Use the primary color
            padding: EdgeInsets.symmetric(vertical: 16), // Larger vertical padding
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          child: Text(
            'Edit Profile',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        SizedBox(height: 12), // Add spacing between the buttons
        ElevatedButton(
          onPressed: () {
            // Navigate to change password screen
            Navigator.pushNamed(context, '/ChangePassword');
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.orange, // Different color for secondary action
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          child: Text(
            'Export Activity',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ],
    );
  }

}
