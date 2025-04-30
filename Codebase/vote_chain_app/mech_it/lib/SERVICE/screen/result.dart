

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mech_it/SERVICE/screen/styled_widget.dart';
import '../utils/app_constants.dart';

class ElectionResultScreen extends StatefulWidget {
  final String electionType;
  final String state;
  final String year;
  final String role;

  const ElectionResultScreen({
    Key? key,
    required this.electionType,
    required this.state,
    required this.year,
    required this.role,
  }) : super(key: key);

  @override
  _ElectionResultScreenState createState() => _ElectionResultScreenState();
}
class _ElectionResultScreenState extends State<ElectionResultScreen> {
  bool isLoading = true;

  // // Used for stopped elections.
  // bool hasTies = false;
  // int threshold = 0;
  // String overallWinningParty = "";
  // Map<String, dynamic>? electionMetadata; // Populated in fetchElectionResults()
  // // Data maps for stopped election results.
  // Map<String, int> partyWins = {};
  // Map<String, List<Map<String, dynamic>>> partyResults = {};
  // Map<String, List<Map<String, dynamic>>> constituencyResults = {};
  // Map<String, Map<String, dynamic>> constituencyWinners = {};
  Map<String, bool> _expandedState = {};
  Map<String, bool> expandedConstituencies = {};

  // // Data list for ongoing elections.
  // List<Map<String, dynamic>> ongoingElectionsData = [];
  // List<ElectionResultInfo> elections = [];
  List<ElectionResultInfo> fetchedElections = [];
  int currentStage = 0 ;
  late Future<List<BaseElectionResult>> electionStatusFuture;

  @override
  void initState() {
    super.initState();

    ///
    // checkElectionStatus();  // Instead of relying on a passed status, we check the status right here.
    /// better approach
    // electionStatusFuture = checkElectionStatus();      // Instead of calling fetchOngoingElections() directly, assign the future.
    ///
    if
    (
      widget.role == "Citizen_Current_Election" ||
      widget.role == "PartyHead_allElectionViewing" ||  widget.role == "Candidate_allElectionViewing"  ||  widget.role == "Guest_allElectionViewing"
    )
    { electionStatusFuture = fetchAllElectionsData();  }  // Aggregating elections from all types --> for particular year, state.
    else if
    (
      widget.role == "Citizen_specificPreviousElectionViewingResult" || widget.role == "Admin" ||
      widget.role == "PartyHead_specificElectionViewingResult" ||  widget.role == "Candidate_specificElectionViewingResult" ||  widget.role == "Guest_specificElectionViewingResult"
    )
    { electionStatusFuture = fetchSpecificElectionsData();  }    // Instead of calling fetchOngoingElections() directly, assign the future.  // Specific election --> for particular year, state.
  }
  Future<List<BaseElectionResult>> fetchAllElectionsData() async
  {
    List<BaseElectionResult> aggregatedOngoingElections = [];
    List<BaseElectionResult> aggregatedStoppedElections = [];


    try
    {
      // Loop through all election types defined in AppConstants.
      for (String type in AppConstants.electionTypes)
      {
        if (type.trim().isEmpty) continue;

        // Build the admin and result paths based on the election type.
        String adminPath = "";
        String fetchedResultPath = "";
        if
        (type == "General (Lok Sabha)" || type == "Council of States (Rajya Sabha)") {
          adminPath = "Vote Chain/Election/${widget.year}/$type/State/${widget.state}/Admin/Election Activity";
          fetchedResultPath = "Vote Chain/Election/${widget.year}/$type/State/${widget.state}/Result/Fetched_Result";
        }
        else if
        (type == "State Assembly (Vidhan Sabha)" || type == "Legislary Council (Vidhan Parishad)" || type == "Municipal" || type == "Panchayat")
        {
          adminPath = "Vote Chain/State/${widget.state}/Election/${widget.year}/$type/Admin/Election Activity";
          fetchedResultPath = "Vote Chain/State/${widget.state}/Election/${widget.year}/$type/Result/Fetched_Result";
        }
        else {
          print("Skipping unhandled election type: $type");
          continue;
        }

        print("\nProcessing election type: $type");
        print("Admin Path: $adminPath");

        if (adminPath.isEmpty || fetchedResultPath.isEmpty) continue;

        // Fetch the Admin/Election Activity document.
        DocumentSnapshot adminDoc = await FirebaseFirestore.instance.doc(
            adminPath).get();
        if (!adminDoc.exists) {
          print("Admin document does not exist for type: $type");
          continue;
        }
        Map<String, dynamic> adminData = adminDoc.data() as Map<String,dynamic>;
        int stage = (adminData['currentStage'] ?? 1).toInt();
        bool isFirebaseActive = (adminData["isElectionActive"] ?? "true")
            .toString()
            .toLowerCase() == "true";

        // Skip if voting hasn't started for this type.
        if (stage <= 5) {
          print("Voting hasn't started for type: $type (stage: $stage)");
          continue;
        }
        // For ongoing elections: stage 6 or 7 (and active).
        if (stage == 6 && !isFirebaseActive) {
          SnackbarUtils.showNeutralMessage(context,"Voting hasn't started yet.\nSo, only constituencies, parties & candidates info is available as of now, if it is.");
          DocumentSnapshot fetchedDoc = await FirebaseFirestore.instance.doc(
              fetchedResultPath).get();
          if (fetchedDoc.exists && fetchedDoc.data() != null) {
            aggregatedOngoingElections.add(
              ElectionResultInfo(
                doc: fetchedDoc,
                electionType: type,
                year: widget.year,
                state: widget.state,
              ),
            );
            print(
                "Added ongoing election result for type: $type (stage: $stage)");
          }
          else {
            setState(() {
              isLoading = false;
            });
            SnackbarUtils.showErrorMessage(context, 'Problem occurred in checking election status.');
            SnackbarUtils.showErrorMessage(context, 'Unhandled stage for type: $type (stage: $stage, active: $isFirebaseActive)');
            print("No result document for ongoing election type: $type at $fetchedResultPath");
          }
        }
        else if (stage == 7 && isFirebaseActive) {
          SnackbarUtils.showSuccessMessage(context, 'Election is ongoing.\nSo, only constituencies, parties & candidates info is available as of now.');
          DocumentSnapshot fetchedDoc = await FirebaseFirestore.instance.doc(
              fetchedResultPath).get();
          if (fetchedDoc.exists && fetchedDoc.data() != null) {
            aggregatedOngoingElections.add(
              ElectionResultInfo(
                doc: fetchedDoc,
                electionType: type,
                year: widget.year,
                state: widget.state,
              ),
            );
            print("Added ongoing election result for type: $type (stage: $stage)");
          }
          else {
            setState(() {
              isLoading = false;
            });
            SnackbarUtils.showErrorMessage(context, 'Problem occurred in checking election status.');
            SnackbarUtils.showErrorMessage(context, 'Unhandled stage for type: $type (stage: $stage, active: $isFirebaseActive)');
            print("No result document for ongoing election type: $type at $fetchedResultPath");
          }
        }
        else if (stage >= 8 && !isFirebaseActive) {
          // For stopped elections: stage >= 8 and not active.
          SnackbarUtils.showSuccessMessage(context,'As the election has stopped,\nDisplaying all available data & result.');
          List<stoppedElectionResultInfo> stoppedResults = await getStoppedElection( year: "${widget.year}", state: "${widget.state}", electionType: "${type}" );
          aggregatedStoppedElections.addAll(stoppedResults);
          print("Added stopped election result for type: $type (stage: $stage)");
        }
        else {
          setState(() {
            isLoading = false;
          });
          SnackbarUtils.showErrorMessage( context, 'Problem occurred in checking election status.');
          SnackbarUtils.showErrorMessage(context, 'Unhandled stage for type: $type (stage: $stage, active: $isFirebaseActive)');
          print( "Unhandled stage for type: $type (stage: $stage, active: $isFirebaseActive)");
        }
      } // end for loop

      // /*
      //     It stops further execution if you switch tabs or navigate away
      //     When you use if (!mounted) return;, it prevents further execution of the code if the widget is no longer part of the widget tree (disposed).
      //     Prevents UI updates on disposed widgets and avoids crashes when switching tabs or navigating away.
      // */
      // if (!mounted) return [];  // ✅ Check if the widget is still mounted & Stop execution if widget is disposed

      setState(() {
        isLoading = false;
      });
    }
    catch (e)
    {
      // if (!mounted) return [];  // ✅ Check if the widget is still mounted & Stop execution if widget is disposed

      setState(() {
        isLoading = false;
      });

      print("Error in fetchAllElectionsData: $e");
      SnackbarUtils.showErrorMessage(context, "Error fetching elections: $e");
    }

    // return aggregatedOngoingElections;
    // Final null/empty condition: return ongoing elections if available; otherwise, return stopped elections if available; else return an empty list.
    if (aggregatedOngoingElections.isNotEmpty) {return aggregatedOngoingElections ;}
    else if(aggregatedStoppedElections.isNotEmpty) {return aggregatedStoppedElections ;}
    else return [];
  }
  Future<List<BaseElectionResult>> fetchSpecificElectionsData() async   // old name was --> "checkElectionStatus()"
  {
    // Future<void> checkElectionStatus() async {
    String electionActivityPath = "";

    print("\n000. Hiiiiiiii..........");


    // Build the admin path based on election type.
    if
    (widget.electionType == "General (Lok Sabha)" || widget.electionType == "Council of States (Rajya Sabha)")
    { electionActivityPath = "Vote Chain/Election/${widget.year}/${widget.electionType}/State/${widget.state}/Admin/Election Activity"; }
    else if
    ( widget.electionType == "State Assembly (Vidhan Sabha)" || widget.electionType == "Legislary Council (Vidhan Parishad)" ||
        widget.electionType == "Municipal" || widget.electionType == "Panchayat")
    { electionActivityPath = "Vote Chain/State/${widget.state}/Election/${widget.year}/${widget.electionType}/Admin/Election Activity"; }

    print("\n00k. Hiiiiiiii..........");
    print("\n00j. electionActivityPath..........: ${widget.electionType} ");
    print("\n00j. electionActivityPath..........: ${widget.year}");
    print("\n00j. electionActivityPath..........: ${widget.state}");


    try
    {
      DocumentSnapshot electionActivity =
      await FirebaseFirestore.instance.doc(electionActivityPath).get();

      currentStage = (electionActivity['currentStage'] ?? 1).toInt();
      bool isFirebaseElectionActive = true;
      String isElectionActive =
      electionActivity.get("isElectionActive").toString().toLowerCase();
      if (isElectionActive == "false") {
        isFirebaseElectionActive = false;
      }

      // if (!mounted) return [];  // ✅ Check if the widget is still mounted & Stop execution if widget is disposed

      if
      ( currentStage <= 5 )
      {
        setState(() { isLoading = false; });
        SnackbarUtils.showErrorMessage(context, "Voting hasn't started yet.\nSo no data is available to show.");
        return [];
      }
      else if
      (currentStage == 6)
      {
        // Voting hasn't started yet.
        // setState(() { isLoading = false; });
        // Show an error message (using your SnackbarUtils or similar)
        SnackbarUtils.showNeutralMessage(context, "Voting hasn't started yet.\nSo, only constituencies, parties & candidates info is available as of now, if it is.");

        // await fetchOngoingElections();              // For our UI we still show the basic (ongoing) card.
        return await getOngoingElection();
      }
      else if
      (
      currentStage == 7
          && isFirebaseElectionActive == true
      // && (await SmartContractService().checkElectionStatus(electionDetails.year! as int, electionDetails.electionType!, electionDetails.state!) == 'STARTED')
      )
      {
        print("\n001. Hiiiiiiii..........");
        // Election ongoing.
        // setState(() { isLoading = false; });
        SnackbarUtils.showSuccessMessage(context, 'Election is ongoing.\nSo, only constituencies, parties & candidates info is available as of now.');
        // await fetchOngoingElections();
        return await getOngoingElection();
      }
      else if
      (
      currentStage >= 8 && isFirebaseElectionActive == false
      // && (await SmartContractService().checkElectionStatus(electionDetails.year! as int, electionDetails.electionType!, electionDetails.state!) == 'STOPPED')
      )
      {
        setState(() { isLoading = false; });
        SnackbarUtils.showSuccessMessage(context, 'As the election has stopped,\nDisplaying all available data & result.');

        // await getStoppedElection();          // Election stopped: fetch full results.
        return await getStoppedElection( year: "${widget.year}", state: "${widget.state}", electionType: "${widget.electionType}" ); // Now returns a list of stoppedElectionResultInfo objects.
      }
      else
      {
        setState(() { isLoading = false; });
        SnackbarUtils.showErrorMessage(context, 'Problem occurred in checking election status.');
        return [];
      }
    }
    catch (e)
    {
      // if (!mounted) return [];  // ✅ Check if the widget is still mounted & Stop execution if widget is disposed

      setState(() { isLoading = false; });
      print("Error checking election status: $e");
      // SnackbarUtils.showErrorMessage(context, "Error checking election status: $e");
      return [];
    }
  }

  /// ************************************  ************  *********  **** ** *   For elections not yet stopped (ongoing or not started): fetch a basic set of election details without vote counts.
  /// ************************************  ************  *********  **** ** *   For elections not yet stopped (ongoing or not started): fetch a basic set of election details without vote counts.
  Widget detailRow_For_6_7(String label, String? value) {
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

  /// Build the main election card using metadata
  Widget _buildElectionCard(Map<String, dynamic> resultData, BaseElectionResult  info) {
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
                _buildElectionSummaryCard(resultData, info),
                SizedBox(height: 20),
                // Divider(color: Colors.black,),
                _buildPartyResultsCard(resultData, info),
                SizedBox(height: 20),
                // Divider(color: Colors.black,),
                _buildConstituencyResultsCard(resultData, info),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// UI Card 1: Election Summary Card
  Widget _buildElectionSummaryCard(Map<String, dynamic> resultData, BaseElectionResult  info) {
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
  Widget _buildPartyResultsCard(Map<String, dynamic> resultData, BaseElectionResult  info) {
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
                                      detailRow_For_6_7("Age:", candidateData["age"]?.toString()),
                                      detailRow_For_6_7("Gender:", candidateData["gender"]),
                                      detailRow_For_6_7("Education:", candidateData["education"]),
                                      detailRow_For_6_7("Profession:", candidateData["profession"]),
                                      detailRow_For_6_7("Home State:", candidateData["candidateHomeState"]),
                                      detailRow_For_6_7("Email:", candidateData["candidateId"]),
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
  Widget _buildConstituencyResultsCard(Map<String, dynamic> resultData, BaseElectionResult  info) {
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
                                  detailRow_For_6_7("Age:", candidateData["age"]?.toString()),
                                  detailRow_For_6_7("Gender:", candidateData["gender"]),
                                  detailRow_For_6_7("Education:", candidateData["education"]),
                                  detailRow_For_6_7("Profession:", candidateData["profession"]),
                                  detailRow_For_6_7("Home State:", candidateData["candidateHomeState"]),
                                  detailRow_For_6_7("Email:", candidateData["candidateId"]),
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

  Future<List<ElectionResultInfo>> getOngoingElection() async {
    // Future<void> fetchOngoingElections() async {

    print("\n002. Hiiiiiiii..........");

    String electionType = widget.electionType; // Use the specific election type

    try
    {
      String adminPath = '';
      String fetchedResultPath = '';

      // Build paths based on the election type
      if (electionType == "General (Lok Sabha)" || electionType == "Council of States (Rajya Sabha)")
      {
        adminPath = "Vote Chain/Election/${widget.year}/$electionType/State/${widget.state}/Admin/Election Activity/";
        fetchedResultPath = "Vote Chain/Election/${widget.year}/$electionType/State/${widget.state}/Result/Fetched_Result/";
      }
      else if
      (electionType == "State Assembly (Vidhan Sabha)" || electionType == "Legislary Council (Vidhan Parishad)" || electionType == "Municipal" || electionType == "Panchayat")
      {
        adminPath = "Vote Chain/State/${widget.state}/Election/${widget.year}/$electionType/Admin/Election Activity/";
        fetchedResultPath = "Vote Chain/State/${widget.state}/Election/${widget.year}/$electionType/Result/Fetched_Result/";
      }
      else
      {
        print("Skipping unhandled election type: $electionType");
        return []; // Exit early if election type is not valid
      }

      // Debug print the paths
      print("*** Admin Path: $adminPath");

      // Ensure paths are not empty before calling Firestore
      if (adminPath.isEmpty || fetchedResultPath.isEmpty) return [];

      // Fetch the Admin/Election Activity document
      DocumentSnapshot adminDoc = await FirebaseFirestore.instance.doc(adminPath).get();

      if (adminDoc.exists)
      {
        Map<String, dynamic> adminData = adminDoc.data() as Map<String, dynamic>;

        // Check if currentStage is 6 or 7
        if (adminData['currentStage'] == 6 || adminData['currentStage'] == 7 )
        {
          print("\n*** Found election at: $adminPath with currentStage = ${adminData['currentStage']}");

          // Now fetch the Fetched_Result document that contains the votes data
          DocumentSnapshot fetchedResultDoc = await FirebaseFirestore.instance.doc(fetchedResultPath).get();

          print("*** Fetching: $fetchedResultPath");
          if (fetchedResultDoc.exists && fetchedResultDoc.data() != null)
          {
            fetchedElections.add(
              ElectionResultInfo(
                doc: fetchedResultDoc,
                electionType: electionType,
                year: widget.year,
                state: widget.state,
              ),
            );
            print("*** Election result added");
          }
          else
          { print("No Fetched_Result doc found at: $fetchedResultPath"); }
        }
      }
      setState(() {
        isLoading = false;
      });

      return fetchedElections;
    }
    catch (e) {
      print("Error fetching election results: $e");
      setState(() {
        //   elections = [];
        //   print("**** Fetched elections: $elections");  // for testing print & check
        isLoading = false;
      });
      return [];      // Return an empty list in case of error.
    }
  }


  /// ************************************  ************  *********  **** ** *   For stopped elections: fetch detailed results with vote counts and candidate details.
  /// ************************************  ************  *********  **** ** *   For stopped elections: fetch detailed results with vote counts and candidate details.
  Widget detailRow_For_8(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align to the top
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 5),
          Expanded( // Prevents overflow
            child: Text(
              value ?? 'N/A',
              style: TextStyle(color: Colors.black87),
              overflow: TextOverflow.ellipsis, // Avoids overflow
              maxLines: 2, // Wraps text if it's too long
            ),
          ),
        ],
      ),
    );
  }
  List<List<String>> findWinningAlliances(Map<String, int> partyWins, int threshold) {
    List<String> parties = partyWins.keys.toList();
    List<List<String>> alliances = [];

    // Generate all possible party combinations
    for (int i = 1; i < (1 << parties.length); i++) { // Iterate through subsets
      List<String> combination = [];
      int totalSeats = 0;

      for (int j = 0; j < parties.length; j++) {
        if ((i & (1 << j)) != 0) { // Check if party is in the subset
          combination.add(parties[j]);
          totalSeats += partyWins[parties[j]]!;
        }
      }

      if (totalSeats >= threshold) {
        alliances.add(combination);
      }
    }

    // Sort alliances by total seats in descending order
    alliances.sort((a, b) =>
        b.fold(0, (sum, party) => sum + (partyWins[party] ?? 0))
            .compareTo(
            a.fold(0, (sum, party) => sum + (partyWins[party] ?? 0))
        ));

    return alliances;
  }     // Utility method to compute possible winning alliances.

  /// Build the main election card using metadata
  /// old name was --> Return part in widget context @ Result_Election.dart
  // Widget _buildStoppedElectionCard(Map<String, dynamic> resultData, stoppedElectionResultInfo info) {
  //   return Scaffold(
  //     body: isLoading
  //         ? Center(child: CircularProgressIndicator())
  //     // : constituencyResults.isEmpty
  //         : electionStatusFuture.isNull
  //         ? Center(
  //       child: Text(
  //         'No results available.',
  //         style: TextStyle(fontSize: 18, color: Colors.grey),
  //       ),
  //     )
  //         : Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: ListView(
  //         children: [
  //           Card(
  //             elevation: 4,
  //             shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(10)),
  //             // color: Colors.blue.shade100,
  //             color: Colors.teal.shade200,
  //             margin: EdgeInsets.symmetric(vertical: 10),
  //             child: Padding(
  //               padding: const EdgeInsets.all(16.0),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Center(
  //                       child: Text("Election Summary",
  //                           style: TextStyle(
  //                               fontSize: 20,
  //                               fontWeight: FontWeight.bold))),
  //                   SizedBox(height: 8),
  //                   /// shows only constituency name in which tie is there among top candidates
  //                   // ...partyWins.entries.map((entry) {
  //                   //   return Text(
  //                   //       "\n${entry.key}: \n${entry.value} constituencies won");
  //                   // }).toList(),
  //                   // SizedBox(height: 10),
  //                   // Center(
  //                   //   child: Text("Constituency Ties\nTie between top candidates. Lottery will decide winner.",
  //                   //       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
  //                   // ),
  //                   // ...constituencyWinners.entries.map((entry) {
  //                   //   if (entry.value.containsKey("message")) {
  //                   //     return Text("\n${entry.key}: ${entry.value['message']}");
  //                   //   } else {
  //                   //     return SizedBox.shrink();
  //                   //   }
  //                   // }).toList(),
  //                   /// shows constituency name + party names in which tie is there among top candidates
  //                   ...partyWins.entries.map((entry) {
  //                     return Text("\n${entry.key}: \n${entry.value} constituencies won");
  //                   }).toList(),
  //                   SizedBox(height: 15),
  //                   ///
  //                   // Center(
  //                   //   child: Text(
  //                   //     "Constituency Ties\n(Tie between top candidates. Lottery will decide winner.)",
  //                   //     style: TextStyle(
  //                   //       fontSize: 18,
  //                   //       fontWeight: FontWeight.bold,
  //                   //       color: Colors.black,
  //                   //     ),
  //                   //   ),
  //                   // ),
  //                   ///
  //                   // Center(
  //                   //   child: RichText(
  //                   //     textAlign: TextAlign.center,
  //                   //     text: TextSpan(
  //                   //       children: [
  //                   //         TextSpan(
  //                   //           text: "Candidate Ties\n",
  //                   //           style: TextStyle(
  //                   //             fontSize: 18,
  //                   //             fontWeight: FontWeight.bold,
  //                   //             color: Colors.black,
  //                   //           ),
  //                   //         ),
  //                   //         TextSpan(
  //                   //           text: "Tie between top candidates in respective constituency. Lottery will decide winner.",
  //                   //           style: TextStyle(
  //                   //             fontSize: 14, // smaller size
  //                   //             fontWeight: FontWeight.normal, // not bold
  //                   //             color: Colors.black,
  //                   //           ),
  //                   //         ),
  //                   //       ],
  //                   //     ),
  //                   //   ),
  //                   // ),
  //                   // ...constituencyWinners.entries.map((entry) {
  //                   //   // If the entry has tiedParties, show them.
  //                   //   if (entry.value.containsKey("tiedParties")) {
  //                   //     List tiedParties = entry.value["tiedParties"];
  //                   //     return Text("\n${entry.key}:\n${tiedParties.join(', ')}");
  //                   //   } else {
  //                   //     // For constituencies with a clear winner, nothing extra is shown.
  //                   //     return SizedBox.shrink();
  //                   //   }
  //                   // }).toList(),
  //                   ///
  //                   // Conditionally display "Candidate Ties" only if there are actual ties.
  //                   if (hasTies) ...[
  //                     Center(
  //                       child: RichText(
  //                         textAlign: TextAlign.center,
  //                         text: TextSpan(
  //                           children: [
  //                             TextSpan(
  //                               text: "Candidate Ties\n",
  //                               style: TextStyle(
  //                                 fontSize: 18,
  //                                 fontWeight: FontWeight.bold,
  //                                 color: Colors.black,
  //                               ),
  //                             ),
  //                             TextSpan(
  //                               text: "Tie between top candidates in respective constituency. Lottery will decide winner.",
  //                               style: TextStyle(
  //                                 fontSize: 14, // smaller size
  //                                 fontWeight: FontWeight.normal, // not bold
  //                                 color: Colors.black,
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                     ...constituencyWinners.entries.map((entry) {
  //                       if (entry.value.containsKey("tiedParties")) {
  //                         List tiedParties = entry.value["tiedParties"];
  //                         return Text("\n${entry.key}:\n${tiedParties.join(', ')}");
  //                       } else {
  //                         return SizedBox.shrink();
  //                       }
  //                     }).toList(),
  //                   ],
  //
  //                   SizedBox(height: 15),
  //                   Center(
  //                       child: Text("Overall Winner:",
  //                           style: TextStyle(
  //                               fontSize: 18,
  //                               fontWeight: FontWeight.bold,
  //                               color: Colors.black))),
  //                   SizedBox(height: 3),
  //                   Center(
  //                       child: Text("$overallWinningParty",
  //                           style: TextStyle(
  //                               fontSize: 18,
  //                               fontWeight: FontWeight.bold,
  //                               color: Colors.black))),
  //
  //                   SizedBox(height: 15),
  //                   if (overallWinningParty == "No clear winner") ...[
  //                     Center(
  //                       child: RichText(
  //                         textAlign: TextAlign.center,
  //                         text: TextSpan(
  //                           children: [
  //                             TextSpan(
  //                               text: "Possible Winner\n",
  //                               style: TextStyle(
  //                                 fontSize: 18,
  //                                 fontWeight: FontWeight.bold,
  //                                 color: Colors.black,
  //                               ),
  //                             ),
  //                             TextSpan(
  //                               text: "Possible alliances that can form the majority:",
  //                               style: TextStyle(
  //                                 fontSize: 14,
  //                                 fontWeight: FontWeight.normal,
  //                                 color: Colors.black,
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                     ...findWinningAlliances(partyWins, threshold).map((alliance) {
  //                       return Text("\nAlliance: ${alliance.join(' + ')} → ${alliance.fold(0, (sum, party) => sum + (partyWins[party] ?? 0))} constituencies");
  //                     }).toList(),
  //                   ],
  //
  //                 ],
  //               ),
  //             ),
  //           ),
  //
  //           SizedBox(height: 15),
  //           Card(
  //             elevation: 4,
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(10),
  //             ),
  //             color: Colors.teal.shade200,
  //             margin: EdgeInsets.symmetric(vertical: 10),
  //             child: Padding(
  //               padding: const EdgeInsets.all(8.0),
  //               child: Column(
  //                 children:
  //                 // partyResults.keys.map((party)
  //                 (partyResults.keys.toList()..sort())                // Sort party names alphabetically
  //                     .map((party)
  //                 {
  //                   bool isExpanded = _expandedState[party] ?? false;
  //                   return Card(
  //                     elevation: 2,
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(10),
  //                     ),
  //                     margin: EdgeInsets.symmetric(vertical: 5),    //  gap between internal party-cards
  //                     child: Column(
  //                       children: [
  //                         ListTile(
  //                           title: Text(
  //                             "Party: $party",
  //                             style: TextStyle(
  //                               fontSize: 18,
  //                               fontWeight: FontWeight.bold,
  //                             ),
  //                           ),
  //                           trailing: IconButton(
  //                             icon: Icon(
  //                               isExpanded ? Icons.expand_less : Icons.expand_more,
  //                             ),
  //                             onPressed: () {
  //                               setState(() {
  //                                 _expandedState[party] = !isExpanded;
  //                               });
  //                             },
  //                           ),
  //                         ),
  //                         if (isExpanded)
  //                           Column(
  //                             children:
  //                             // partyResults[party]!
  //                             (partyResults[party]!..sort((a, b) => a["constituency"].compareTo(b["constituency"])))      // showing constituencies in alphabetical order
  //                                 .map((constituencyData) {
  //
  //                               // Get winner data, if any.
  //                               bool isWinner = constituencyData["candidateId"] ==
  //                                   constituencyWinners[constituencyData["constituency"]]?["candidateId"];
  //                               int leadMargin = (constituencyData["voteCount"] - (constituencyWinners[constituencyData["constituency"]]?["voteCount"] ?? 0)).abs();
  //
  //                               // return Card(
  //                               //   color: isWinner
  //                               //       ? Colors.green.shade100
  //                               //       : Colors.red.shade100,
  //                               //   margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
  //                               //   // shape: RoundedRectangleBorder(
  //                               //   //   borderRadius: BorderRadius.circular(12),
  //                               //   // ),
  //                               //   child: ListTile(
  //                               //     // contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),            // The gap between data  & border of card
  //                               //     leading: Icon(isWinner ? Icons.star : Icons.person),
  //                               //     title: Column(
  //                               //       crossAxisAlignment: CrossAxisAlignment.start,
  //                               //       children: [
  //                               //         Text(
  //                               //           constituencyData["constituency"],
  //                               //           style: TextStyle(fontWeight: FontWeight.bold),
  //                               //         ),
  //                               //         SizedBox(height: 4),
  //                               //         Text(
  //                               //           "${constituencyData["candidateId"]}",
  //                               //           style: TextStyle(fontWeight: FontWeight.bold),
  //                               //         ),
  //                               //         SizedBox(height: 4),
  //                               //         Row(
  //                               //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                               //           children: [
  //                               //             Text("Votes: ${constituencyData["voteCount"]}"),
  //                               //             Text(
  //                               //               isWinner ? "Won" : "-$leadMargin",
  //                               //               style: TextStyle(
  //                               //                 color: isWinner ? Colors.green : Colors.red,
  //                               //                 fontWeight: FontWeight.bold,
  //                               //               ),
  //                               //             ),
  //                               //           ],
  //                               //         ),
  //                               //       ],
  //                               //     ),
  //                               //   ),
  //                               // );
  //                               ///
  //                               return Card(
  //                                 color: isWinner
  //                                     ? Colors.green.shade100
  //                                     : Colors.red.shade100,
  //                                 margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
  //                                 // shape: RoundedRectangleBorder(
  //                                 //   borderRadius: BorderRadius.circular(12),
  //                                 // ),
  //                                 child: ListTile(
  //                                   // contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),            // The gap between data  & border of card
  //                                   // leading: Icon(isWinner ? Icons.star : Icons.person),
  //                                   title: Column(
  //                                     crossAxisAlignment: CrossAxisAlignment.start,
  //                                     children: [
  //                                       Row(
  //                                         crossAxisAlignment: CrossAxisAlignment.center,
  //                                         children: [
  //                                           // Candidate Profile Photo
  //                                           Container(
  //                                             width: 50,
  //                                             height: 50,
  //                                             decoration: BoxDecoration(
  //                                               // color: Colors.teal.shade200,
  //                                               // gradient: LinearGradient(
  //                                               //   colors: [Colors.teal.shade200, Colors.teal.shade600],
  //                                               //   begin: Alignment.topLeft,
  //                                               //   end: Alignment.bottomRight,
  //                                               // ),
  //                                               gradient: LinearGradient(
  //                                                 colors: [Colors.teal.shade300, Colors.indigo.shade400],
  //                                                 begin: Alignment.topLeft,
  //                                                 end: Alignment.bottomRight,
  //                                               ),
  //                                               // gradient: LinearGradient(
  //                                               //   colors: [Colors.tealAccent.shade400, Colors.teal.shade800],
  //                                               //   begin: Alignment.topLeft,
  //                                               //   end: Alignment.bottomRight,
  //                                               // ),
  //                                               borderRadius: BorderRadius.circular(10),
  //                                             ),
  //                                             child: Icon(Icons.person, color: Colors.white, size: 40),
  //                                           ),
  //                                           SizedBox(width: 12),
  //
  //                                           // Name and Email Column
  //                                           Expanded(
  //                                             child: Column(
  //                                               crossAxisAlignment: CrossAxisAlignment.start,
  //                                               children: [
  //                                                 Text(
  //                                                   constituencyData["name"] ?? 'N/A',
  //                                                   style: TextStyle(
  //                                                     fontWeight: FontWeight.bold,
  //                                                     fontSize: 17,
  //                                                     color: Colors.black87,
  //                                                   ),
  //                                                 ),
  //                                                 SizedBox(height: 5),
  //                                                 Text(
  //                                                   constituencyData["constituency"] ?? 'N/A',
  //                                                   style: TextStyle(
  //                                                     fontSize: 16,
  //                                                     color: Colors.black,
  //                                                     fontWeight: FontWeight.bold,
  //                                                   ),
  //                                                   overflow: TextOverflow.ellipsis, // Prevents overflow
  //                                                   maxLines: 1, // Keeps it in one line
  //                                                 ),
  //                                                 SizedBox(height: 4),
  //                                                 Row(
  //                                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                                                   children: [
  //                                                     Text("Votes: ${constituencyData["voteCount"]}",
  //                                                       style: TextStyle( fontWeight: FontWeight.bold, ),
  //                                                     ),
  //                                                     Text(
  //                                                       isWinner ? "Won" : "-$leadMargin",
  //                                                       style: TextStyle(
  //                                                         color: isWinner ? Colors.green : Colors.red,
  //                                                         fontWeight: FontWeight.bold,
  //                                                       ),
  //                                                     ),
  //                                                   ],
  //                                                 ),
  //                                               ],
  //                                             ),
  //                                           ),
  //                                         ],
  //                                       ),
  //
  //
  //
  //                                       SizedBox(height: 10), // Space before other details
  //                                       Divider(color: Colors.grey),
  //
  //                                       // Candidate Details List
  //                                       Column(
  //                                         crossAxisAlignment: CrossAxisAlignment.start,
  //                                         children: [
  //                                           detailRow_For_8("Age:", constituencyData["age"]?.toString()),
  //                                           detailRow_For_8("Gender:", constituencyData["gender"]),
  //                                           detailRow_For_8("Education:", constituencyData["education"]),
  //                                           detailRow_For_8("Profession:", constituencyData["profession"]),
  //                                           detailRow_For_8("Home State:", constituencyData["candidateHomeState"]),
  //                                           detailRow_For_8("Email:", constituencyData["candidateId"]),
  //                                         ],
  //                                       ),
  //                                     ],
  //                                   ),
  //                                 ),
  //                               );
  //                             }).toList(),
  //                           ),
  //                         SizedBox(height: 4),
  //                       ],
  //                     ),
  //                   );
  //                 }).toList(),
  //               ),
  //             ),
  //           ),
  //
  //           SizedBox(height: 15),
  //           Card(
  //             elevation: 4,
  //             shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(10)),
  //             // color: Colors.blue.shade100,
  //             color: Colors.teal.shade200,
  //             margin: EdgeInsets.symmetric(vertical: 10),
  //             child: Padding(
  //               padding: const EdgeInsets.all(8.0),
  //               // child: Column(        /// Not for nota vote count card
  //               child: Column(           /// for nota vote count card
  //                 children:
  //                 // constituencyResults.keys
  //                 (constituencyResults.keys.toList()..sort())           // Showing constituencies alphabetically
  //                     .map((constituency) {
  //
  //                   // Retrieve the NOTA vote count for the current constituency.
  //                   String notaCount = "0";
  //                   if (electionMetadata != null && electionMetadata!.containsKey(constituency)) {
  //                     var meta = electionMetadata![constituency];
  //                     if (meta is Map<String, dynamic> && meta.containsKey('notaVotes')) {
  //                       notaCount = meta['notaVotes'].toString();
  //                     }
  //                   }
  //
  //                   return Card(
  //                     elevation: 2,
  //                     shape: RoundedRectangleBorder(
  //                         borderRadius: BorderRadius.circular(10)),
  //                     margin: EdgeInsets.symmetric(vertical: 5),           //  gap between internal constituency-cards
  //                     child: Column(
  //                       children: [
  //                         ListTile(
  //                           title: Text(constituency,
  //                               style: TextStyle(
  //                                   fontSize: 18,
  //                                   fontWeight: FontWeight.bold)),
  //                           trailing: IconButton(
  //                             icon: Icon(
  //                                 expandedConstituencies[constituency] ==
  //                                     true  ? Icons.expand_less : Icons.expand_more),
  //                             onPressed: () {
  //                               print("Checking election status...");
  //                               print("Party results: ${partyResults.length}");
  //                               print("Constituency winners: ${constituencyWinners.length}");
  //                               print("Overall winner: $overallWinningParty");
  //
  //                               setState(() {
  //                                 expandedConstituencies[constituency] =
  //                                 !(expandedConstituencies[
  //                                 constituency] ??
  //                                     false);
  //                               });
  //                             },
  //                           ),
  //                         ),
  //                         if (expandedConstituencies[constituency] == true)
  //                           Column(
  //
  //                             /// Not for nota vote count card
  //                             // children:
  //                             // constituencyResults[constituency]!.map((candidate) {
  //                             /// for nota vote count card
  //                             children: [
  //                               ...constituencyResults[constituency]!.map((candidate) {
  //                                 var winnerData = constituencyWinners[constituency];
  //                                 bool isWinner = false;
  //                                 int leadMargin = 0;
  //                                 if (winnerData != null) {
  //                                   isWinner = candidate["candidateId"] == winnerData["candidateId"];
  //                                   leadMargin = isWinner ? 0 : candidate["voteCount"] - (winnerData["voteCount"] ?? 0);
  //                                 }
  //                                 // bool isWinner = candidate["candidateId"] ==
  //                                 //     constituencyWinners[constituency]![
  //                                 //     'candidateId'];
  //                                 // int leadMargin = isWinner
  //                                 //     ? 0
  //                                 //     : candidate["voteCount"] -
  //                                 //     constituencyWinners[constituency]![
  //                                 //     'voteCount'];
  //                                 return Card(
  //                                   color: isWinner
  //                                       ? Colors.green.shade100
  //                                       : Colors.red.shade100,
  //                                   margin: EdgeInsets.symmetric(
  //                                       vertical: 5, horizontal: 10),
  //                                   child: ListTile(
  //                                     // contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),  // The gap between data  & border of card
  //                                     // leading: Icon(isWinner
  //                                     //     ? Icons.star
  //                                     //     : Icons.person),
  //                                     title: Column(
  //                                       crossAxisAlignment: CrossAxisAlignment.start,
  //                                       // children: [
  //                                       //   Text(candidate["candidateId"],
  //                                       //       style: TextStyle(
  //                                       //           fontWeight:
  //                                       //           FontWeight.bold)),
  //                                       //   SizedBox(height: 4),
  //                                       //   Text(candidate["party"],
  //                                       //       style: TextStyle(
  //                                       //           fontWeight:
  //                                       //           FontWeight.bold)),
  //                                       //   SizedBox(height: 4),
  //                                       //   Row(
  //                                       //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                                       //     children: [
  //                                       //       Text("Votes: ${candidate["voteCount"]}"),
  //                                       //       // Text(
  //                                       //       //   leadMargin >= 0
  //                                       //       //       ? "Won" : "$leadMargin",
  //                                       //       //   style: TextStyle(
  //                                       //       //     color: leadMargin >= 0 ? Colors.green : Colors.red,
  //                                       //       //     fontWeight: FontWeight.bold,),
  //                                       //       // ),
  //                                       //       Text(
  //                                       //         winnerData == null ? "0" : (isWinner ? "Won" : "$leadMargin"),
  //                                       //         style: TextStyle(
  //                                       //           color: winnerData == null
  //                                       //               ? Colors.orange
  //                                       //               : (isWinner ? Colors.green : Colors.red),
  //                                       //           fontWeight: FontWeight.bold,
  //                                       //         ),
  //                                       //       ),
  //                                       //     ],
  //                                       //   ),
  //                                       // ],
  //                                       ///
  //                                       children: [
  //                                         Row(
  //                                           crossAxisAlignment: CrossAxisAlignment.center,
  //                                           children: [
  //                                             // Candidate Profile Photo
  //                                             Container(
  //                                               width: 50,
  //                                               height: 50,
  //                                               decoration: BoxDecoration(
  //                                                 // color: Colors.teal.shade200,
  //                                                 // gradient: LinearGradient(
  //                                                 //   colors: [Colors.teal.shade200, Colors.teal.shade600],
  //                                                 //   begin: Alignment.topLeft,
  //                                                 //   end: Alignment.bottomRight,
  //                                                 // ),
  //                                                 gradient: LinearGradient(
  //                                                   colors: [Colors.teal.shade300, Colors.indigo.shade400],
  //                                                   begin: Alignment.topLeft,
  //                                                   end: Alignment.bottomRight,
  //                                                 ),
  //                                                 // gradient: LinearGradient(
  //                                                 //   colors: [Colors.tealAccent.shade400, Colors.teal.shade800],
  //                                                 //   begin: Alignment.topLeft,
  //                                                 //   end: Alignment.bottomRight,
  //                                                 // ),
  //                                                 borderRadius: BorderRadius.circular(10),
  //                                               ),
  //                                               child: Icon(Icons.person, color: Colors.white, size: 40),
  //                                             ),
  //                                             SizedBox(width: 12),
  //
  //                                             // Name and Email Column
  //                                             Expanded(
  //                                               child: Column(
  //                                                 crossAxisAlignment: CrossAxisAlignment.start,
  //                                                 children: [
  //                                                   Text(
  //                                                     candidate["name"] ?? 'N/A',
  //                                                     style: TextStyle(
  //                                                       fontWeight: FontWeight.bold,
  //                                                       fontSize: 17,
  //                                                       color: Colors.black87,
  //                                                     ),
  //                                                   ),
  //                                                   SizedBox(height: 5),
  //                                                   Text(
  //                                                     candidate["party"] ?? 'N/A',
  //                                                     style: TextStyle(
  //                                                       fontSize: 16,
  //                                                       color: Colors.black,
  //                                                       fontWeight: FontWeight.bold,
  //                                                     ),
  //                                                     overflow: TextOverflow.ellipsis, // Prevents overflow
  //                                                     maxLines: 1, // Keeps it in one line
  //                                                   ),
  //                                                   SizedBox(height: 4),
  //                                                   Row(
  //                                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                                                     children: [
  //                                                       Text("Votes: ${candidate["voteCount"]}",
  //                                                         style: TextStyle( fontWeight: FontWeight.bold, ),
  //                                                       ),
  //                                                       // Text(
  //                                                       //   leadMargin >= 0
  //                                                       //       ? "Won" : "$leadMargin",
  //                                                       //   style: TextStyle(
  //                                                       //     color: leadMargin >= 0 ? Colors.green : Colors.red,
  //                                                       //     fontWeight: FontWeight.bold,),
  //                                                       // ),
  //                                                       Text(
  //                                                         winnerData == null ? "0" : (isWinner ? "Won" : "$leadMargin"),
  //                                                         style: TextStyle(
  //                                                           color: winnerData == null
  //                                                               ? Colors.orange
  //                                                               : (isWinner ? Colors.green : Colors.red),
  //                                                           fontWeight: FontWeight.bold,
  //                                                         ),
  //                                                       ),
  //                                                     ],
  //                                                   ),
  //                                                 ],
  //                                               ),
  //                                             ),
  //                                           ],
  //                                         ),
  //                                         SizedBox(height: 10), // Space before other details
  //                                         Divider(color: Colors.grey),
  //
  //                                         // Candidate Details List
  //                                         Column(
  //                                           crossAxisAlignment: CrossAxisAlignment.start,
  //                                           children: [
  //                                             detailRow_For_8("Age:", candidate["age"]?.toString()),
  //                                             detailRow_For_8("Gender:", candidate["gender"]),
  //                                             detailRow_For_8("Education:", candidate["education"]),
  //                                             detailRow_For_8("Profession:", candidate["profession"]),
  //                                             detailRow_For_8("Home State:", candidate["candidateHomeState"]),
  //                                             detailRow_For_8("Email:", candidate["candidateId"]),
  //                                           ],
  //                                         ),
  //                                       ],
  //                                     ),
  //                                   ),
  //                                 );
  //                               }).toList(),
  //                               /// shows nota vote count card only if votes are there
  //                               // // Display NOTA vote count card for the constituency if metadata is available.
  //                               // if (notaVotesText.isNotEmpty)
  //                               // Card(
  //                               //   color: Colors.orange.shade100,
  //                               //   margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
  //                               //   child: ListTile(
  //                               //     title: Text(
  //                               //       notaVotesText,
  //                               //       style: TextStyle(
  //                               //         fontSize: 14,
  //                               //         fontWeight: FontWeight.normal,
  //                               //       ),
  //                               //     ),
  //                               //   ),
  //                               // ),
  //                               /// Always show NOTA vote count card.
  //                               Card(
  //                                 color: Colors.orange.shade100,
  //                                 margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
  //                                 child: ListTile(
  //                                   leading: Icon(
  //                                     Icons.block,
  //                                     color: Colors.orange,
  //                                     size: 30, // Increase size to make it visually bolder
  //                                     opticalSize: 48, // Only works in newer Flutter versions
  //                                   ),                                        title: Row(
  //                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                                   children: [
  //                                     Text(
  //                                       "NOTA Votes",
  //                                       style: TextStyle(
  //                                         fontSize: 15,
  //                                         fontWeight: FontWeight.bold, // Bold text
  //                                         color: Colors.black87,
  //                                       ),
  //                                     ),
  //                                     Text(
  //                                       notaCount,
  //                                       style: TextStyle(
  //                                         fontSize: 15,
  //                                         fontWeight: FontWeight.bold, // Bold text
  //                                         color: Colors.black87,
  //                                       ),
  //                                     ),
  //                                   ],
  //                                 ),
  //                                 ),
  //                               )
  //
  //                             ],
  //                           ),
  //                         SizedBox(height: 5),
  //                       ],
  //                     ),
  //                   );
  //                 }).toList(),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  /// trying to improve by using all same code of above one
  Widget _buildStoppedElectionCard(Map<String, dynamic> resultData, stoppedElectionResultInfo  info) {
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
                _buildStoppedElectionSummaryCard(resultData, info),
                SizedBox(height: 20),
                // Divider(color: Colors.black,),
                _buildStoppedElectionPartyResultsCard(resultData, info),
                SizedBox(height: 20),
                // Divider(color: Colors.black,),
                _buildStoppedElectionConstituencyResultsCard(resultData, info),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// UI Card 1: Election Summary Card
  Widget _buildStoppedElectionSummaryCard( Map<String, dynamic> resultData , stoppedElectionResultInfo info) {
    // // Print entire election summary data
    // print("\n\n******************\n\n=== Election Summary Data ===");
    // print("Election Type: ${info.electionType}");
    // print("Year: ${info.year}");
    // print("State: ${info.state}");
    // print("Party Wins: ${info.partyWins}");
    // print("Party Results: ${info.partyResults}");
    // print("Constituency Results: ${info.constituencyResults}");
    // print("Constituency Winners: ${info.constituencyWinners}");
    // print("Has Ties: ${info.hasTies}");
    // print("Threshold: ${info.threshold}");
    // print("Overall Winning Party: ${info.overallWinningParty}");
    // print("Election Metadata: ${info.electionMetadata}");


    // STEP A1 -  Extract party names from the first data structure
    Set<String> existingParties = info.partyWins.keys.toSet();

    // STEP A2 -  Extract party names from the second data structure (contsins all party names + too much metadata)
    List<String> partyNames = info.partyResults.keys.toList();

    // STEP A3 -  Find extra party names in the second list
    List<String> extraParties = partyNames.where((party) => !existingParties.contains(party)).toList();

    // STEP A4 -  Update the first data structure with the new parties (set their value to 0)
    for (var party in extraParties)
    { info.partyWins[party] = 0; }        // Assuming info.partyWins is a Map<String, int>

    // STEP A5 -  Convert partyWins to a sorted list of MapEntry
    List<MapEntry<String, int>> sortedPartyWins = info.partyWins.entries
        .toList() // Convert to a list for sorting
      ..sort((a, b) => a.key.compareTo(b.key)); // Sort by party name alphabetically

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
      // color: Colors.blue.shade100,
      color: Colors.teal.shade200,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: Text("Election Summary",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold))),
            SizedBox(height: 8),
            /// shows only constituency name in which tie is there among top candidates
            // ...partyWins.entries.map((entry) {
            //   return Text(
            //       "\n${entry.key}: \n${entry.value} constituencies won");
            // }).toList(),
            // SizedBox(height: 10),
            // Center(
            //   child: Text("Constituency Ties\nTie between top candidates. Lottery will decide winner.",
            //       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            // ),
            // ...constituencyWinners.entries.map((entry) {
            //   if (entry.value.containsKey("message")) {
            //     return Text("\n${entry.key}: ${entry.value['message']}");
            //   } else {
            //     return SizedBox.shrink();
            //   }
            // }).toList(),
            /// shows (constituency name +) party names who has won atleast 1 constituency (in which tie is there among top candidates)
            // ...info.partyWins.entries.map((entry) {
            //   return Text("\n${entry.key}: \n${entry.value} constituencies won");
            // }).toList(),
            /// shows all party names & their number of won constituencies (from 0,1,2,3,4,... & so on..)
            // STEP A6 -  Now use the all party names in your UI
            ...sortedPartyWins
                .map((entry) { return Text("\n${entry.key}: \n${entry.value} constituencies won.");  }).toList(),

            SizedBox(height: 15),
            ///
            // Center(
            //   child: Text(
            //     "Constituency Ties\n(Tie between top candidates. Lottery will decide winner.)",
            //     style: TextStyle(
            //       fontSize: 18,
            //       fontWeight: FontWeight.bold,
            //       color: Colors.black,
            //     ),
            //   ),
            // ),
            ///
            // Center(
            //   child: RichText(
            //     textAlign: TextAlign.center,
            //     text: TextSpan(
            //       children: [
            //         TextSpan(
            //           text: "Candidate Ties\n",
            //           style: TextStyle(
            //             fontSize: 18,
            //             fontWeight: FontWeight.bold,
            //             color: Colors.black,
            //           ),
            //         ),
            //         TextSpan(
            //           text: "Tie between top candidates in respective constituency. Lottery will decide winner.",
            //           style: TextStyle(
            //             fontSize: 14, // smaller size
            //             fontWeight: FontWeight.normal, // not bold
            //             color: Colors.black,
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            // ...constituencyWinners.entries.map((entry) {
            //   // If the entry has tiedParties, show them.
            //   if (entry.value.containsKey("tiedParties")) {
            //     List tiedParties = entry.value["tiedParties"];
            //     return Text("\n${entry.key}:\n${tiedParties.join(', ')}");
            //   } else {
            //     // For constituencies with a clear winner, nothing extra is shown.
            //     return SizedBox.shrink();
            //   }
            // }).toList(),
            ///
            // Conditionally display "Candidate Ties" only if there are actual ties.
            if (info.hasTies) ...[
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Candidate Ties\n",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: "Tie between top candidates in respective constituency. Lottery will decide winner.",
                        style: TextStyle(
                          fontSize: 14, // smaller size
                          fontWeight: FontWeight.normal, // not bold
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ...info.constituencyWinners.entries.map((entry) {
                if (entry.value.containsKey("tiedParties")) {
                  List tiedParties = entry.value["tiedParties"];
                  return Text("\n${entry.key}:\n${tiedParties.join(', ')}");
                } else {
                  return SizedBox.shrink();
                }
              }).toList(),
            ],

            SizedBox(height: 15),
            Center(
                child: Text("Overall Winner:",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black))),
            SizedBox(height: 3),
            Center(
                child: Text("${info.overallWinningParty}",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black))),

            SizedBox(height: 15),
            if (info.overallWinningParty == "No clear winner") ...[
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Possible Winner\n",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: "Possible alliances that can form the majority:",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ...findWinningAlliances(info.partyWins, info.threshold).map((alliance) {
                return Text("\nAlliance: ${alliance.join(' + ')} → ${alliance.fold(0, (sum, party) => sum + (info.partyWins[party] ?? 0))} constituencies");
              }).toList(),
            ],

          ],
        ),
      ),
    );
  }

  /// UI Card 2: Party Results Card
  Widget _buildStoppedElectionPartyResultsCard( Map<String, dynamic> resultData, stoppedElectionResultInfo info) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.teal.shade200,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children:
          // partyResults.keys.map((party)
          (info.partyResults.keys.toList()..sort())                // Sort party names alphabetically
              .map((party)
          {
            bool isExpanded = _expandedState[party] ?? false;
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: EdgeInsets.symmetric(vertical: 5),    //  gap between internal party-cards
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      "Party: $party",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                      ),
                      onPressed: () {
                        setState(() {
                          _expandedState[party] = !isExpanded;
                        });
                      },
                    ),
                  ),
                  if (isExpanded)
                    Column(
                      children:
                      // partyResults[party]!
                      (info.partyResults[party]!..sort((a, b) => a["constituency"].compareTo(b["constituency"])))      // showing constituencies in alphabetical order
                          .map((constituencyData) {

                        // Get winner data, if any.
                        bool isWinner = constituencyData["candidateId"] ==
                            info.constituencyWinners[constituencyData["constituency"]]?["candidateId"];
                        int leadMargin = (constituencyData["voteCount"] - (info.constituencyWinners[constituencyData["constituency"]]?["voteCount"] ?? 0)).abs();

                        // return Card(
                        //   color: isWinner
                        //       ? Colors.green.shade100
                        //       : Colors.red.shade100,
                        //   margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        //   // shape: RoundedRectangleBorder(
                        //   //   borderRadius: BorderRadius.circular(12),
                        //   // ),
                        //   child: ListTile(
                        //     // contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),            // The gap between data  & border of card
                        //     leading: Icon(isWinner ? Icons.star : Icons.person),
                        //     title: Column(
                        //       crossAxisAlignment: CrossAxisAlignment.start,
                        //       children: [
                        //         Text(
                        //           constituencyData["constituency"],
                        //           style: TextStyle(fontWeight: FontWeight.bold),
                        //         ),
                        //         SizedBox(height: 4),
                        //         Text(
                        //           "${constituencyData["candidateId"]}",
                        //           style: TextStyle(fontWeight: FontWeight.bold),
                        //         ),
                        //         SizedBox(height: 4),
                        //         Row(
                        //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //           children: [
                        //             Text("Votes: ${constituencyData["voteCount"]}"),
                        //             Text(
                        //               isWinner ? "Won" : "-$leadMargin",
                        //               style: TextStyle(
                        //                 color: isWinner ? Colors.green : Colors.red,
                        //                 fontWeight: FontWeight.bold,
                        //               ),
                        //             ),
                        //           ],
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // );
                        ///
                        return Card(
                          color: isWinner
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          // shape: RoundedRectangleBorder(
                          //   borderRadius: BorderRadius.circular(12),
                          // ),
                          child: ListTile(
                            // contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),            // The gap between data  & border of card
                            // leading: Icon(isWinner ? Icons.star : Icons.person),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Candidate Profile Photo
                                    Container(
                                      width: 50,
                                      height: 50,
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
                                            constituencyData["name"] ?? 'N/A',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            constituencyData["constituency"] ?? 'N/A',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis, // Prevents overflow
                                            maxLines: 1, // Keeps it in one line
                                          ),
                                          SizedBox(height: 4),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("Votes: ${constituencyData["voteCount"]}",
                                                style: TextStyle( fontWeight: FontWeight.bold, ),
                                              ),
                                              Text(
                                                isWinner ? "Won" : "-$leadMargin",
                                                style: TextStyle(
                                                  color: isWinner ? Colors.green : Colors.red,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
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
                                    detailRow_For_8("Age:", constituencyData["age"]?.toString()),
                                    detailRow_For_8("Gender:", constituencyData["gender"]),
                                    detailRow_For_8("Education:", constituencyData["education"]),
                                    detailRow_For_8("Profession:", constituencyData["profession"]),
                                    detailRow_For_8("Home State:", constituencyData["candidateHomeState"]),
                                    detailRow_For_8("Email:", constituencyData["candidateId"]),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  SizedBox(height: 4),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// UI Card 3: Constituency Results Card
  Widget _buildStoppedElectionConstituencyResultsCard(Map<String, dynamic> resultData, stoppedElectionResultInfo info ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)),
      // color: Colors.blue.shade100,
      color: Colors.teal.shade200,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        // child: Column(        /// Not for nota vote count card
        child: Column(           /// for nota vote count card
          children:
          // constituencyResults.keys
          (info.constituencyResults.keys.toList()..sort())           // Showing constituencies alphabetically
              .map((constituency) {

            // Retrieve the NOTA vote count for the current constituency.
            String notaCount = "0";
            if (info.electionMetadata != null && info.electionMetadata!.containsKey(constituency)) {
              var meta = info.electionMetadata![constituency];
              if (meta is Map<String, dynamic> && meta.containsKey('notaVotes')) {
                notaCount = meta['notaVotes'].toString();
              }
            }

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              margin: EdgeInsets.symmetric(vertical: 5),           //  gap between internal constituency-cards
              child: Column(
                children: [
                  ListTile(
                    title: Text(constituency,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    trailing: IconButton(
                      icon: Icon(
                          expandedConstituencies[constituency] ==
                              true  ? Icons.expand_less : Icons.expand_more),
                      onPressed: () {
                        print("Checking election status...");
                        print("Party results: ${info.partyResults.length}");
                        print("Constituency winners: ${info.constituencyWinners.length}");
                        print("Overall winner: ${info.overallWinningParty}");

                        setState(() {
                          expandedConstituencies[constituency] =
                          !(expandedConstituencies[
                          constituency] ??
                              false);
                        });
                      },
                    ),
                  ),
                  if (expandedConstituencies[constituency] == true)
                    Column(

                      /// Not for nota vote count card
                      // children:
                      // constituencyResults[constituency]!.map((candidate) {
                      /// for nota vote count card
                      children: [
                        ...info.constituencyResults[constituency]!.map((candidate) {
                          var winnerData = info.constituencyWinners[constituency];
                          bool isWinner = false;
                          int leadMargin = 0;
                          if (winnerData != null) {
                            isWinner = candidate["candidateId"] == winnerData["candidateId"];
                            leadMargin = isWinner ? 0 : candidate["voteCount"] - (winnerData["voteCount"] ?? 0);
                          }
                          // bool isWinner = candidate["candidateId"] ==
                          //     constituencyWinners[constituency]![
                          //     'candidateId'];
                          // int leadMargin = isWinner
                          //     ? 0
                          //     : candidate["voteCount"] -
                          //     constituencyWinners[constituency]![
                          //     'voteCount'];
                          return Card(
                            color: isWinner
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            margin: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            child: ListTile(
                              // contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),  // The gap between data  & border of card
                              // leading: Icon(isWinner
                              //     ? Icons.star
                              //     : Icons.person),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                // children: [
                                //   Text(candidate["candidateId"],
                                //       style: TextStyle(
                                //           fontWeight:
                                //           FontWeight.bold)),
                                //   SizedBox(height: 4),
                                //   Text(candidate["party"],
                                //       style: TextStyle(
                                //           fontWeight:
                                //           FontWeight.bold)),
                                //   SizedBox(height: 4),
                                //   Row(
                                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                //     children: [
                                //       Text("Votes: ${candidate["voteCount"]}"),
                                //       // Text(
                                //       //   leadMargin >= 0
                                //       //       ? "Won" : "$leadMargin",
                                //       //   style: TextStyle(
                                //       //     color: leadMargin >= 0 ? Colors.green : Colors.red,
                                //       //     fontWeight: FontWeight.bold,),
                                //       // ),
                                //       Text(
                                //         winnerData == null ? "0" : (isWinner ? "Won" : "$leadMargin"),
                                //         style: TextStyle(
                                //           color: winnerData == null
                                //               ? Colors.orange
                                //               : (isWinner ? Colors.green : Colors.red),
                                //           fontWeight: FontWeight.bold,
                                //         ),
                                //       ),
                                //     ],
                                //   ),
                                // ],
                                ///
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // Candidate Profile Photo
                                      Container(
                                        width: 50,
                                        height: 50,
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
                                              candidate["name"] ?? 'N/A',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              candidate["party"] ?? 'N/A',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis, // Prevents overflow
                                              maxLines: 1, // Keeps it in one line
                                            ),
                                            SizedBox(height: 4),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text("Votes: ${candidate["voteCount"]}",
                                                  style: TextStyle( fontWeight: FontWeight.bold, ),
                                                ),
                                                // Text(
                                                //   leadMargin >= 0
                                                //       ? "Won" : "$leadMargin",
                                                //   style: TextStyle(
                                                //     color: leadMargin >= 0 ? Colors.green : Colors.red,
                                                //     fontWeight: FontWeight.bold,),
                                                // ),
                                                Text(
                                                  winnerData == null ? "0" : (isWinner ? "Won" : "$leadMargin"),
                                                  style: TextStyle(
                                                    color: winnerData == null
                                                        ? Colors.orange
                                                        : (isWinner ? Colors.green : Colors.red),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
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
                                      detailRow_For_8("Age:", candidate["age"]?.toString()),
                                      detailRow_For_8("Gender:", candidate["gender"]),
                                      detailRow_For_8("Education:", candidate["education"]),
                                      detailRow_For_8("Profession:", candidate["profession"]),
                                      detailRow_For_8("Home State:", candidate["candidateHomeState"]),
                                      detailRow_For_8("Email:", candidate["candidateId"]),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        /// shows nota vote count card only if votes are there
                        // // Display NOTA vote count card for the constituency if metadata is available.
                        // if (notaVotesText.isNotEmpty)
                        // Card(
                        //   color: Colors.orange.shade100,
                        //   margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        //   child: ListTile(
                        //     title: Text(
                        //       notaVotesText,
                        //       style: TextStyle(
                        //         fontSize: 14,
                        //         fontWeight: FontWeight.normal,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        /// Always show NOTA vote count card.
                        Card(
                          color: Colors.orange.shade100,
                          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: ListTile(
                            leading: Icon(
                              Icons.block,
                              color: Colors.orange,
                              size: 30, // Increase size to make it visually bolder
                              opticalSize: 48, // Only works in newer Flutter versions
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "NOTA Votes",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold, // Bold text
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  notaCount,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold, // Bold text
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )

                      ],
                    ),
                  SizedBox(height: 5),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<List<stoppedElectionResultInfo>> getStoppedElection({ required String year, required String state, required String electionType }) async {
    // Future<void> getStoppedElection() async {
    // Future<List<ElectionResultInfo>> fetchElectionResults() async {

    List<stoppedElectionResultInfo> stoppedElections = [];

    // Reset/initialize maps -->  Useing local variables for each call
    Map<String, int> partyWins = {}; // Map<String, int>
    Map<String, List<Map<String, dynamic>>> partyResults = {}; // Map<String, List<Map<String, dynamic>>>
    Map<String, List<Map<String, dynamic>>> constituencyResults = {}; // Map<String, List<Map<String, dynamic>>>
    Map<String, Map<String, dynamic>> constituencyWinners = {}; // Map<String, Map<String, dynamic>>
    String overallWinningParty = "";
    bool hasTies = false ;
    int threshold = 0;
    Map<String, dynamic>? electionMetadata;



    String fetchedResultPath = '';
    if
    (electionType == "General (Lok Sabha)" || electionType == "Council of States (Rajya Sabha)")
    { fetchedResultPath = "Vote Chain/Election/$year/$electionType/State/$state/Result/Fetched_Result/"; }
    else if
    ( electionType == "State Assembly (Vidhan Sabha)" || electionType == "Legislary Council (Vidhan Parishad)" || electionType == "Municipal" || electionType == "Panchayat")
    { fetchedResultPath = "Vote Chain/State/$state/Election/$year/$electionType/Result/Fetched_Result/"; }


    print ("\n\n\n********** $fetchedResultPath") ;

    try
    {
      var resultSnapshot = await FirebaseFirestore.instance.doc(fetchedResultPath).get();
      if (resultSnapshot.exists)
      {
        var votes = resultSnapshot.data()?['votes'] ?? {};

        electionMetadata = resultSnapshot.data()?['Metadata'] ?? {};
        // Assign Metadata (if exists) to our state variable.
        setState(() {
          electionMetadata = resultSnapshot.data()?['Metadata'] ?? {};
        });

        // Populate maps: constituencyResults & partyResults
        votes.forEach((candidateId, data) {

          // Skip the _NOTA entry
          if (candidateId == "_NOTA") {
            print("Skipping _NOTA entry.");
            return;
          }

          String party = data['party'] ?? 'Unknown';
          String constituency = data['constituency'] ?? 'Unknown';
          int voteCount = int.tryParse(data['vote_count']?.toString() ?? "0") ?? 0;

          // Fetch additional details
          String name = data['name'] ?? 'N/A';
          String age = data['age']?.toString() ?? 'N/A';
          String gender = data['gender'] ?? 'N/A';
          String education = data['education'] ?? 'N/A';
          String profession = data['profession'] ?? 'N/A';
          String homeState = data['homeState'] ?? 'N/A';

          print("Vote count for $name: $voteCount");


          // For constituency results:
          constituencyResults.putIfAbsent(constituency, () => []);
          constituencyResults[constituency]!.add({
            "candidateId": candidateId,
            "party": party,
            "voteCount": voteCount,
            "name": name,
            "age": age,
            "gender": gender,
            "education": education,
            "profession": profession,
            "homeState": homeState,
            // Optionally add other candidate details here if needed.
          });

          // For party-wise results:
          partyResults.putIfAbsent(party, () => []);
          partyResults[party]!.add({
            "candidateId": candidateId,
            "voteCount": voteCount,
            "constituency": constituency,
            "name": name,
            "age": age,
            "gender": gender,
            "education": education,
            "profession": profession,
            "homeState": homeState,
          });
        });

        // Process each constituency to determine its winner.
        int totalConstituencies = constituencyResults.keys.length;
        constituencyResults.forEach((constituency, candidates) {
          // Sort candidates by voteCount descending.
          candidates.sort((a, b) => b["voteCount"].compareTo(a["voteCount"]));

          // Check for tie or no votes:
          if (candidates.isNotEmpty)
          {
            int topVotes = candidates.first["voteCount"];
            bool isTie = candidates.length > 1 &&
                candidates[1]["voteCount"] == topVotes;
            if (topVotes > 0 && !isTie)
            {
              // Clear winner exists in this constituency.
              var winner = candidates.first;
              constituencyWinners[constituency] = {
                "candidateId": winner["candidateId"],
                "party": winner["party"],
                "voteCount": winner["voteCount"],
                "name": winner["name"],
                "age": winner["age"],
                "gender": winner["gender"],
                "education": winner["education"],
                "profession": winner["profession"],
                "homeState": winner["homeState"],
              };

              // Count this win for the party.
              partyWins[winner["party"]] = (partyWins[winner["party"]] ?? 0) + 1;
            }
            else
            {
              // No clear winner if tie or zero votes.
              print("No clear winner in constituency: $constituency");

              /// shows only constituency name in which tie is there among top candidates
              // // Tie detected – store a custom message instead.
              // constituencyWinners[constituency] = {"message": "\nTie between top candidates. Lottery will decide winner." };
              /// shows constituency name + party names in which tie is there among top candidates
              // // Tie detected – collect unique party names among tied candidates.
              List<String> tiedParties = candidates
                  .where((c) => c["voteCount"] == topVotes)
                  .map<String>((c) => c["party"])
                  .toSet()
                  .toList();
              constituencyWinners[constituency] = {"tiedParties": tiedParties};
              print("Tie in $constituency between parties: ${tiedParties.join(', ')}");

              // Check if there are any ties
              hasTies = constituencyWinners.values.any((entry) => entry.containsKey("tiedParties"));

            }
          }
        });

        // Calculate threshold for winning election:
        // int threshold = (totalConstituencies / 2).ceil() + 1;

        // int threshold = totalConstituencies > 0 ? (totalConstituencies / 2).ceil() + 1 : 1;
        threshold = totalConstituencies > 0 ? (totalConstituencies / 2).ceil() + 1 : 1;
        print("Total constituencies: $totalConstituencies, Threshold: $threshold");

        // Find if any party has reached the threshold.
        String winnerParty = "";
        partyWins.forEach((party, wins) {
          if (wins >= threshold) {
            winnerParty = party;
          }
        });

        overallWinningParty = winnerParty.isNotEmpty ? winnerParty : "No clear winner";
        print("Overall Winning Party: $overallWinningParty");

        // Build the ElectionResultInfo object
        stoppedElections.add(stoppedElectionResultInfo(
          doc: resultSnapshot,
          electionType: electionType,
          year: year,
          state: state,
          partyWins: partyWins,
          partyResults: partyResults,
          constituencyResults: constituencyResults,
          constituencyWinners: constituencyWinners,
          hasTies: hasTies,
          threshold: threshold,
          overallWinningParty: overallWinningParty,
          electionMetadata: electionMetadata,
        ));
      }
      else
      {
        SnackbarUtils.showErrorMessage(context, 'Problem occurred in checking election status.');
        SnackbarUtils.showErrorMessage(context, 'Unhandled stage for type: $electionType (state: $state, year: $year)');
        print("No result document for stopped election type: $electionType (state: $state, year: $year) at $fetchedResultPath");
      }

      // setState(() {
      //   isLoading = false;
      // });

      // return fetchedElections;        // Return the fetched list once all processing is done.
      return stoppedElections;
    }
    catch (e)
    {
      setState(() {
        // elections = [];
        // print("**** Fetched elections: $elections");  // for testing print & check
        isLoading = false;
      });
      print("Error fetching election results: $e");
      return [];      // Return an empty list in case of error.
    }
  }  // Old name was --> "fetchElectionResults()"


  /// Depending on the current stage:
  /// - currentStage == 6: Voting hasn't started; show basic UI (party-candidates-constituency--->cards).
  /// - currentStage == 7: Election ongoing; show basic UI (party-candidates-constituency--->cards).
  /// - currentStage >= 8 and isFirebaseElectionActive is false: Election stopped; fetch full results, to show  (party-candidates-constituency--->result cards).
  ///
  @override
  Widget build(BuildContext context) {
    // If the election hasn't stopped, show a simplified UI.

    ///
    //  // if (currentStage == 6 || currentStage == 7)
    //  if (widget.role == "Citizen_Current_Election" ||  widget.role == "Admin")
    //  {
    //    // if (isLoading) { return Center(child: CircularProgressIndicator()); }
    //    // if (elections.isEmpty) { return Center(child: Text("No elections found.")); }
    //    // return ListView.builder(
    //    //   itemCount: elections.length,
    //    //   itemBuilder: (context, index) {
    //    //     final electionInfo = elections[index];
    //    //     // Convert document data to a Map
    //    //     final resultData =
    //    //     Map<String, dynamic>.from(electionInfo.doc.data() as Map);
    //    //     return _buildElectionCard(resultData, electionInfo);
    //    //   },
    //    // );
    //    /// better approach
    //    return FutureBuilder<List<BaseElectionResult>>(
    //      future: electionStatusFuture,
    //      builder: (context, snapshot) {
    //        if (snapshot.connectionState == ConnectionState.waiting) { return Center(child: CircularProgressIndicator()); }
    //        else if (snapshot.hasError) { return Center(child: Text("Error: ${snapshot.error}"));  }
    //        else if (!snapshot.hasData || snapshot.data!.isEmpty) { return Center(child: Text("No elections found."));  }
    //        else
    //        {
    //          final elections = snapshot.data!;
    //          return ListView.builder(
    //            itemCount: elections.length,
    //            itemBuilder: (context, index) {
    //              final BaseElectionResult electionInfo = elections[index];
    //              // // If doc exists, extract its data as a Map; otherwise use an empty Map.
    //              // final resultData = Map<String, dynamic>.from(electionInfo is ElectionResultInfo ? electionInfo.doc.data() as Map : "" );
    //              final resultData = electionInfo.doc != null
    //                  ? Map<String, dynamic>.from(electionInfo.doc!.data() as Map)
    //                  : <String, dynamic>{};
    //              return _buildElectionCard(resultData, electionInfo);
    //            },
    //          );
    //        }
    //      },
    //    );
    // }
    //
    //  // Otherwise, if detailed results have been fetched, show the full results.
    //  return Scaffold(
    //    body: isLoading
    //        ? Center(child: CircularProgressIndicator())
    //        : constituencyResults.isEmpty
    //        ? Center(
    //          child: Text(
    //            'No results available.',
    //            style: TextStyle(fontSize: 18, color: Colors.grey),
    //          ),
    //        )
    //        : Padding(
    //          padding: const EdgeInsets.all(16.0),
    //          child: ListView(
    //            children: [
    //              Card(
    //                elevation: 4,
    //                shape: RoundedRectangleBorder(
    //                    borderRadius: BorderRadius.circular(10)),
    //                // color: Colors.blue.shade100,
    //                color: Colors.teal.shade200,
    //                margin: EdgeInsets.symmetric(vertical: 10),
    //                child: Padding(
    //                  padding: const EdgeInsets.all(16.0),
    //                  child: Column(
    //                    crossAxisAlignment: CrossAxisAlignment.start,
    //                    children: [
    //                      Center(
    //                          child: Text("Election Summary",
    //                              style: TextStyle(
    //                                  fontSize: 20,
    //                                  fontWeight: FontWeight.bold))),
    //                      SizedBox(height: 8),
    //                      /// shows only constituency name in which tie is there among top candidates
    //                      // ...partyWins.entries.map((entry) {
    //                      //   return Text(
    //                      //       "\n${entry.key}: \n${entry.value} constituencies won");
    //                      // }).toList(),
    //                      // SizedBox(height: 10),
    //                      // Center(
    //                      //   child: Text("Constituency Ties\nTie between top candidates. Lottery will decide winner.",
    //                      //       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
    //                      // ),
    //                      // ...constituencyWinners.entries.map((entry) {
    //                      //   if (entry.value.containsKey("message")) {
    //                      //     return Text("\n${entry.key}: ${entry.value['message']}");
    //                      //   } else {
    //                      //     return SizedBox.shrink();
    //                      //   }
    //                      // }).toList(),
    //                      /// shows constituency name + party names in which tie is there among top candidates
    //                      ...partyWins.entries.map((entry) {
    //                        return Text("\n${entry.key}: \n${entry.value} constituencies won");
    //                      }).toList(),
    //                      SizedBox(height: 15),
    //                      ///
    //                      // Center(
    //                      //   child: Text(
    //                      //     "Constituency Ties\n(Tie between top candidates. Lottery will decide winner.)",
    //                      //     style: TextStyle(
    //                      //       fontSize: 18,
    //                      //       fontWeight: FontWeight.bold,
    //                      //       color: Colors.black,
    //                      //     ),
    //                      //   ),
    //                      // ),
    //                      ///
    //                      // Center(
    //                      //   child: RichText(
    //                      //     textAlign: TextAlign.center,
    //                      //     text: TextSpan(
    //                      //       children: [
    //                      //         TextSpan(
    //                      //           text: "Candidate Ties\n",
    //                      //           style: TextStyle(
    //                      //             fontSize: 18,
    //                      //             fontWeight: FontWeight.bold,
    //                      //             color: Colors.black,
    //                      //           ),
    //                      //         ),
    //                      //         TextSpan(
    //                      //           text: "Tie between top candidates in respective constituency. Lottery will decide winner.",
    //                      //           style: TextStyle(
    //                      //             fontSize: 14, // smaller size
    //                      //             fontWeight: FontWeight.normal, // not bold
    //                      //             color: Colors.black,
    //                      //           ),
    //                      //         ),
    //                      //       ],
    //                      //     ),
    //                      //   ),
    //                      // ),
    //                      // ...constituencyWinners.entries.map((entry) {
    //                      //   // If the entry has tiedParties, show them.
    //                      //   if (entry.value.containsKey("tiedParties")) {
    //                      //     List tiedParties = entry.value["tiedParties"];
    //                      //     return Text("\n${entry.key}:\n${tiedParties.join(', ')}");
    //                      //   } else {
    //                      //     // For constituencies with a clear winner, nothing extra is shown.
    //                      //     return SizedBox.shrink();
    //                      //   }
    //                      // }).toList(),
    //                      ///
    //                      // Conditionally display "Candidate Ties" only if there are actual ties.
    //                      if (hasTies) ...[
    //                        Center(
    //                          child: RichText(
    //                            textAlign: TextAlign.center,
    //                            text: TextSpan(
    //                              children: [
    //                                TextSpan(
    //                                  text: "Candidate Ties\n",
    //                                  style: TextStyle(
    //                                    fontSize: 18,
    //                                    fontWeight: FontWeight.bold,
    //                                    color: Colors.black,
    //                                  ),
    //                                ),
    //                                TextSpan(
    //                                  text: "Tie between top candidates in respective constituency. Lottery will decide winner.",
    //                                  style: TextStyle(
    //                                    fontSize: 14, // smaller size
    //                                    fontWeight: FontWeight.normal, // not bold
    //                                    color: Colors.black,
    //                                  ),
    //                                ),
    //                              ],
    //                            ),
    //                          ),
    //                        ),
    //                        ...constituencyWinners.entries.map((entry) {
    //                          if (entry.value.containsKey("tiedParties")) {
    //                            List tiedParties = entry.value["tiedParties"];
    //                            return Text("\n${entry.key}:\n${tiedParties.join(', ')}");
    //                          } else {
    //                            return SizedBox.shrink();
    //                          }
    //                        }).toList(),
    //                      ],
    //
    //                      SizedBox(height: 15),
    //                      Center(
    //                          child: Text("Overall Winner:",
    //                              style: TextStyle(
    //                                  fontSize: 18,
    //                                  fontWeight: FontWeight.bold,
    //                                  color: Colors.black))),
    //                      SizedBox(height: 3),
    //                      Center(
    //                          child: Text("$overallWinningParty",
    //                              style: TextStyle(
    //                                  fontSize: 18,
    //                                  fontWeight: FontWeight.bold,
    //                                  color: Colors.black))),
    //
    //                      SizedBox(height: 15),
    //                      if (overallWinningParty == "No clear winner") ...[
    //                        Center(
    //                          child: RichText(
    //                            textAlign: TextAlign.center,
    //                            text: TextSpan(
    //                              children: [
    //                                TextSpan(
    //                                  text: "Possible Winner\n",
    //                                  style: TextStyle(
    //                                    fontSize: 18,
    //                                    fontWeight: FontWeight.bold,
    //                                    color: Colors.black,
    //                                  ),
    //                                ),
    //                                TextSpan(
    //                                  text: "Possible alliances that can form the majority:",
    //                                  style: TextStyle(
    //                                    fontSize: 14,
    //                                    fontWeight: FontWeight.normal,
    //                                    color: Colors.black,
    //                                  ),
    //                                ),
    //                              ],
    //                            ),
    //                          ),
    //                        ),
    //                        ...findWinningAlliances(partyWins, threshold).map((alliance) {
    //                          return Text("\nAlliance: ${alliance.join(' + ')} → ${alliance.fold(0, (sum, party) => sum + (partyWins[party] ?? 0))} constituencies");
    //                        }).toList(),
    //                      ],
    //
    //                    ],
    //                  ),
    //                ),
    //              ),
    //
    //              SizedBox(height: 15),
    //              Card(
    //                elevation: 4,
    //                shape: RoundedRectangleBorder(
    //                  borderRadius: BorderRadius.circular(10),
    //                ),
    //                color: Colors.teal.shade200,
    //                margin: EdgeInsets.symmetric(vertical: 10),
    //                child: Padding(
    //                  padding: const EdgeInsets.all(8.0),
    //                  child: Column(
    //                    children:
    //                    // partyResults.keys.map((party)
    //                    (partyResults.keys.toList()..sort())                // Sort party names alphabetically
    //                        .map((party)
    //                    {
    //                      bool isExpanded = _expandedState[party] ?? false;
    //                      return Card(
    //                        elevation: 2,
    //                        shape: RoundedRectangleBorder(
    //                          borderRadius: BorderRadius.circular(10),
    //                        ),
    //                        margin: EdgeInsets.symmetric(vertical: 5),    //  gap between internal party-cards
    //                        child: Column(
    //                          children: [
    //                            ListTile(
    //                              title: Text(
    //                                "Party: $party",
    //                                style: TextStyle(
    //                                  fontSize: 18,
    //                                  fontWeight: FontWeight.bold,
    //                                ),
    //                              ),
    //                              trailing: IconButton(
    //                                icon: Icon(
    //                                  isExpanded ? Icons.expand_less : Icons.expand_more,
    //                                ),
    //                                onPressed: () {
    //                                  setState(() {
    //                                    _expandedState[party] = !isExpanded;
    //                                  });
    //                                },
    //                              ),
    //                            ),
    //                            if (isExpanded)
    //                              Column(
    //                                children:
    //                                // partyResults[party]!
    //                                (partyResults[party]!..sort((a, b) => a["constituency"].compareTo(b["constituency"])))      // showing constituencies in alphabetical order
    //                                    .map((constituencyData) {
    //
    //                                  // Get winner data, if any.
    //                                  bool isWinner = constituencyData["candidateId"] ==
    //                                      constituencyWinners[constituencyData["constituency"]]?["candidateId"];
    //                                  int leadMargin = (constituencyData["voteCount"] - (constituencyWinners[constituencyData["constituency"]]?["voteCount"] ?? 0)).abs();
    //
    //                                  // return Card(
    //                                  //   color: isWinner
    //                                  //       ? Colors.green.shade100
    //                                  //       : Colors.red.shade100,
    //                                  //   margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
    //                                  //   // shape: RoundedRectangleBorder(
    //                                  //   //   borderRadius: BorderRadius.circular(12),
    //                                  //   // ),
    //                                  //   child: ListTile(
    //                                  //     // contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),            // The gap between data  & border of card
    //                                  //     leading: Icon(isWinner ? Icons.star : Icons.person),
    //                                  //     title: Column(
    //                                  //       crossAxisAlignment: CrossAxisAlignment.start,
    //                                  //       children: [
    //                                  //         Text(
    //                                  //           constituencyData["constituency"],
    //                                  //           style: TextStyle(fontWeight: FontWeight.bold),
    //                                  //         ),
    //                                  //         SizedBox(height: 4),
    //                                  //         Text(
    //                                  //           "${constituencyData["candidateId"]}",
    //                                  //           style: TextStyle(fontWeight: FontWeight.bold),
    //                                  //         ),
    //                                  //         SizedBox(height: 4),
    //                                  //         Row(
    //                                  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                                  //           children: [
    //                                  //             Text("Votes: ${constituencyData["voteCount"]}"),
    //                                  //             Text(
    //                                  //               isWinner ? "Won" : "-$leadMargin",
    //                                  //               style: TextStyle(
    //                                  //                 color: isWinner ? Colors.green : Colors.red,
    //                                  //                 fontWeight: FontWeight.bold,
    //                                  //               ),
    //                                  //             ),
    //                                  //           ],
    //                                  //         ),
    //                                  //       ],
    //                                  //     ),
    //                                  //   ),
    //                                  // );
    //                                  ///
    //                                  return Card(
    //                                    color: isWinner
    //                                        ? Colors.green.shade100
    //                                        : Colors.red.shade100,
    //                                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
    //                                    // shape: RoundedRectangleBorder(
    //                                    //   borderRadius: BorderRadius.circular(12),
    //                                    // ),
    //                                    child: ListTile(
    //                                      // contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),            // The gap between data  & border of card
    //                                      // leading: Icon(isWinner ? Icons.star : Icons.person),
    //                                      title: Column(
    //                                        crossAxisAlignment: CrossAxisAlignment.start,
    //                                        children: [
    //                                          Row(
    //                                            crossAxisAlignment: CrossAxisAlignment.center,
    //                                            children: [
    //                                              // Candidate Profile Photo
    //                                              Container(
    //                                                width: 50,
    //                                                height: 50,
    //                                                decoration: BoxDecoration(
    //                                                  // color: Colors.teal.shade200,
    //                                                  // gradient: LinearGradient(
    //                                                  //   colors: [Colors.teal.shade200, Colors.teal.shade600],
    //                                                  //   begin: Alignment.topLeft,
    //                                                  //   end: Alignment.bottomRight,
    //                                                  // ),
    //                                                  gradient: LinearGradient(
    //                                                    colors: [Colors.teal.shade300, Colors.indigo.shade400],
    //                                                    begin: Alignment.topLeft,
    //                                                    end: Alignment.bottomRight,
    //                                                  ),
    //                                                  // gradient: LinearGradient(
    //                                                  //   colors: [Colors.tealAccent.shade400, Colors.teal.shade800],
    //                                                  //   begin: Alignment.topLeft,
    //                                                  //   end: Alignment.bottomRight,
    //                                                  // ),
    //                                                  borderRadius: BorderRadius.circular(10),
    //                                                ),
    //                                                child: Icon(Icons.person, color: Colors.white, size: 40),
    //                                              ),
    //                                              SizedBox(width: 12),
    //
    //                                              // Name and Email Column
    //                                              Expanded(
    //                                                child: Column(
    //                                                  crossAxisAlignment: CrossAxisAlignment.start,
    //                                                  children: [
    //                                                    Text(
    //                                                      constituencyData["name"] ?? 'N/A',
    //                                                      style: TextStyle(
    //                                                        fontWeight: FontWeight.bold,
    //                                                        fontSize: 17,
    //                                                        color: Colors.black87,
    //                                                      ),
    //                                                    ),
    //                                                    SizedBox(height: 5),
    //                                                    Text(
    //                                                      constituencyData["constituency"] ?? 'N/A',
    //                                                      style: TextStyle(
    //                                                        fontSize: 16,
    //                                                        color: Colors.black,
    //                                                        fontWeight: FontWeight.bold,
    //                                                      ),
    //                                                      overflow: TextOverflow.ellipsis, // Prevents overflow
    //                                                      maxLines: 1, // Keeps it in one line
    //                                                    ),
    //                                                    SizedBox(height: 4),
    //                                                    Row(
    //                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                                                      children: [
    //                                                        Text("Votes: ${constituencyData["voteCount"]}",
    //                                                          style: TextStyle( fontWeight: FontWeight.bold, ),
    //                                                        ),
    //                                                        Text(
    //                                                          isWinner ? "Won" : "-$leadMargin",
    //                                                          style: TextStyle(
    //                                                            color: isWinner ? Colors.green : Colors.red,
    //                                                            fontWeight: FontWeight.bold,
    //                                                          ),
    //                                                        ),
    //                                                      ],
    //                                                    ),
    //                                                  ],
    //                                                ),
    //                                              ),
    //                                            ],
    //                                          ),
    //
    //
    //
    //                                          SizedBox(height: 10), // Space before other details
    //                                          Divider(color: Colors.grey),
    //
    //                                          // Candidate Details List
    //                                          Column(
    //                                            crossAxisAlignment: CrossAxisAlignment.start,
    //                                            children: [
    //                                              detailRow_For_8("Age:", constituencyData["age"]?.toString()),
    //                                              detailRow_For_8("Gender:", constituencyData["gender"]),
    //                                              detailRow_For_8("Education:", constituencyData["education"]),
    //                                              detailRow_For_8("Profession:", constituencyData["profession"]),
    //                                              detailRow_For_8("Home State:", constituencyData["candidateHomeState"]),
    //                                              detailRow_For_8("Email:", constituencyData["candidateId"]),
    //                                            ],
    //                                          ),
    //                                        ],
    //                                      ),
    //                                    ),
    //                                  );
    //                                }).toList(),
    //                              ),
    //                            SizedBox(height: 4),
    //                          ],
    //                        ),
    //                      );
    //                    }).toList(),
    //                  ),
    //                ),
    //              ),
    //
    //              SizedBox(height: 15),
    //              Card(
    //                elevation: 4,
    //                shape: RoundedRectangleBorder(
    //                    borderRadius: BorderRadius.circular(10)),
    //                // color: Colors.blue.shade100,
    //                color: Colors.teal.shade200,
    //                margin: EdgeInsets.symmetric(vertical: 10),
    //                child: Padding(
    //                  padding: const EdgeInsets.all(8.0),
    //                  // child: Column(        /// Not for nota vote count card
    //                  child: Column(           /// for nota vote count card
    //                    children:
    //                    // constituencyResults.keys
    //                    (constituencyResults.keys.toList()..sort())           // Showing constituencies alphabetically
    //                        .map((constituency) {
    //
    //                      // Retrieve the NOTA vote count for the current constituency.
    //                      String notaCount = "0";
    //                      if (electionMetadata != null && electionMetadata!.containsKey(constituency)) {
    //                        var meta = electionMetadata![constituency];
    //                        if (meta is Map<String, dynamic> && meta.containsKey('notaVotes')) {
    //                          notaCount = meta['notaVotes'].toString();
    //                        }
    //                      }
    //
    //                      return Card(
    //                        elevation: 2,
    //                        shape: RoundedRectangleBorder(
    //                            borderRadius: BorderRadius.circular(10)),
    //                        margin: EdgeInsets.symmetric(vertical: 5),           //  gap between internal constituency-cards
    //                        child: Column(
    //                          children: [
    //                            ListTile(
    //                              title: Text(constituency,
    //                                  style: TextStyle(
    //                                      fontSize: 18,
    //                                      fontWeight: FontWeight.bold)),
    //                              trailing: IconButton(
    //                                icon: Icon(
    //                                    expandedConstituencies[constituency] ==
    //                                        true  ? Icons.expand_less : Icons.expand_more),
    //                                onPressed: () {
    //                                  print("Checking election status...");
    //                                  print("Party results: ${partyResults.length}");
    //                                  print("Constituency winners: ${constituencyWinners.length}");
    //                                  print("Overall winner: $overallWinningParty");
    //
    //                                  setState(() {
    //                                    expandedConstituencies[constituency] =
    //                                    !(expandedConstituencies[
    //                                    constituency] ??
    //                                        false);
    //                                  });
    //                                },
    //                              ),
    //                            ),
    //                            if (expandedConstituencies[constituency] == true)
    //                              Column(
    //
    //                                /// Not for nota vote count card
    //                                // children:
    //                                // constituencyResults[constituency]!.map((candidate) {
    //                                /// for nota vote count card
    //                                children: [
    //                                  ...constituencyResults[constituency]!.map((candidate) {
    //                                    var winnerData = constituencyWinners[constituency];
    //                                    bool isWinner = false;
    //                                    int leadMargin = 0;
    //                                    if (winnerData != null) {
    //                                      isWinner = candidate["candidateId"] == winnerData["candidateId"];
    //                                      leadMargin = isWinner ? 0 : candidate["voteCount"] - (winnerData["voteCount"] ?? 0);
    //                                    }
    //                                    // bool isWinner = candidate["candidateId"] ==
    //                                    //     constituencyWinners[constituency]![
    //                                    //     'candidateId'];
    //                                    // int leadMargin = isWinner
    //                                    //     ? 0
    //                                    //     : candidate["voteCount"] -
    //                                    //     constituencyWinners[constituency]![
    //                                    //     'voteCount'];
    //                                    return Card(
    //                                      color: isWinner
    //                                          ? Colors.green.shade100
    //                                          : Colors.red.shade100,
    //                                      margin: EdgeInsets.symmetric(
    //                                          vertical: 5, horizontal: 10),
    //                                      child: ListTile(
    //                                        // contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),  // The gap between data  & border of card
    //                                        // leading: Icon(isWinner
    //                                        //     ? Icons.star
    //                                        //     : Icons.person),
    //                                        title: Column(
    //                                          crossAxisAlignment: CrossAxisAlignment.start,
    //                                          // children: [
    //                                          //   Text(candidate["candidateId"],
    //                                          //       style: TextStyle(
    //                                          //           fontWeight:
    //                                          //           FontWeight.bold)),
    //                                          //   SizedBox(height: 4),
    //                                          //   Text(candidate["party"],
    //                                          //       style: TextStyle(
    //                                          //           fontWeight:
    //                                          //           FontWeight.bold)),
    //                                          //   SizedBox(height: 4),
    //                                          //   Row(
    //                                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                                          //     children: [
    //                                          //       Text("Votes: ${candidate["voteCount"]}"),
    //                                          //       // Text(
    //                                          //       //   leadMargin >= 0
    //                                          //       //       ? "Won" : "$leadMargin",
    //                                          //       //   style: TextStyle(
    //                                          //       //     color: leadMargin >= 0 ? Colors.green : Colors.red,
    //                                          //       //     fontWeight: FontWeight.bold,),
    //                                          //       // ),
    //                                          //       Text(
    //                                          //         winnerData == null ? "0" : (isWinner ? "Won" : "$leadMargin"),
    //                                          //         style: TextStyle(
    //                                          //           color: winnerData == null
    //                                          //               ? Colors.orange
    //                                          //               : (isWinner ? Colors.green : Colors.red),
    //                                          //           fontWeight: FontWeight.bold,
    //                                          //         ),
    //                                          //       ),
    //                                          //     ],
    //                                          //   ),
    //                                          // ],
    //                                          ///
    //                                          children: [
    //                                            Row(
    //                                              crossAxisAlignment: CrossAxisAlignment.center,
    //                                              children: [
    //                                                // Candidate Profile Photo
    //                                                Container(
    //                                                  width: 50,
    //                                                  height: 50,
    //                                                  decoration: BoxDecoration(
    //                                                    // color: Colors.teal.shade200,
    //                                                    // gradient: LinearGradient(
    //                                                    //   colors: [Colors.teal.shade200, Colors.teal.shade600],
    //                                                    //   begin: Alignment.topLeft,
    //                                                    //   end: Alignment.bottomRight,
    //                                                    // ),
    //                                                    gradient: LinearGradient(
    //                                                      colors: [Colors.teal.shade300, Colors.indigo.shade400],
    //                                                      begin: Alignment.topLeft,
    //                                                      end: Alignment.bottomRight,
    //                                                    ),
    //                                                    // gradient: LinearGradient(
    //                                                    //   colors: [Colors.tealAccent.shade400, Colors.teal.shade800],
    //                                                    //   begin: Alignment.topLeft,
    //                                                    //   end: Alignment.bottomRight,
    //                                                    // ),
    //                                                    borderRadius: BorderRadius.circular(10),
    //                                                  ),
    //                                                  child: Icon(Icons.person, color: Colors.white, size: 40),
    //                                                ),
    //                                                SizedBox(width: 12),
    //
    //                                                // Name and Email Column
    //                                                Expanded(
    //                                                  child: Column(
    //                                                    crossAxisAlignment: CrossAxisAlignment.start,
    //                                                    children: [
    //                                                      Text(
    //                                                        candidate["name"] ?? 'N/A',
    //                                                        style: TextStyle(
    //                                                          fontWeight: FontWeight.bold,
    //                                                          fontSize: 17,
    //                                                          color: Colors.black87,
    //                                                        ),
    //                                                      ),
    //                                                      SizedBox(height: 5),
    //                                                      Text(
    //                                                        candidate["party"] ?? 'N/A',
    //                                                        style: TextStyle(
    //                                                          fontSize: 16,
    //                                                          color: Colors.black,
    //                                                          fontWeight: FontWeight.bold,
    //                                                        ),
    //                                                        overflow: TextOverflow.ellipsis, // Prevents overflow
    //                                                        maxLines: 1, // Keeps it in one line
    //                                                      ),
    //                                                      SizedBox(height: 4),
    //                                                      Row(
    //                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                                                        children: [
    //                                                          Text("Votes: ${candidate["voteCount"]}",
    //                                                            style: TextStyle( fontWeight: FontWeight.bold, ),
    //                                                          ),
    //                                                          // Text(
    //                                                          //   leadMargin >= 0
    //                                                          //       ? "Won" : "$leadMargin",
    //                                                          //   style: TextStyle(
    //                                                          //     color: leadMargin >= 0 ? Colors.green : Colors.red,
    //                                                          //     fontWeight: FontWeight.bold,),
    //                                                          // ),
    //                                                          Text(
    //                                                            winnerData == null ? "0" : (isWinner ? "Won" : "$leadMargin"),
    //                                                            style: TextStyle(
    //                                                              color: winnerData == null
    //                                                                  ? Colors.orange
    //                                                                  : (isWinner ? Colors.green : Colors.red),
    //                                                              fontWeight: FontWeight.bold,
    //                                                            ),
    //                                                          ),
    //                                                        ],
    //                                                      ),
    //                                                    ],
    //                                                  ),
    //                                                ),
    //                                              ],
    //                                            ),
    //                                            SizedBox(height: 10), // Space before other details
    //                                            Divider(color: Colors.grey),
    //
    //                                            // Candidate Details List
    //                                            Column(
    //                                              crossAxisAlignment: CrossAxisAlignment.start,
    //                                              children: [
    //                                                detailRow_For_8("Age:", candidate["age"]?.toString()),
    //                                                detailRow_For_8("Gender:", candidate["gender"]),
    //                                                detailRow_For_8("Education:", candidate["education"]),
    //                                                detailRow_For_8("Profession:", candidate["profession"]),
    //                                                detailRow_For_8("Home State:", candidate["candidateHomeState"]),
    //                                                detailRow_For_8("Email:", candidate["candidateId"]),
    //                                              ],
    //                                            ),
    //                                          ],
    //                                        ),
    //                                      ),
    //                                    );
    //                                  }).toList(),
    //                                  /// shows nota vote count card only if votes are there
    //                                  // // Display NOTA vote count card for the constituency if metadata is available.
    //                                  // if (notaVotesText.isNotEmpty)
    //                                  // Card(
    //                                  //   color: Colors.orange.shade100,
    //                                  //   margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
    //                                  //   child: ListTile(
    //                                  //     title: Text(
    //                                  //       notaVotesText,
    //                                  //       style: TextStyle(
    //                                  //         fontSize: 14,
    //                                  //         fontWeight: FontWeight.normal,
    //                                  //       ),
    //                                  //     ),
    //                                  //   ),
    //                                  // ),
    //                                  /// Always show NOTA vote count card.
    //                                  Card(
    //                                    color: Colors.orange.shade100,
    //                                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
    //                                    child: ListTile(
    //                                      leading: Icon(
    //                                        Icons.block,
    //                                        color: Colors.orange,
    //                                        size: 30, // Increase size to make it visually bolder
    //                                        opticalSize: 48, // Only works in newer Flutter versions
    //                                      ),                                        title: Row(
    //                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                                      children: [
    //                                        Text(
    //                                          "NOTA Votes",
    //                                          style: TextStyle(
    //                                            fontSize: 15,
    //                                            fontWeight: FontWeight.bold, // Bold text
    //                                            color: Colors.black87,
    //                                          ),
    //                                        ),
    //                                        Text(
    //                                          notaCount,
    //                                          style: TextStyle(
    //                                            fontSize: 15,
    //                                            fontWeight: FontWeight.bold, // Bold text
    //                                            color: Colors.black87,
    //                                          ),
    //                                        ),
    //                                      ],
    //                                    ),
    //                                    ),
    //                                  )
    //
    //                                ],
    //                              ),
    //                            SizedBox(height: 5),
    //                          ],
    //                        ),
    //                      );
    //                    }).toList(),
    //                  ),
    //                ),
    //              ),
    //            ],
    //          ),
    //         ),
    //  );

    ///
    if
    (
     widget.role == "Citizen_Current_Election" || widget.role == "Citizen_specificPreviousElectionViewingResult" ||  widget.role == "Admin"  || widget.role == "Guest_specificElectionViewingResult"  ||
      widget.role == "PartyHead_specificElectionViewingResult" || widget.role == "Candidate_specificElectionViewingResult"
    )
    {
      // if (isLoading) { return Center(child: CircularProgressIndicator()); }
      // if (elections.isEmpty) { return Center(child: Text("No elections found.")); }
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
      /// better approach
      return FutureBuilder<List<BaseElectionResult>>(
        future: electionStatusFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) { return Center(child: CircularProgressIndicator()); }
          else if (snapshot.hasError) { return Center(child: Text("Error: ${snapshot.error}"));  }
          else if (!snapshot.hasData || snapshot.data!.isEmpty) { return Center(child: Text("No elections found.", style: TextStyle(fontSize: 16) ));  }
          else
          {
            final elections = snapshot.data!;
            return ListView.builder(
              itemCount: elections.length,
              itemBuilder: (context, index) {
                final BaseElectionResult electionInfo = elections[index];
                // // If doc exists, extract its data as a Map; otherwise use an empty Map.
                // final resultData = Map<String, dynamic>.from(electionInfo is ElectionResultInfo ? electionInfo.doc.data() as Map : "" );
                final resultData = electionInfo.doc != null
                    ? Map<String, dynamic>.from(electionInfo.doc!.data() as Map)
                    : <String, dynamic>{};

                if
                (electionInfo is ElectionResultInfo)
                { return _buildElectionCard(resultData, electionInfo); }               // Ongoing election UI (stage 6 or 7)
                else if
                (electionInfo is stoppedElectionResultInfo)
                {  return _buildStoppedElectionCard(resultData,electionInfo);  }       // Stopped election UI (stage >= 8)
                else
                { return SizedBox.shrink(); }
              },
            );
          }
        },
      );
    }
    else
    {
      // Handle other roles
      return Container();
    }
  }
}
abstract class BaseElectionResult {
  DocumentSnapshot? get doc;
  String get electionType;
  String get year;
  String get state;
}
class ElectionResultInfo extends BaseElectionResult {

  @override
  final DocumentSnapshot doc;
  @override
  final String electionType;
  @override
  final String year;
  @override
  final String state;

  ElectionResultInfo({
    required this.doc,
    required this.electionType,
    required this.year,
    required this.state,
  });
}  // Model to hold fetched ongoing election result with metadata
class stoppedElectionResultInfo extends BaseElectionResult {
  @override
  final DocumentSnapshot doc;
  @override
  final String electionType;
  @override
  final String year;
  @override
  final String state;
  final Map<String, int> partyWins;
  final Map<String, List<Map<String, dynamic>>> partyResults;
  final Map<String, List<Map<String, dynamic>>> constituencyResults;
  final Map<String, dynamic> constituencyWinners;
  final bool hasTies;
  final int threshold;
  final String overallWinningParty;
  final Map<String, dynamic>? electionMetadata; // Populated in fetchElectionResults()


  stoppedElectionResultInfo({
    required this.doc,
    required this.electionType,
    required this.year,
    required this.state,
    required this.partyWins,
    required this.partyResults,
    required this.constituencyResults,
    required this.constituencyWinners,
    required this.hasTies,
    required this.threshold,
    required this.overallWinningParty,
    required this.electionMetadata,
  });
}  // Model to hold fetched stopped election result with metadata


