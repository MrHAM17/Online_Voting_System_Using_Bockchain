
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../SERVICE/backend_connectivity/smart_contract_service.dart';
import '../../SERVICE/screen/result.dart';
import '../../SERVICE/screen/styled_widget.dart';
import '../../SERVICE/utils/app_constants.dart';
import '../../SERVICE/screen/filter_fab.dart';

/// Model to hold fetched election result with metadata
class ElectionResultInfo {
  final DocumentSnapshot doc;
  final String electionType;
  final String year;
  final String state;

  ElectionResultInfo({
    required this.doc,
    required this.electionType,
    required this.year,
    required this.state,
  });
}
class CurrentPreviousElections extends StatelessWidget {
  final String state;
  final String email;

  const CurrentPreviousElections({
    Key? key,
    required this.state,
    required this.email,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    // return DefaultTabController(
    return Scaffold(
      // backgroundColor: AppConstants.secondaryColor.withOpacity(0.1),
      appBar: AppBar(
        title: Center(
          child: Text(
            'Election & Result',
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
      ),
      body: DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // This container wraps the TabBar with the same background color as the AppBar.

          Container(
            // color: AppConstants.appBarColor,
            color: Colors.teal,
            child: const TabBar(
              tabs: [
                Tab(
                  icon: Row(
                    children: [
                      Icon(Icons.today_rounded),
                      SizedBox(width: 8),  // Space between the icon and the text
                      Text('Current', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Tab(
                  icon: Row(
                    children: [
                      Icon(Icons.history_rounded),
                      SizedBox(width: 8),  // Space between the icon and the text
                      Text('Previous', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: AppConstants.secondaryColor,
              indicatorWeight: 5.0, // Thickness of the indicator
              indicatorPadding: EdgeInsets.symmetric(horizontal: 8), // Padding for indicator
              labelStyle: TextStyle( fontWeight: FontWeight.bold, fontSize: 19 ),
              unselectedLabelStyle: TextStyle( fontWeight: FontWeight.normal, fontSize: 19),

            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                CurrentElectionsTab(state: state),
                // Center(child: Text('Previous Elections will be displayed here.')),
                PreviousElectionsTab(state: state,)
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }
}
class CurrentElectionsTab extends StatefulWidget {
  final String state;
  const CurrentElectionsTab({Key? key, required this.state}) : super(key: key);

  @override
  _CurrentElectionsTabState createState() => _CurrentElectionsTabState();
}
class _CurrentElectionsTabState extends State<CurrentElectionsTab> {
  List<ElectionResultInfo> elections = [];
  bool isLoading = true;
  String electionType = "";
  String selectedYear = AppConstants.getCurrentYear();

  // For expansion in party and constituency cards
  Map<String, bool> _expandedState = {};
  Map<String, bool> expandedConstituencies = {};
  Map<String, Map<String, dynamic>> constituencyWinners = {};

  @override
  void initState() {
    super.initState();
    // fetchOngoingElections();
  }

  // Helper Widget for Detail Rows
  Widget detailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 5),
          Text(value ?? 'N/A', style: TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
  Future<void> fetchOngoingElections() async {
    List<ElectionResultInfo> fetchedElections = [];

    try {
      // for (String electionType in AppConstants.electionTypes) {
      for (electionType in AppConstants.electionTypes) {
        // Trim and check for empty election type
        if (electionType.trim().isEmpty) continue;

        String adminPath = '';
        String fetchedResultPath = '';

        // Build paths based on the election type
        if (electionType == "General (Lok Sabha)" || electionType == "Council of States (Rajya Sabha)")
        {
          adminPath = "Vote Chain/Election/$selectedYear/$electionType/State/${widget.state}/Admin/Election Activity/";
          fetchedResultPath = "Vote Chain/Election/$selectedYear/$electionType/State/${widget.state}/Result/Fetched_Result/";
        } else if (electionType == "State Assembly (Vidhan Sabha)" || electionType == "Legislary Council (Vidhan Parishad)" || electionType == "Municipal" || electionType == "Panchayat")
        {
          adminPath = "Vote Chain/State/${widget.state}/Election/$selectedYear/$electionType/Admin/Election Activity/";
          fetchedResultPath = "Vote Chain/State/${widget.state}/Election/$selectedYear/$electionType/Result/Fetched_Result/";
        }
        else
        {
          // If this election type doesn't match any expected ones, skip it.
          print("Skipping unhandled election type: $electionType");
          continue;
        }

        // Debug print the path
        print("*** Admin Path: $adminPath");

        // Ensure adminPath is not empty before calling Firestore
        if (adminPath.isEmpty || fetchedResultPath.isEmpty) continue;

        // Fetch the Admin/Election Activity document
        DocumentSnapshot adminDoc = await FirebaseFirestore.instance.doc(adminPath).get();

        if (adminDoc.exists) {
          Map<String, dynamic> adminData = adminDoc.data() as Map<String, dynamic>;

          // Check if currentStage equals 7
          if (adminData['currentStage'] == 7) {
            print("\n*** Found election at: $adminPath with currentStage = 7");
            // Now fetch the Fetched_Result document that contains the votes data
            DocumentSnapshot fetchedResultDoc =
            await FirebaseFirestore.instance.doc(fetchedResultPath).get();

            print("*** $fetchedResultPath");
            if (fetchedResultDoc.exists && fetchedResultDoc.data() != null) {
              fetchedElections.add(
                ElectionResultInfo(
                  doc: fetchedResultDoc,
                  electionType: electionType,
                  year: selectedYear,
                  state: widget.state,
                ),
              );
              print("*** Adding");
            }
            else
            {
              print("No Fetched_Result doc at: $fetchedResultPath");
            }
          }
        }
      }

      setState(() {
        elections = fetchedElections;
        print("**** Fetched elections: $elections");
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching election results: $e");
      setState(() {
        elections = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    /// working perfectly
    // if (isLoading) {
    //   return Center(child: CircularProgressIndicator());
    // }
    // if (elections.isEmpty) {
    //   return Center(child: Text("No elections found."));
    // }
    // return ListView.builder(
    //   itemCount: elections.length,
    //   itemBuilder: (context, index) {
    //     final electionInfo = elections[index];
    //     // Convert document data to a Map
    //     final resultData =
    //     Map<String, dynamic>.from(electionInfo.doc.data() as Map);
    //     return _buildElectionCard(resultData, electionInfo);
    //   },
    // );
    /// but trying to use via common code
    if (isLoading)  { Center(child: CircularProgressIndicator()); }
    print("\n*** 00 $electionType");

    return ElectionResultScreen(
      electionType: "$electionType", // or any dynamic value
      state: "${widget.state}",                   // example state
      year: "$selectedYear", // example year
      role: "Citizen_Current_Election",
    );
  }

  /// Build the main election card using metadata
  Widget _buildElectionCard(Map<String, dynamic> resultData, ElectionResultInfo info) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Header with gradient background and professional styling
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.shade400, Colors.teal.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Center(
                      child: Text(
                        "${info.electionType}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 4),
                  Center(
                    child: Text(
                      "State: ${info.state}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 4),
                  Center(
                    child: Text(
                      "Year: ${info.year}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Body using an ExpansionTile for details
            ExpansionTile(
              tilePadding: EdgeInsets.symmetric(horizontal: 16),
              childrenPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 12),
              // Hide the default title of the ExpansionTile since we already have a header
              title: SizedBox.shrink(),
              children: [
                _buildElectionSummaryCard(resultData),
                SizedBox(height: 20),
                // Divider(color: Colors.black,),
                _buildPartyResultsCard(resultData),
                SizedBox(height: 20),
                // Divider(color: Colors.black,),
                _buildConstituencyResultsCard(resultData),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// UI Card 1: Election Summary Card
  Widget _buildElectionSummaryCard(Map<String, dynamic> resultData) {
    // Retrieve the votes map
    final votesMap = (resultData['votes'] as Map<String, dynamic>?) ?? {};

    // Count candidates per party
    Map<String, int> partyCandidatesCount = {};
    votesMap.forEach((candidateId, candidateData) {
      Map<String, dynamic> candidate = Map<String, dynamic>.from(candidateData);
      candidate['candidateId'] = candidateId;
      String party = candidate['party'] ?? 'Unknown';
      partyCandidatesCount[party] = (partyCandidatesCount[party] ?? 0) + 1;
    });

    // Convert map entries to list and sort by party name alphabetically
    final sortedEntries = partyCandidatesCount.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      // color: Colors.teal.shade200,
      // color: Colors.indigo.shade100,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade200, Colors.teal.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        borderRadius: BorderRadius.circular(10),
        ),
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Election Summary",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 12),
            ...sortedEntries.map((entry) => Text(
              "${entry.key}: ${entry.value} candidates",
              style: TextStyle(fontSize: 16),
            )),
          ],
        ),
      ),
      ),
    );
  }

  /// UI Card 2: Party Results Card
  Widget _buildPartyResultsCard(Map<String, dynamic> resultData) {
    // Retrieve the votes map from the resultData
    final votesMap = (resultData['votes'] as Map<String, dynamic>?) ?? {};

    // Group candidates by party
    Map<String, List<Map<String, dynamic>>> partyResults = {};
    votesMap.forEach((candidateId, candidateData) {
      Map<String, dynamic> candidate = Map<String, dynamic>.from(candidateData);
      candidate['candidateId'] = candidateId;
      String party = candidate['party'] ?? 'Unknown';
      if (!partyResults.containsKey(party)) {
        partyResults[party] = [];
      }
      partyResults[party]!.add(candidate);
    });

    // Sort party names alphabetically
    List<String> parties = partyResults.keys.toList()..sort();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      // color: Colors.teal.shade200,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade200, Colors.teal.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          ),

        child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: parties.map((party) {
            bool isExpanded = _expandedState[party] ?? false;
            // Sort candidates by constituency alphabetically
            List<Map<String, dynamic>> candidates = List.from(partyResults[party]!);
            candidates.sort((a, b) =>
                (a["constituency"] as String).compareTo(b["constituency"] as String));
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: EdgeInsets.symmetric(vertical: 5),
              child: Column(
                children: [
                  // Party Header Tile
                  ListTile(
                    tileColor: Colors.white,
                    title: Text(
                      "Party: $party",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          _expandedState[party] = !isExpanded;
                        });
                      },
                    ),
                  ),

                  // Candidate List (Only visible when expanded)
                  if (isExpanded)
                    Column(
                      children: candidates.map((candidateData) {
                        return Card(
                          color: Colors.indigo.shade100,
                          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Row with Photo and Name & Email
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Candidate Profile Photo
                                    Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        // color: Colors.teal.shade200,
                                        // gradient: LinearGradient(
                                        //   colors: [Colors.teal.shade200, Colors.teal.shade600],
                                        //   begin: Alignment.topLeft,
                                        //   end: Alignment.bottomRight,
                                        // ),
                                        gradient: LinearGradient(
                                          colors: [Colors.teal.shade300, Colors.indigo.shade400],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        // gradient: LinearGradient(
                                        //   colors: [Colors.tealAccent.shade400, Colors.teal.shade800],
                                        //   begin: Alignment.topLeft,
                                        //   end: Alignment.bottomRight,
                                        // ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(Icons.person, color: Colors.white, size: 40),
                                    ),
                                    SizedBox(width: 12),

                                    // Name and Email Column
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            candidateData["name"] ?? 'N/A',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            candidateData["constituency"] ?? 'N/A',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis, // Prevents overflow
                                            maxLines: 1, // Keeps it in one line
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 10), // Space before other details
                                Divider(color: Colors.grey),

                                // Candidate Details List
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    detailRow("Age:", candidateData["age"]?.toString()),
                                    detailRow("Gender:", candidateData["gender"]),
                                    detailRow("Education:", candidateData["education"]),
                                    detailRow("Profession:", candidateData["profession"]),
                                    detailRow("Home State:", candidateData["candidateHomeState"]),
                                    detailRow("Email:", candidateData["candidateId"]),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      ),
    );
  }

  /// UI Card 3: Constituency Results Card
  Widget _buildConstituencyResultsCard(Map<String, dynamic> resultData) {
    // Retrieve the votes map from resultData.
    final votesMap = (resultData['votes'] as Map<String, dynamic>?) ?? {};
    Map<String, List<Map<String, dynamic>>> constituencyResults = {};

    // Group candidates by their constituency.
    votesMap.forEach((candidateId, candidateData) {
      Map<String, dynamic> candidate = Map<String, dynamic>.from(candidateData);
      candidate['candidateId'] = candidateId;
      String constituency = candidate['constituency'] ?? 'Unknown';
      if (!constituencyResults.containsKey(constituency)) {
        constituencyResults[constituency] = [];
      }
      constituencyResults[constituency]!.add(candidate);
    });

    // Sort constituencies alphabetically.
    List<String> constituencies = constituencyResults.keys.toList()..sort();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      // color: Colors.teal.shade200,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade200, Colors.teal.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
          children: constituencies.map((constituency) {
            // Get and sort candidates within this constituency by party name and candidate name.
            List<Map<String, dynamic>> candidates = List.from(constituencyResults[constituency]!);
            candidates.sort((a, b) {
              String partyA = (a["party"] ?? "").toString();
              String partyB = (b["party"] ?? "").toString();
              int cmp = partyA.compareTo(partyB);
              if (cmp != 0) return cmp;
              return (a["name"] ?? "").toString().compareTo((b["name"] ?? "").toString());
            });
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: EdgeInsets.symmetric(vertical: 5),
              child: Column(
                children: [
                  // Constituency Header
                  ListTile(
                    tileColor: Colors.white,
                    title: Text(
                      "Constituency: $constituency",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        expandedConstituencies[constituency] == true
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          expandedConstituencies[constituency] =
                          !(expandedConstituencies[constituency] ?? false);
                        });
                      },
                    ),
                  ),
                  // Candidate Details (if expanded)
                  if (expandedConstituencies[constituency] == true)
                    Column(
                      children: candidates.map((candidateData) {
                        return Card(
                          color: Colors.indigo.shade100,
                          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Row with photo and Name & Candidate ID
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Candidate Profile Photo
                                    Container(
                                      width: 70,
                                      height: 70,
                                      decoration: BoxDecoration(
                                        // color: Colors.teal.shade200,
                                        // color: Colors.teal.shade500,
                                        gradient: LinearGradient(
                                          colors: [Colors.teal.shade300, Colors.indigo.shade400],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(Icons.person, color: Colors.white, size: 40),
                                    ),
                                    SizedBox(width: 12),
                                    // Name and Candidate ID Column
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            candidateData["name"] ?? 'N/A',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                              "${candidateData["party"] ?? 'N/A'}",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              )
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Divider(color: Colors.grey),
                                // Additional details in a clean layout
                                detailRow("Age:", candidateData["age"]?.toString()),
                                detailRow("Gender:", candidateData["gender"]),
                                detailRow("Education:", candidateData["education"]),
                                detailRow("Profession:", candidateData["profession"]),
                                detailRow("Home State:", candidateData["candidateHomeState"]),
                                detailRow("Email:", candidateData["candidateId"]),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      ),
    );
  }
}
class PreviousElectionsTab extends StatefulWidget {
  final String state;

  const PreviousElectionsTab({Key? key, required this.state}) : super(key: key);

  @override
  _PreviousElectionsTabState createState() => _PreviousElectionsTabState();
}
class _PreviousElectionsTabState extends State<PreviousElectionsTab> {
  String selectedYear = "";
  String selectedElectionType = "";
  String selectedState = "";
  bool isLoading = true;
  bool filtersApplied = false;

  void updateFilters(Map<String, String?> filters) {
    setState(() {
      selectedElectionType = filters['type']!;
      selectedYear = filters['year']!;
      selectedState = filters['state']!;
      // selectedConstituency = filters['constituency'];
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
      // Use an empty Container or your placeholder content here.
      // body: Container(),
      body: readyToShow
                        ? ElectionResultScreen(
                            key: ValueKey("result-$selectedElectionType-$selectedState-$selectedYear"),
                            electionType: selectedElectionType,
                            state: selectedState,
                            year: selectedYear,
                            role: "Citizen_specificPreviousElectionViewingResult",
                          )
                        : const Center(
                            child: Text(
                              "Apply filters to view election & result.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
      floatingActionButton: FilterFAB(
        // // role: 'Citizen_Previous_Ellection',
        role: 'Citizen_specificPreviousElectionViewingResult',
        onFilterApplied: ( filters) {
          updateFilters(filters);
        },
      ),
    );
  }
}



