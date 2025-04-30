
import 'package:flutter/material.dart';
import '../../SERVICE/utils/app_constants.dart';
import 'current_previous_elections.dart';
import 'eligible_elections.dart';
import 'reports.dart';

class CitizenHome extends StatefulWidget {
  @override
  _CitizenHomeState createState() => _CitizenHomeState();
}

class _CitizenHomeState extends State<CitizenHome> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    CurrentPreviousElections(),
    EligibleElections(),
    Reports(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vote Chain', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppConstants.appBarColor, // Use color from AppConstants
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.how_to_vote),
            label: 'Elections',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.how_to_reg),
            label: 'Vote',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
        ],
        selectedItemColor: AppConstants.selectedItemColor,  // Use color from AppConstants
        unselectedItemColor: AppConstants.unselectedItemColor, // Use color from AppConstants
      ),
    );
  }
}
