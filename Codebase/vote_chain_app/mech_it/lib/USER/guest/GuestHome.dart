
import 'package:flutter/material.dart';
import '../../Future Apply[ (reg) & no login ]/login.dart';
import '../../SERVICE/screen/filter_fab.dart';
import '../../SERVICE/screen/report.dart';
import '../../SERVICE/screen/result.dart';
import '../../SERVICE/screen/styled_widget.dart';
import '../../SERVICE/screen/sub_report.dart';
import '../../SERVICE/utils/app_constants.dart';


void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: GuestHome(),
  ));
}
class GuestHome extends StatelessWidget {
  const GuestHome({Key? key}) : super(key: key);

  void _navigateToResults(BuildContext context)
  { Navigator.push(context,MaterialPageRoute(builder: (context) => const ResultsScreen()), ); }
  void _navigateToReports(BuildContext context)
  { Navigator.push(context,MaterialPageRoute(builder: (context) => const ReportsScreen()), ); }
  void _navigateToDetailedReport(BuildContext context)
  { Navigator.push(context,MaterialPageRoute(builder: (context) => const DetailedReportScreen()), ); }

  void _navigateToNotifications(BuildContext context)
  {
    // Navigator.push(context,MaterialPageRoute(builder: (context) => const DetailedReportScreen()), );
  }

  /// Builds each dashboard card with a gradient background.
  Widget _buildDashboardCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 8,
        shadowColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                // AppConstants.primaryColor,  // .withOpacity(0.5)
                // AppConstants.primaryColor.withOpacity(0.6),   // .withOpacity(0.3)
                AppConstants.cardStartColor, AppConstants.cardEndColor   // same as admin dashboard
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardItems = [
      {
        'title': 'Results',
        'icon': Icons.bar_chart,
        'onTap': () => _navigateToResults(context),
      },
      {
        'title': 'Report',
        'icon': Icons.insert_chart,
        'onTap': () => _navigateToReports(context),
      },
      {
        'title': 'Detailed Report',
        'icon': Icons.assignment,
        'onTap': () => _navigateToDetailedReport(context),
      },
      {
        'title': 'Notifications',
        'icon': Icons.notifications_active,   // Icons.notifications
        'onTap': () => _navigateToNotifications(context),
      },
    ];

    // return Scaffold(
    //   backgroundColor: Colors.white,
    //   appBar: AppBar(
    //     title: Text(
    //       'Guest Dashboard',
    //       style: TextStyle(
    //         fontSize: 22,
    //         fontWeight: FontWeight.bold,
    //         color: Colors.white,
    //       ),
    //     ),
    //     backgroundColor: AppConstants.appBarColor,
    //     elevation: 6,
    //     centerTitle: true,
    //     automaticallyImplyLeading: true, // Disable the back button if not needed
    //     // actions: [
    //     //   // IconButton(
    //     //   //   icon: Icon(Icons.logout),
    //     //   //   onPressed: () {
    //     //   //     Navigator.pushReplacement(
    //     //   //       context,
    //     //   //       MaterialPageRoute(
    //     //   //         builder: (context) => LoginScreen(),
    //     //   //       ),
    //     //   //     );
    //     //   //   },
    //     //   // ),
    //     //   LogoutButton( onPressed: () { Navigator.pushReplacementNamed(context, '/Login'); }, ),
    //     // ],
    //   ),
    //   body: Padding(
    //     padding: const EdgeInsets.all(20.0),
    //     child: Column(
    //       children: [
    //         // Welcome Section Container
    //         Container(
    //           width: double.infinity,
    //           padding: const EdgeInsets.all(16),
    //           margin: const EdgeInsets.only(bottom: 20),
    //           decoration: BoxDecoration(
    //             gradient: LinearGradient(
    //               colors: [
    //                 AppConstants.primaryColor.withOpacity(0.7),
    //                 AppConstants.primaryColor,
    //               ],
    //               begin: Alignment.topLeft,
    //               end: Alignment.bottomRight,
    //             ),
    //             borderRadius: BorderRadius.circular(12),
    //           ),
    //           child: Column(
    //             crossAxisAlignment: CrossAxisAlignment.center,
    //             children: const [
    //               Text(
    //                 'Welcome !',
    //                 style: TextStyle(
    //                   fontSize: 20,
    //                   fontWeight: FontWeight.bold,
    //                   color: Colors.white,
    //                 ),
    //                 textAlign: TextAlign.center,
    //               ),
    //               SizedBox(height: 8),
    //               Text(
    //                 'Explore the election results, reports & detailed reports here.\n\n'
    //                     "Explore Verified Election Data:\n"
    //                     "Seamlessly access current and historical outcomes, comprehensive reports, and blockchain-certified insights that elevate electoral transparency to unprecedented levels.\n\n"
    //
    //                     "Monitor Live Electoral Trends:\n"
    //                     "Experience real-time updates and granular, constituency-level breakdowns powered by the precision of smart contract technology.\n\n"
    //
    //                     "Audit with Immutable Records:\n"
    //                     "Access cryptographic proofs and official declarations that ensure every vote is indelibly recorded and fully auditable.\n\n",
    //
    //                 style: TextStyle(
    //                   fontSize: 16,
    //                   color: Colors.white,
    //                 ),
    //                 textAlign: TextAlign.center,
    //               ),
    //             ],
    //           ),
    //         ),
    //         // Dashboard Grid
    //         Expanded(
    //           child: GridView.builder(
    //             physics: const BouncingScrollPhysics(),
    //             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    //               crossAxisCount: 2,
    //               crossAxisSpacing: 16.0,
    //               mainAxisSpacing: 16.0,
    //             ),
    //             itemCount: dashboardItems.length,
    //             itemBuilder: (context, index) {
    //               final item = dashboardItems[index];
    //               return _buildDashboardCard(
    //                 title: item['title'] as String,
    //                 icon: item['icon'] as IconData,
    //                 onTap: item['onTap'] as VoidCallback,
    //               );
    //             },
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LoginScreen(),
              ),
            );
          },
        ),
        title: Text(
          'Guest Dashboard',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppConstants.appBarColor,
        elevation: 6,
        centerTitle: true,
        // automaticallyImplyLeading: true, // Disable the back button if not needed

        // actions: [
        //   // IconButton(
        //   //   icon: Icon(Icons.logout),
        //   //   onPressed: () {
        //   //     Navigator.pushReplacement(
        //   //       context,
        //   //       MaterialPageRoute(
        //   //         builder: (context) => LoginScreen(),
        //   //       ),
        //   //     );
        //   //   },
        //   // ),
        //   LogoutButton( onPressed: () { Navigator.pushReplacementNamed(context, '/Login'); }, ),
        // ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Welcome Section Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppConstants.primaryColor.withOpacity(0.7),
                      AppConstants.primaryColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Text(
                      'Welcome !',
                      style: TextStyle(
                        fontSize: 20,  // 20
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    // Text(
                    //   // 'Explore the election results, reports & detailed reports here.\n\n'
                    //
                    //       "Explore Verified Election Data:\n"
                    //       "Seamlessly access current and historical outcomes, comprehensive reports, and blockchain-certified insights that elevate electoral transparency to unprecedented levels.\n\n"
                    //       "Monitor Live Electoral Trends:\n"
                    //       "Experience real-time updates and granular, constituency-level breakdowns powered by the precision of smart contract technology.\n\n"
                    //       "Audit with Immutable Records:\n"
                    //       "Access cryptographic proofs and official declarations that ensure every vote is indelibly recorded and fully auditable.\n\n",
                    //   style: TextStyle(
                    //     fontSize: 16,
                    //     color: Colors.white,
                    //   ),
                    //   textAlign: TextAlign.center,
                    // ),
                    Text(
                      '\nExplore Verified Election Data:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, ),textAlign: TextAlign.center,
                    ),
                    Text(
                      "Seamlessly access current and historical outcomes, comprehensive reports, and blockchain-certified insights that elevate electoral transparency to unprecedented levels.\n\n",
                           style: TextStyle( fontSize: 16, color: Colors.white,), textAlign: TextAlign.center,
                    ),
                    Text(
                      'Monitor Live Electoral Trends:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, ),textAlign: TextAlign.center,
                    ),
                    Text(
                      "Experience real-time updates and granular, constituency-level breakdowns powered by the precision of smart contract technology.\n\n",
                      style: TextStyle( fontSize: 16, color: Colors.white,), textAlign: TextAlign.center,
                    ),
                    Text(
                      'Audit with Immutable Records:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, ),textAlign: TextAlign.center,
                    ),
                    Text(
                      "Access cryptographic proofs and official declarations that ensure every vote is indelibly recorded and fully auditable.\n\n",
                      style: TextStyle( fontSize: 16, color: Colors.white,), textAlign: TextAlign.center,
                    ),

                  ],
                ),
              ),
              // Dashboard Grid as non-scrollable within SingleChildScrollView
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                ),
                itemCount: dashboardItems.length,
                itemBuilder: (context, index) {
                  final item = dashboardItems[index];
                  return _buildDashboardCard(
                    title: item['title'] as String,
                    icon: item['icon'] as IconData,
                    onTap: item['onTap'] as VoidCallback,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );

  }
}


class ResultsScreen extends StatefulWidget {
  const ResultsScreen({Key? key}) : super(key: key);

  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}
class _ResultsScreenState extends State<ResultsScreen> {
  String selectedYear = "";
  String selectedElectionType = "";
  String selectedState = "";
  bool filtersApplied = false;

  /// Called when filters are applied from the FilterFAB.
  void updateFilters(Map<String, String?> filters) {
    setState(() {
      selectedElectionType = filters['type']!;
      selectedYear = filters['year']!;
      selectedState = filters['state']!;
      filtersApplied = true;
    });
    print(
        "Filters applied: Type: $selectedElectionType, Year: $selectedYear, State: $selectedState");
  }

  @override
  Widget build(BuildContext context) {
    // Check if all filter fields are provided.
    bool readyToShow = selectedYear.isNotEmpty && selectedElectionType.isNotEmpty && selectedState.isNotEmpty;
    if (filtersApplied) { print("\n*** Filters updated ***\n");  }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Results',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppConstants.appBarColor,
        elevation: 6,
        centerTitle: true,
        automaticallyImplyLeading: true, // Disable the back button if not needed
        // actions: [
        //   // IconButton(
        //   //   icon: Icon(Icons.logout),
        //   //   onPressed: () {
        //   //     Navigator.pushReplacement(
        //   //       context,
        //   //       MaterialPageRoute(
        //   //         builder: (context) => LoginScreen(),
        //   //       ),
        //   //     );
        //   //   },
        //   // ),
        //   LogoutButton( onPressed: () { Navigator.pushReplacementNamed(context, '/Login'); }, ),
        // ],
      ),
      body: readyToShow
          ? ElectionResultScreen(
              key: ValueKey("result-$selectedElectionType-$selectedState-$selectedYear"),
              electionType: selectedElectionType,
              state: selectedState,
              year: selectedYear,
              role: "Guest_specificElectionViewingResult",
            )
          : const Center(
              child: Text(
                "No results to display.\nApply filters to view results.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            floatingActionButton: FilterFAB(
              role: 'Guest_specificElectionViewingResult',
              onFilterApplied: (filters) {
                updateFilters(filters);
              },
            ),
    );
  }
}


class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}
class _ReportsScreenState extends State<ReportsScreen> {
  String selectedYear = "";
  String selectedElectionType = "";
  String selectedState = "";
  bool filtersApplied = false;

  /// Called when filters are applied from the FilterFAB.
  void updateFilters(Map<String, String?> filters) {
    setState(() {
      selectedElectionType = filters['type']!;
      selectedYear = filters['year']!;
      selectedState = filters['state']!;
      filtersApplied = true;
    });
    print(
        "Filters applied: Type: $selectedElectionType, Year: $selectedYear, State: $selectedState");
  }

  @override
  Widget build(BuildContext context) {
    // Check if all filter fields are provided.
    bool readyToShow = selectedYear.isNotEmpty && selectedElectionType.isNotEmpty && selectedState.isNotEmpty;
    if (filtersApplied) { print("\n*** Filters updated ***\n");  }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppConstants.appBarColor,
        elevation: 6,
        centerTitle: true,
        automaticallyImplyLeading: true, // Disable the back button if not needed
        // actions: [
        //   // IconButton(
        //   //   icon: Icon(Icons.logout),
        //   //   onPressed: () {
        //   //     Navigator.pushReplacement(
        //   //       context,
        //   //       MaterialPageRoute(
        //   //         builder: (context) => LoginScreen(),
        //   //       ),
        //   //     );
        //   //   },
        //   // ),
        //   LogoutButton( onPressed: () { Navigator.pushReplacementNamed(context, '/Login'); }, ),
        // ],
      ),
      body: readyToShow
                ? ReportScreen(
                    key: ValueKey("report_overview-$selectedElectionType-$selectedState-$selectedYear"),
                    electionType: selectedElectionType,
                    state: selectedState,
                    year: selectedYear,
                    role: "Guest_electionOverviewReport",
                  )
                : const Center(
                    child: Text(
                      "No report to display.\nApply filters to view report.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
      floatingActionButton: FilterFAB(
        role: 'Guest_electionOverviewReport',
        onFilterApplied: (filters) {
          updateFilters(filters);
        },
      ),
    );
  }
}


class DetailedReportScreen extends StatefulWidget {
  const DetailedReportScreen({Key? key}) : super(key: key);

  @override
  _DetailedReportScreenState createState() => _DetailedReportScreenState();
}
class _DetailedReportScreenState extends State<DetailedReportScreen> {
  String selectedYear = "";
  String selectedElectionType = "";
  String selectedState = "";
  bool filtersApplied = false;

  /// Called when filters are applied from the FilterFAB.
  void updateFilters(Map<String, String?> filters) {
    setState(() {
      selectedElectionType = filters['type']!;
      selectedYear = filters['year']!;
      selectedState = filters['state']!;
      filtersApplied = true;
    });
    print(
        "Filters applied: Type: $selectedElectionType, Year: $selectedYear, State: $selectedState");
  }

  @override
  Widget build(BuildContext context) {
    // Check if all filter fields are provided.
    bool readyToShow = selectedYear.isNotEmpty && selectedElectionType.isNotEmpty && selectedState.isNotEmpty;
    if (filtersApplied) { print("\n*** Filters updated ***\n");  }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detailed Report',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppConstants.appBarColor,
        elevation: 6,
        centerTitle: true,
        automaticallyImplyLeading: true, // Disable the back button if not needed
        // actions: [
        //   // IconButton(
        //   //   icon: Icon(Icons.logout),
        //   //   onPressed: () {
        //   //     Navigator.pushReplacement(
        //   //       context,
        //   //       MaterialPageRoute(
        //   //         builder: (context) => LoginScreen(),
        //   //       ),
        //   //     );
        //   //   },
        //   // ),
        //   LogoutButton( onPressed: () { Navigator.pushReplacementNamed(context, '/Login'); }, ),
        // ],
      ),
      body: readyToShow
                ? SubReportScreen(
                    key: ValueKey("report_compare-$selectedElectionType-$selectedState-$selectedYear"),
                    electionType: selectedElectionType,
                    state: selectedState,
                    year: selectedYear,
                    role: "Guest_electionsDetailedReport",
                  )
                : const Center(
                    child: Text(
                      "No detailed report to display.\nApply filters to view results.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
      floatingActionButton: FilterFAB(
        role: 'Guest_electionsDetailedReport',
        onFilterApplied: (filters) {
          updateFilters(filters);
        },
      ),
    );
  }
}

