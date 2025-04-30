import 'package:flutter/material.dart';
import '../../SERVICE/utils/app_constants.dart';
import 'Review_View_Dashboard_candidate_applications.dart';
import 'Profile_party.dart'; // Import the correct screen
import 'Apply_Approval_Dashboard_party_application.dart';

class PartyHeadHome extends StatefulWidget {
  @override
  _PartyHeadHomeState createState() => _PartyHeadHomeState();
}

class _PartyHeadHomeState extends State<PartyHeadHome> {
  int _currentIndex = 0;
  String selectedState = "Some State"; // Example state that should be passed
  String selectedParty = "Some Party"; // Example party that should be passed

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve the state and party name passed from the login screen
    final arguments = ModalRoute.of(context)?.settings.arguments as Map?;
    if (arguments != null) {
      selectedState = arguments['stateName'] ?? "Maharashtra"; // Default fallback
      selectedParty = arguments['partyName'] ?? "Shivsena"; // Default fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pass the correct parameters to each tab
    final List<Widget> tabs = [
      ReviewCandidateApplication( partyName: selectedParty,  ), // Tab 1: Manage Candidates
      PartyApplicationForElection( stateName: selectedState, partyName: selectedParty, ), // Tab 2: Apply for Elections
      PartyProfile( stateName: selectedState,  partyName: selectedParty, ), // Tab 3: Party Profile
    ];

    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: AppConstants.appBarColor,
      //   title: const Text('Party Head Dashboard'),
      //   centerTitle: true,
      //   elevation: 0,
      // ),
      body: tabs[_currentIndex], // Render the selected tab's widget
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: AppConstants.primaryColor,
        selectedItemColor: Colors.white,
        unselectedItemColor: AppConstants.secondaryColor,
        items: const [
          BottomNavigationBarItem( icon: Icon(Icons.group), label: 'Review', ),
          BottomNavigationBarItem( icon: Icon(Icons.how_to_reg), label: 'Apply',  ),
          BottomNavigationBarItem( icon: Icon(Icons.account_circle),  label: 'Profile', ),
        ],
      ),
    );
  }
}
