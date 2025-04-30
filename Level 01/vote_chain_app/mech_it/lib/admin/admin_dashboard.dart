// import 'package:flutter/material.dart';
// import 'admin_service.dart';
// import 'election_management_screen.dart';
// import 'election_report.dart';
//
// class AdminDashboard extends StatefulWidget {
//   @override
//   _AdminDashboardState createState() => _AdminDashboardState();
// }
//
// class _AdminDashboardState extends State<AdminDashboard> {
//   final AdminService _adminService = AdminService();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Admin Dashboard'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.add),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => ElectionManagementScreen()),
//               );
//             },
//           ),
//         ],
//       ),
//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         future: _adminService.fetchAllElections(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (snapshot.hasData) {
//             List<Map<String, dynamic>> elections = snapshot.data!;
//             return ListView.builder(
//               itemCount: elections.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(elections[index]['name']),
//                   subtitle: Text('Status: ${elections[index]['status']}'),
//                   trailing: IconButton(
//                     icon: Icon(Icons.delete, color: Colors.red),
//                     onPressed: () async {
//                       String result = await _adminService.deleteElection(elections[index]['id']);
//                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
//                       setState(() {}); // Refresh the dashboard
//                     },
//                   ),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => ElectionReportScreen(electionId: elections[index]['id']),
//                       ),
//                     );
//                   },
//                 );
//               },
//             );
//           } else {
//             return Center(child: Text('No elections available'));
//           }
//         },
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'election_management_screen.dart';
import 'notification_management_screen.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = [
    ElectionManagement(),        // Assuming this is already implemented
    // ResultManagement(),          // Implement the ResultManagement widget
    NotificationManagementScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.how_to_vote), label: 'Elections'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Results'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
        ],
      ),
      body: _tabs[_selectedIndex],
    );
  }
}

class ResultManagement extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Results Management Screen'),
    );
  }
}
