import 'package:flutter/material.dart';
import '../../SERVICE/screen/filter_fab.dart';
import '../../SERVICE/utils/app_constants.dart';

class Reports extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: AppConstants.primaryColor,  // Use primaryColor from AppConstants
            unselectedLabelColor: AppConstants.secondaryColor,  // Use secondaryColor from AppConstants
            indicatorColor: AppConstants.primaryColor,  // Use primaryColor from AppConstants
            tabs: const [
              Tab(text: 'Single Election'),
              Tab(text: 'Comparison'),
            ],
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
        FilterFAB(),
      ],
    );
  }

}
