
import 'package:flutter/material.dart';
import '../../SERVICE/screen/filter_fab.dart';
import '../../SERVICE/screen/report.dart';
import '../../SERVICE/screen/result.dart';
import '../../SERVICE/utils/app_constants.dart';

class PartyResultDashboard extends StatefulWidget {
  const PartyResultDashboard({Key? key,}) : super(key: key);

  @override
  _PartyResultDashboardState createState() => _PartyResultDashboardState();
}

class _PartyResultDashboardState extends State<PartyResultDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Filter variables:
  String selectedYear = "";
  String selectedElectionType = "";
  String selectedState = "";
  bool isLoading = false;
  bool filtersApplied = false;

  // When filters are applied via the FAB, update the state.
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
    _tabController = TabController(length: 2, vsync: this);
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

    return Scaffold(
      backgroundColor: AppConstants.secondaryColor.withOpacity(0.1),
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Election Results',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: AppConstants.appBarColor,
        elevation: 4,
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
      body: TabBarView(
        controller: _tabController,
        children: [

          // // First tab: Results.
          readyToShow
                      ? ElectionResultScreen(
                          // Use a key so that changes in filters force a rebuild.
                          // key: ValueKey("$selectedElectionType-$selectedState-$selectedYear"),
                          key: ValueKey("result-$selectedElectionType-$selectedState-$selectedYear"),

                          electionType: selectedElectionType,
                          state: selectedState,
                          year: selectedYear,
                          // role: "PartyHead_specificElectionViewing",
                          role: "PartyHead_specificElectionViewingResult",
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
                      ?  ReportScreen(
                          // Use a key so that changes in filters force a rebuild.
                          // key: ValueKey("$selectedElectionType-$selectedState-$selectedYear"),
                          key: ValueKey("report-$selectedElectionType-$selectedState-$selectedYear"),

                          electionType: selectedElectionType,
                          state: selectedState,
                          year: selectedYear,
                          // role: "PartyHead_specificElectionViewingReport",
                          role: "PartyHead_electionViewReport",
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
      //   role: "PartyHead_specificElectionViewingResult",
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
              role: "PartyHead_specificElectionViewingResult",
              onFilterApplied: updateFilters,
            );
          }
          // else
          //   // if (currentIndex == 1)
          // {
          //   fabRole = "PartyHead_electionViewReport";
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
