import 'package:flutter/material.dart';
import '../../SERVICE/screen/filter_fab.dart';
import '../../SERVICE/utils/app_constants.dart';

class Reports extends StatelessWidget {

  void updateFilters(Map<String, String?> filters) {
    // setState(() {
    //   selectedElectionType = filters['type'];
    //   selectedYear = filters['year'];
    //   selectedState = filters['state'];
    //   selectedConstituency = filters['constituency'];
    // });
    //
    // fetchApplications(); // Fetch applications based on the updated filters
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
          tabs: const [
              // Tab(text: 'Single Election'),
              // Tab(text: 'Comparison'),
              Tab(
                icon: Row(
                  children: [
                    Icon(Icons.insert_chart_rounded),
                    SizedBox(width: 8),  // Space between the icon and the text
                    Text('Overview', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Tab(
                icon: Row(
                  children: [
                    Icon(Icons.compare_arrows_rounded),
                    SizedBox(width: 8),  // Space between the icon and the text
                    Text('Compare', style: TextStyle(fontWeight: FontWeight.bold)),
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

          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildReportTab('Single Election', context),
                _buildReportTab('Comparison', context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportTab(String title, BuildContext context) {
    return Stack(
      children: [
        Center(child: Text('$title reports will be displayed here.')),
        FilterFAB(role: 'Citizen',
          onFilterApplied: (filters) {
            updateFilters(filters);
          },
        ),
      ],
    );
  }
}
