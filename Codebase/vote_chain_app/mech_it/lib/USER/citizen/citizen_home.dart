//
// import 'package:flutter/material.dart';
// import '../../SERVICE/screen/styled_widget.dart';
// import '../../SERVICE/utils/app_constants.dart';
// import 'current_previous_elections.dart';
// import 'eligible_elections.dart';
// import 'elections_reports.dart';
//
// class CitizenHome extends StatefulWidget {
//   final String state;
//   final String email;
//
//   CitizenHome({required this.state, required this.email});
//   @override
//   _CitizenHomeState createState() => _CitizenHomeState();
// }
//
// class _CitizenHomeState extends State<CitizenHome> {
//   int _currentIndex = 0;
//
//   final List<Widget> _tabs = [
//     CurrentPreviousElections(),
//     EligibleElections(), // Pass stateName here
//     Reports(),
//   ];
//
//   void _onTabTapped(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(
//       //   title: const Text('Vote Chain', style: TextStyle(fontWeight: FontWeight.bold)),
//       //   centerTitle: true,
//       //   backgroundColor: AppConstants.appBarColor, // Use color from AppConstants
//       // ),
//       appBar: AppBar(
//         backgroundColor: AppConstants.appBarColor,
//         title: Center(
//           child: Text(
//             'Vote Chain',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//         ),
//         elevation: 6,
//         automaticallyImplyLeading: false,
//         actions: [ LogoutButton( onPressed: () { Navigator.pushReplacementNamed(context, '/Login'); }, ), ],
//       ),
//       body: _tabs[_currentIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: _onTabTapped,
//         items: const [
//           BottomNavigationBarItem(  icon: Icon(Icons.how_to_vote), label: 'Elections',  ),
//           BottomNavigationBarItem(  icon: Icon(Icons.how_to_reg), label: 'Vote', ),
//           BottomNavigationBarItem(  icon: Icon(Icons.bar_chart), label: 'Reports', ),
//         ],
//         selectedItemColor: AppConstants.selectedItemColor,  // Use color from AppConstants
//         unselectedItemColor: AppConstants.unselectedItemColor, // Use color from AppConstants
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import '../../SERVICE/screen/styled_widget.dart';
import '../../SERVICE/utils/app_constants.dart';
import 'citizen_profile.dart';
import 'current_previous_elections.dart';
import 'eligible_elections.dart';
import 'elections_reports.dart';

class CitizenHome extends StatefulWidget {
  final String state;
  final String email;

  CitizenHome({required this.state, required this.email});

  @override
  _CitizenHomeState createState() => _CitizenHomeState();
}

class _CitizenHomeState extends State<CitizenHome> {
  int _currentIndex = 0;

  // Create tabs list dynamically in the build method
  List<Widget> _getTabs() {
    return [
      CurrentPreviousElections(state: widget.state, email: widget.email),
      EligibleElections(state: widget.state, email: widget.email), // Pass stateName here
      Reports(),
      Profile(state: widget.state, email: widget.email)
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Center(
      //     child: Text(
      //       'Vote Chain',
      //       style: TextStyle(
      //         fontSize: 20,
      //         fontWeight: FontWeight.bold,
      //         color: Colors.white,
      //       ),
      //     ),
      //   ),
      //   backgroundColor: AppConstants.appBarColor,
      //   elevation: 4,
      //   automaticallyImplyLeading: false,
      //   actions: [
      //     LogoutButton(
      //       onPressed: () {
      //         Navigator.pushReplacementNamed(context, '/Login');
      //       },
      //     ),
      //   ],
      // ),
      body: _getTabs()[_currentIndex], // Use _getTabs to get the tabs dynamically
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        backgroundColor: AppConstants.primaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: AppConstants.secondaryColor,
        /*
          Solution:
          Force BottomNavigationBar Rendering with type: BottomNavigationBarType.fixed
          In some cases, Flutter uses a shifting effect when you have 4 or more tabs,
          which may cause the color disappearance. To prevent this, you need to force the fixed type rendering.
        */
        type: BottomNavigationBarType.fixed, // Add this line
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.how_to_vote), label: 'Elections'),
          BottomNavigationBarItem(icon: Icon(Icons.how_to_reg), label: 'Vote'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profile'),

        ],
        // selectedItemColor: AppConstants.selectedItemColor,
        // unselectedItemColor: AppConstants.unselectedItemColor,
      ),
    );
  }
}
