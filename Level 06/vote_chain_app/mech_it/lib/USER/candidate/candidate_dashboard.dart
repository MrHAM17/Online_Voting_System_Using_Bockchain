import 'package:flutter/material.dart';
import '../../SERVICE/screen/report.dart';
import '../../SERVICE/screen/filter_fab.dart';
import '../../SERVICE/screen/report.dart';
import '../../SERVICE/screen/result.dart';
import '../../SERVICE/screen/sub_report.dart';
import '../../SERVICE/utils/app_constants.dart';

class CandidateDashboard extends StatefulWidget {
  const CandidateDashboard({Key? key}) : super(key: key);

  @override
  State<CandidateDashboard> createState() => _CandidateDashboardState();
}
class _CandidateDashboardState extends State<CandidateDashboard> with TickerProviderStateMixin {
  late TabController _tabController;
  String selectedYear = "";
  String selectedElectionType = "";
  String selectedState = "";
  List<Map<String, dynamic>> results = [];
  bool isLoading = false;
  bool filtersApplied = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void updateFilters(Map<String, String?> filters) {
    setState(() {
      selectedElectionType = filters['type']!;
      selectedYear = filters['year']!;
      selectedState = filters['state']!;
      filtersApplied = true;
    });
    print("Filters applied: Type: $selectedElectionType, Year: $selectedYear, State: $selectedState");
  }            // When filters are applied, simply update the state.


  @override
  Widget build(BuildContext context) {

    // Check if filters are applied (all fields non-empty)
    bool readyToShow = selectedYear.isNotEmpty && selectedElectionType.isNotEmpty && selectedState.isNotEmpty;
    if (filtersApplied) { print("\n*** 00 \n\n"); }           // For debugging: print outside the widget tree.

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Candidate Dashboard',
            style: TextStyle(
              fontSize: 20,                    // Font size for better visibility
              fontWeight: FontWeight.bold,     // Bold font for emphasis
              color: Colors.white,             // White color for better contrast
            ),
          ),
        ),
        backgroundColor: AppConstants.appBarColor,  // Use your custom color constant
        elevation: 4,                               // Add shadow for a modern look
        automaticallyImplyLeading: false,

        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.reviews),
                  SizedBox(width: 8),
                  Text('Result', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Tab(
              icon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_user_rounded),
                  SizedBox(width: 8),
                  Text('Report', style: TextStyle(fontWeight: FontWeight.bold)),
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
      /// only result tab
      // body
      //     : isLoading
      //     ? const Center(child: CircularProgressIndicator())
      //     : readyToShow
      //        ?  ElectionResultScreen(
      //             /*
      //               We create a key using a string composed of the filter values. When any filter changes,
      //               the key changes and Flutter will rebuild the ElectionResultScreen as a new widget.
      //               This clears any previously loaded data.
      //             */
      //             key: ValueKey("$selectedElectionType-$selectedState-$selectedYear"),
      //             electionType: selectedElectionType,
      //             state: selectedState,
      //             year: selectedYear,
      //             role: "Candidate_specificElectionViewingResult",
      //           )
      //         : const Center(
      //           child: Text(
      //           "No results to display.\nApply filters to view results.",
      //                 textAlign: TextAlign.center,
      //                 style: TextStyle(fontSize: 16),
      //               ),
      //           ),
      //       floatingActionButton: FilterFAB(
      //         role: "Candidate_specificElectionViewingResult",
      //         onFilterApplied: (filters) { updateFilters(filters); },
      //       ),
      /// report tab added along with result tab
      body: TabBarView(
        controller: _tabController,
        children: [

          // // First tab: Results.
          readyToShow
                      ? ElectionResultScreen(
                          /*
                              We create a key using a string composed of the filter values. When any filter changes,
                              the key changes and Flutter will rebuild the ElectionResultScreen as a new widget.
                              This clears any previously loaded data.
                          */
                          // key: ValueKey("$selectedElectionType-$selectedState-$selectedYear"),
                          key: ValueKey("result-$selectedElectionType-$selectedState-$selectedYear"),

                          electionType: selectedElectionType,
                          state: selectedState,
                          year: selectedYear,
                          role: "Candidate_specificElectionViewingResult",
                        )
                      : const Center(
                          child: Text(
                            "No results to display.\nApply filters to view results.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),

          // // Second tab: Report.
          readyToShow
                      ? ReportScreen(

                          // key: ValueKey("$selectedElectionType-$selectedState-$selectedYear"),
                          key: ValueKey("report-$selectedElectionType-$selectedState-$selectedYear"),

                          electionType: selectedElectionType,
                          state: selectedState,
                          year: selectedYear,
                          // role: "Candidate_specificElectionViewingReport",
                          role: "Candidate_electionViewReport",

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
      //   role: "Candidate_specificElectionViewingResult",
      //   onFilterApplied: updateFilters,
      // ),

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
              role: "Candidate_specificElectionViewingResult",
              onFilterApplied: updateFilters,
            );
          }
          // else
          //   // if (currentIndex == 1)
          // {
          //   fabRole = "Candidate_electionViewReport";
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
}
