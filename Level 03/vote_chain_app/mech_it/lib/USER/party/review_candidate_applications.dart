
import 'package:flutter/material.dart';
import 'package:mech_it/USER/party/review_approved_dashboard.dart';
import 'package:mech_it/USER/party/view_candidates_over_all_constituencies.dart';
import '../../SERVICE/utils/app_constants.dart';

class ReviewCandidateApplication extends StatefulWidget {
  final String partyName;
  const ReviewCandidateApplication({
    Key? key,
    required this.partyName,
  }) : super(key: key);

  @override
  _ReviewCandidateApplicationState createState() =>
      _ReviewCandidateApplicationState();
}

class _ReviewCandidateApplicationState extends State<ReviewCandidateApplication>
    with TickerProviderStateMixin
{
  late TabController _tabController;

  String? selectedYear;
  String? selectedState;
  String? selectedConstituency;
  List<Map<String, dynamic>> candidateApplications = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize the TabController with vsync
    _tabController = TabController(length: 2, vsync: this);
    // fetchApplications();  // Fetch applications when the screen is initialized
  }

  @override
  void dispose() {
    // Dispose of the TabController to avoid memory leaks
    _tabController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.secondaryColor.withOpacity(0.1),
      appBar: AppBar(
        title: Center(
          child: Text(
            'Manage Candidate Applications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: AppConstants.appBarColor,
        elevation: 4, // A subtle shadow for a clean, modern look
        automaticallyImplyLeading: false, // Disable the back button if not needed
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            // Tab(text: 'Review'),
            // Tab(text: 'View'),
            Tab(
              icon: Row(
                children: [
                  Icon(Icons.reviews),
                  SizedBox(width: 8),  // Space between the icon and the text
                  Text('Review', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Tab(
              icon: Row(
                children: [
                  Icon(Icons.verified_user_rounded),
                  SizedBox(width: 8),  // Space between the icon and the text
                  Text('Approved', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
          // Custom TabBar styling
          indicatorColor: Colors.white, // Color of the indicator (line under selected tab)
          labelColor: Colors.white, // Color of the selected tab text
          unselectedLabelColor: AppConstants.secondaryColor, // Color of unselected tab text
          indicatorWeight: 5.0, // Thickness of the indicator
          indicatorPadding: EdgeInsets.symmetric(horizontal: 8), // Padding for indicator
          labelStyle: TextStyle( fontWeight: FontWeight.bold, fontSize: 19 ),
          unselectedLabelStyle: TextStyle( fontWeight: FontWeight.normal, fontSize: 19),
          // Background color of the TabBar
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ReviewTab(partyName: widget.partyName),  // Pass the partyName here
          ViewTab(partyName: widget.partyName),  // Pass the partyName here
        ],
      ),

    );
  }
}

