import 'package:flutter/material.dart';

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate to the login page when the back button is pressed
            Navigator.pushReplacementNamed(context, '/Login');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, Admin',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                children: [
                  _buildDashboardCard(
                    context,
                    title: 'Manage Elections',
                    icon: Icons.how_to_vote,
                    onTap: () => Navigator.pushNamed(context, '/ManageElection'),
                  ),
                  _buildDashboardCard(
                    context,
                    title: 'Manage Candidates',
                    icon: Icons.person,
                    onTap: () => Navigator.pushNamed(context, '/ManageCandidate'),
                  ),
                  _buildDashboardCard(
                    context,
                    title: 'View Results',
                    icon: Icons.bar_chart,
                    onTap: () => Navigator.pushNamed(context, '/ElectionResult'),
                  ),
                  _buildDashboardCard(
                    context,
                    title: 'Logs & Reports',
                    icon: Icons.document_scanner,
                    onTap: () => Navigator.pushNamed(context, '/ReportDetails'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).primaryColor),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
