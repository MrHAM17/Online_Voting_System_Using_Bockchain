import 'package:flutter/material.dart';
import '../../SERVICE/screen/filter_fab.dart';
import '../../SERVICE/utils/app_constants.dart';

class CurrentPreviousElections extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            labelColor: AppConstants.selectedItemColor, // Use the selectedItemColor from AppConstants
            unselectedLabelColor: AppConstants.unselectedItemColor, // Use the unselectedItemColor from AppConstants
            indicatorColor: AppConstants.selectedItemColor, // Use the selectedItemColor for the indicator
            tabs: [
              Tab(text: 'Current Elections'),
              Tab(text: 'Previous Elections'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildElectionList('Current Elections', context),
                _buildElectionList('Previous Elections', context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElectionList(String title, BuildContext context) {
    return Stack(
      children: [
        Center(child: Text('$title will be displayed here.')),
        FilterFAB(),
      ],
    );
  }

}
