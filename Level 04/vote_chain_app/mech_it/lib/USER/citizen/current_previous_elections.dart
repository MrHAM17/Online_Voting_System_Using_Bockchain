// import 'package:flutter/material.dart';
// import '../../SERVICE/screen/filter_fab.dart';
// import '../../SERVICE/utils/app_constants.dart';
//
// class CurrentPreviousElections extends StatelessWidget {
//
//
//   void updateFilters(Map<String, String?> filters) {
//     // setState(() {
//     //   selectedElectionType = filters['type'];
//     //   selectedYear = filters['year'];
//     //   selectedState = filters['state'];
//     //   selectedConstituency = filters['constituency'];
//     // });
//     //
//     // fetchApplications(); // Fetch applications based on the updated filters
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2,
//       child: Column(
//         children: [
//           const TabBar(
//             tabs: [
//               // Tab(text: 'Current Elections'),
//               // Tab(text: 'Previous Elections'),
//               Tab(
//                 icon: Row(
//                   children: [
//                     Icon(Icons.today_rounded),
//                     SizedBox(width: 8),  // Space between the icon and the text
//                     Text('Current Elections', style: TextStyle(fontWeight: FontWeight.bold)),
//                   ],
//                 ),
//               ),
//               Tab(
//                 icon: Row(
//                   children: [
//                     Icon(Icons.history_rounded),
//                     SizedBox(width: 8),  // Space between the icon and the text
//                     Text('Previous Elections', style: TextStyle(fontWeight: FontWeight.bold)),
//                   ],
//                 ),
//               ),
//             ],
//             // Custom TabBar styling
//             indicatorColor: Colors.white, // Color of the indicator (line under selected tab)
//             labelColor: Colors.white, // Color of the selected tab text
//             unselectedLabelColor: AppConstants.secondaryColor, // Color of unselected tab text
//             indicatorWeight: 5.0, // Thickness of the indicator
//             indicatorPadding: EdgeInsets.symmetric(horizontal: 8), // Padding for indicator
//             labelStyle: TextStyle( fontWeight: FontWeight.bold, fontSize: 19 ),
//             unselectedLabelStyle: TextStyle( fontWeight: FontWeight.normal, fontSize: 19),
//           ),
//           Expanded(
//             child: TabBarView(
//               children: [
//                 _buildElectionList('Current Elections', context),
//                 _buildElectionList('Previous Elections', context),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildElectionList(String title, BuildContext context) {
//     return Stack(
//       children: [
//         Center(child: Text('$title will be displayed here.')),
//         FilterFAB(role: 'Citizen',
//           onFilterApplied: (filters) {
//             updateFilters(filters);
//           },
//         ),
//       ],
//     );
//   }
// }



///////////////////////////////////////////////////////////////////////////////   FLUTTER + BLOCKCHAIN CODE BELOW ---------->>>






import 'package:flutter/material.dart';
import '../../SERVICE/backend_connectivity/smart_contract_service.dart';
import '../../SERVICE/utils/app_constants.dart';
import '../../SERVICE/screen/filter_fab.dart';

class VoteScreen extends StatefulWidget {
  @override
  _VoteScreenState createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  final SmartContractService _contractService = SmartContractService();
  List<dynamic> candidates = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadCandidates();
  }

  Future<void> _loadCandidates() async {
    await _contractService.loadContract();
    final result = await _contractService.getCandidates();
    setState(() {
      candidates = result;
      loading = false;
    });
  }

  Future<void> _vote(int index) async {
    try {
      await _contractService.vote(index);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Vote casted successfully!")),
      );
      _loadCandidates(); // Refresh candidate list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vote for Candidate'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: loading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: candidates.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(candidates[index][0]), // Candidate name
                  trailing: ElevatedButton(
                    onPressed: () => _vote(index),
                    child: Text('Vote'),
                  ),
                );
              },
            ),
          ),
          Divider(height: 1, color: AppConstants.secondaryColor),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CurrentPreviousElections(), // Add Current Elections & Previous Elections tabs
          ),
        ],
      ),
    );
  }
}

class CurrentPreviousElections extends StatelessWidget {
  void updateFilters(Map<String, String?> filters) {
    // Apply filters when the user interacts with the FilterFAB
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(
                icon: Row(
                  children: [
                    Icon(Icons.today_rounded),
                    SizedBox(width: 8),
                    Text('Current Elections', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Tab(
                icon: Row(
                  children: [
                    Icon(Icons.history_rounded),
                    SizedBox(width: 8),
                    Text('Previous Elections', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: AppConstants.secondaryColor,
            indicatorWeight: 5.0,
            indicatorPadding: EdgeInsets.symmetric(horizontal: 8),
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 19),
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
        FilterFAB(
          role: 'Citizen',
          onFilterApplied: (filters) {
            updateFilters(filters);
          },
        ),
      ],
    );
  }
}
