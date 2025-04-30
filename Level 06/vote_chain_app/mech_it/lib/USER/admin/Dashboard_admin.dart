import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../SERVICE/screen/styled_widget.dart';
import '../../SERVICE/utils/app_constants.dart';
import 'election_details.dart';

class AdminDashboard extends StatelessWidget {
  // Future<String> fetchAdminName(BuildContext context) async
  // {
  //   try
  //   {
  //     // Replace _selectedState and _emailController with the actual values
  //     final String selectedState = 'Your State'; // Replace with actual value
  //     final String adminEmail = 'admin@example.com'; // Replace with actual email
  //
  //     final userDoc = await FirebaseFirestore.instance
  //         .collection('Vote Chain')
  //         .doc('Admin')
  //         .collection(selectedState)
  //         .doc(adminEmail.trim())
  //         .collection('Profile')
  //         .doc('Details')
  //         .get();
  //
  //     if (userDoc.exists)
  //     { return userDoc.data()?['name'] ?? 'Admin'; } // Replace 'name' with the actual field name in your database
  //     else
  //     { return 'Admin'; }
  //   }
  //   catch (e)
  //   {
  //     print('Error fetching admin name: $e');
  //     SnackbarUtils.showErrorMessage(context, "Error fetching admin name: $e");
  //     return 'Admin';
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final dashboardItems = [
      {
        'title': 'Manage Elections',
        'icon': Icons.how_to_vote,
        'onTap': () => Navigator.pushNamed(context, '/ManageElection'),
      },
      {
        'title': 'Manage Party',
        'icon': Icons.group,
        'onTap': () => Navigator.pushNamed(context, '/ManagePartyApplication'),
      },
      {
        'title': 'View Results',
        'icon': Icons.bar_chart,
        'onTap': () => Navigator.pushNamed(context, '/ElectionResult'),
      },
      {
        'title': 'Logs & Reports',
        'icon': Icons.document_scanner,
        'onTap': () => Navigator.pushNamed(context, '/ReportDetails'),
      },
    ];

    // Fetching election details from the ElectionDetails singleton
    final electionDetails = ElectionDetails.instance;


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppConstants.appBarColor,
        elevation: 6,
        centerTitle: true,
        automaticallyImplyLeading: true, // Disable the back button if not needed
        actions: [
          // IconButton(
          //   icon: Icon(Icons.logout),
          //   onPressed: () {
          //     Navigator.pushReplacement(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => LoginScreen(),
          //       ),
          //     );
          //   },
          // ),
          LogoutButton( onPressed: () { Navigator.pushReplacementNamed(context, '/Login'); }, ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Election Details Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppConstants.primaryColor.withOpacity(0.5),
                    AppConstants.primaryColor.withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Display Election Details
                  Text(
                    'Election: ${electionDetails.electionType ?? 'Unknown'}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      // color: AppConstants.primaryColor,
                      color: Colors.grey[900],
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: AppConstants.primaryColor.withOpacity(0.3),
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'State: ${electionDetails.state ?? 'Unknown'}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[850],
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: AppConstants.primaryColor.withOpacity(0.3),
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Year: ${electionDetails.year ?? 'Unknown'}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[850],
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: AppConstants.primaryColor.withOpacity(0.3),
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Manage all operations for this election from this dashboard.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // Dashboard Grid
            Expanded(
              child: GridView.builder(
                physics: BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                ),
                itemCount: dashboardItems.length,
                itemBuilder: (context, index) {
                  final item = dashboardItems[index];
                  return _buildDashboardCard(
                    title: item['title'] as String,
                    icon: item['icon'] as IconData,
                    onTap: item['onTap'] as VoidCallback,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
        shadowColor: Colors.white,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppConstants.cardStartColor, AppConstants.cardEndColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
