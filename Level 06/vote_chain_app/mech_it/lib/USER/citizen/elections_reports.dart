
import 'package:flutter/material.dart';
import '../../SERVICE/screen/filter_fab.dart';
import '../../SERVICE/screen/report.dart';
import '../../SERVICE/screen/sub_report.dart';
import '../../SERVICE/utils/app_constants.dart';

class Reports extends StatefulWidget {
  const Reports({Key? key}) : super(key: key);

  @override
  _ReportsState createState() => _ReportsState();
}

class _ReportsState extends State<Reports> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedYear = "";
  String selectedElectionType = "";
  String selectedState = "";
  bool isLoading = false;
  bool filtersApplied = false;

  void updateFilters(Map<String, String?> filters) {
    setState(() {
      selectedElectionType = filters['type'] ?? "";
      selectedYear = filters['year'] ?? "";
      selectedState = filters['state'] ?? "";
      filtersApplied = true;
    });
    print("Filters applied: Type: $selectedElectionType, Year: $selectedYear, State: $selectedState");
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);   // 2 tabs
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    // We consider filters ready when year, election type and state are non-empty.
    bool readyToShow = selectedYear.isNotEmpty && selectedElectionType.isNotEmpty && selectedState.isNotEmpty;
    if (filtersApplied) {
      print("\n*** Filters Applied ***\n");
    }

    // return DefaultTabController(
    return Scaffold(
      // backgroundColor: AppConstants.secondaryColor.withOpacity(0.1),
      appBar: AppBar(
        title: Center(
          child: Text(
            'Election Reports',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: AppConstants.appBarColor,
        // elevation: 4,
        automaticallyImplyLeading: false,
        // actions: [
        //   LogoutButton(
        //     onPressed: () {
        //       Navigator.pushReplacementNamed(context, '/Login');
        //     },
        //   ),
        // ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.insert_chart_rounded),
                  SizedBox(width: 8),
                  Text('Overview', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Tab(
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.compare_arrows_rounded),
                  SizedBox(width: 8),
                  Text('Compare', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: AppConstants.secondaryColor,
          indicatorWeight: 5.0,
          indicatorPadding: EdgeInsets.symmetric(horizontal: 8),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 19),
        ),
      ),
      //   body: DefaultTabController(
    //   length: 2,
    //   child: Column(
    //     children: [
    //       Container(
    //         color: AppConstants.appBarColor, // Set your custom teal color here
    //         child: const TabBar(
    //         tabs: [
    //             // Tab(text: 'Single Election'),
    //             // Tab(text: 'Comparison'),
    //             Tab(
    //               icon: Row(
    //                 children: [
    //                   Icon(Icons.insert_chart_rounded),
    //                   SizedBox(width: 8),  // Space between the icon and the text
    //                   Text('Overview', style: TextStyle(fontWeight: FontWeight.bold)),
    //                 ],
    //               ),
    //             ),
    //             Tab(
    //               icon: Row(
    //                 children: [
    //                   Icon(Icons.compare_arrows_rounded),
    //                   SizedBox(width: 8),  // Space between the icon and the text
    //                   Text('Compare', style: TextStyle(fontWeight: FontWeight.bold)),
    //                 ],
    //               ),
    //             ),
    //           ],
    //           // Custom TabBar styling
    //           indicatorColor: Colors.white, // Color of the indicator (line under selected tab)
    //           labelColor: Colors.white, // Color of the selected tab text
    //           unselectedLabelColor: AppConstants.secondaryColor, // Color of unselected tab text
    //           indicatorWeight: 5.0, // Thickness of the indicator
    //           indicatorPadding: EdgeInsets.symmetric(horizontal: 8), // Padding for indicator
    //           labelStyle: TextStyle( fontWeight: FontWeight.bold, fontSize: 19 ),
    //           unselectedLabelStyle: TextStyle( fontWeight: FontWeight.normal, fontSize: 19),
    //
    //         ),
    //       ),
    //       Expanded(
    //         child: TabBarView(
    //           children: [
    //             _buildReportTab('Single Election', context),
    //             _buildReportTab('Comparison', context),
    //           ],
    //         ),
    //       ),
    //     ],
    //   ),
    // ),
      body: TabBarView(
        controller: _tabController,
        children: [

          // // First tab: Report - overview.
          readyToShow
              ? ReportScreen(
                  // Use a key so that changes in filters force a rebuild.
                  // key: ValueKey("$selectedElectionType-$selectedState-$selectedYear"),
                  key: ValueKey("report_overview-$selectedElectionType-$selectedState-$selectedYear"),
                  electionType: selectedElectionType,
                  state: selectedState,
                  year: selectedYear,
                  role: "Citizen_electionOverviewReport",
                )
              : const Center(
                  child: Text(
                    "No results to display.\nApply filters to view results.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),

          // // Second tab: Sub Report - compare/detailed .
          readyToShow
              ? SubReportScreen(
                    // Use a key so that changes in filters force a rebuild.
                    // key: ValueKey("$selectedElectionType-$selectedState-$selectedYear"),
                    key: ValueKey("report_compare-$selectedElectionType-$selectedState-$selectedYear"),

                    electionType: selectedElectionType,
                    state: selectedState,
                    year: selectedYear,
                    role: "Citizen_electionsComparingReport",
                )
              : const Center(
                  child: Text(
                    "No report available.\nApply filters to view report.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
        ],
      ),

      // // The Scaffold's floatingActionButton automatically positions the FAB at bottom right.
      // floatingActionButton: FilterFAB(
      //   role: "Citizen_specificElectionViewingReport",
      //   onFilterApplied: updateFilters,
      // ),
      // Display a FAB based on the active tab.
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (context, child) {
          // Determine the current tab index.
          int currentIndex = _tabController.index;
          // Customize the role for each tab.
          String fabRole;
          if (currentIndex == 0) {
            // fabRole = "Citizen_electionOverviewReport";
            return FilterFAB(
              role: "Citizen_electionOverviewReport",
              onFilterApplied: updateFilters,
            );
          }
          // else
          //   // if (currentIndex == 1)
          // {
          //   fabRole = "Citizen_electionComparedDetailedReport";
          // }
          // return FilterFAB(
          //   role: fabRole,
          //   onFilterApplied: updateFilters,
          // );
          // Return empty container for other tabs
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // Widget _buildReportTab(String title, BuildContext context) {
  //   return Stack(
  //     children: [
  //       Center(child: Text('$title reports will be displayed here.', style: const TextStyle(fontSize: 16, color: Colors.grey),)),
  //       // FilterFAB(role: 'Citizen',
  //       //   onFilterApplied: (filters) {
  //       //     updateFilters(filters);
  //       //   },
  //       // ),
  //       // Wrap FilterFAB in Positioned so it appears at bottom right.
  //       Positioned(
  //         bottom: 16,
  //         right: 16,
  //         child: FilterFAB(
  //           role: 'Citizen',
  //           onFilterApplied: (filters) {
  //             updateFilters(filters);
  //           },
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
