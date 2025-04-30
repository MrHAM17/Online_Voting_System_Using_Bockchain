
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mech_it/SERVICE/screen/styled_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../SERVICE/backend_connectivity/smart_contract_service.dart';
import '../../SERVICE/utils/app_constants.dart';
import 'election_details.dart';
import 'package:collection/collection.dart';


class ElectionResult extends StatefulWidget {
  @override
  ElectionResultState createState() => ElectionResultState();
}

// class ElectionResultState extends State<ElectionResult> with TickerProviderStateMixin {
//   late TabController _tabController;
//   bool isSyncing = false;
//   bool isSuccess = false;
//   int syncCount = 0;
//   bool syncLimitReached = false;
//   String lastSyncDate = "";
//
//   late AnimationController _animationController;
//   late Animation<double> _rotationAnimation;
//
//   Future<void> clearPreferences() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.clear();
//     print('SharedPreferences cleared!');
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     clearPreferences();
//     _tabController = TabController(length: 2, vsync: this);
//     _loadSyncCount();
//
//     // Set up rotation animation with adjustable speed (e.g., 2 seconds for a full rotation)
//     _animationController = AnimationController(
//       duration: Duration(seconds: 10), // Adjust the speed here (higher value = slower rotation)
//       vsync: this,
//       lowerBound: 0.0,
//       upperBound: 2.0 * 3.1416, // 2π for full rotation
//     )..repeat(); // Repeat the animation indefinitely
//     _rotationAnimation = Tween(begin: 0.0, end: 2.0 * 3.1416).animate(_animationController);
//
//     _tabController.addListener(() {
//       if (_tabController.index == 1) {
//         _clearSyncTab(); // Clear sync UI when switching to second tab
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   /// Load sync count and check if a new day has started
//   Future<void> _loadSyncCount() async {
//     final prefs = await SharedPreferences.getInstance();
//     final storedDate = prefs.getString('lastSyncDate') ?? "";
//     final storedCount = prefs.getInt('syncCount') ?? 0;
//
//     String currentDate = DateTime.now().toIso8601String().split("T")[0];
//
//     if (storedDate != currentDate) {
//       // Reset sync count if a new day
//       await prefs.setInt('syncCount', 0);
//       await prefs.setString('lastSyncDate', currentDate);
//       syncCount = 0;
//       syncLimitReached = false;
//     } else {
//       syncCount = storedCount;
//       syncLimitReached = syncCount >= 3;
//     }
//
//     setState(() {});
//   }
//
//   /// Save sync count in SharedPreferences
//   Future<void> _saveSyncCount() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setInt('syncCount', syncCount);
//     await prefs.setString('lastSyncDate', DateTime.now().toIso8601String().split("T")[0]);
//   }
//
//   /// Clear sync UI when switching to another tab
//   void _clearSyncTab() {
//     setState(() {
//       isSyncing = false;
//       isSuccess = false;
//     });
//   }
//
//   /// Sync Votes Function
//   Future<void> syncVotes() async {
//     if (isSyncing || syncLimitReached) return;
//
//     if (syncCount >= 3) {
//       setState(() {
//         syncLimitReached = true;
//       });
//       return;
//     }
//
//     setState(() {
//       isSyncing = true;
//       isSuccess = false;
//     });
//
//     // await Future.delayed(Duration(seconds: 2));
//     // Just simulate the async task:
//     // await Future.delayed(Duration(seconds: 1)); // Simulating the async call delay
//     // Stop any previous animation immediately if it's still running
//     _animationController.stop();
//     // Reset the animation to start from the beginning every time the button is clicked
//     _animationController.reset();
//     // Start the rotation animation again
//     _animationController.forward(); // Start the rotation animation again

//
//     final electionDetails = ElectionDetails.instance;
//     await SmartContractService().storeVotesInFirebase(
//       electionDetails.year!,
//       electionDetails.electionType!,
//       electionDetails.state!,
//     );
//
//     setState(() {
//       isSyncing = false;
//       isSuccess = true;
//       syncCount++;
//
//       if (syncCount >= 3) {
//         syncLimitReached = true;
//       }
//     });
//
//     // Stop the animation when syncing is complete
//     _animationController.stop();
//
//     _saveSyncCount();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(
//             'Election Results',
//             style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
//           ),
//           backgroundColor: AppConstants.primaryColor,
//           centerTitle: true,
//           bottom: TabBar(
//             controller: _tabController,
//             tabs: [
//               Tab(
//                 icon: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.sync),
//                     SizedBox(width: 8),
//                     Text('Sync Votes', style: TextStyle(fontWeight: FontWeight.bold)),
//                   ],
//                 ),
//               ),
//               Tab(
//                 icon: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.settings),
//                     SizedBox(width: 8),
//                     Text('View Result', style: TextStyle(fontWeight: FontWeight.bold)),
//                   ],
//                 ),
//               ),
//             ],
//             indicatorColor: Colors.white,
//             labelColor: Colors.white,
//             unselectedLabelColor: AppConstants.secondaryColor,
//             indicatorWeight: 5.0,
//             indicatorPadding: EdgeInsets.symmetric(horizontal: 8),
//             labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
//             unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 19),
//           ),
//         ),
//         body: TabBarView(
//           controller: _tabController,
//           children: [
//             Stack(
//               children: [
//                 _buildSyncVotesTab(),
//                 if (syncLimitReached) _buildSyncLimitMessage(), // Show message only in 1st tab
//               ],
//             ),
//             // _buildSecondTab(),
//             ElectionResultSecondTab(), // Your second tab here
//
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// Fixed Card Message for Sync Limit (Only in First Tab)
//   Widget _buildSyncLimitMessage() {
//     return Positioned(
//       top: 10, // Change to bottom: 10 if you want it at the bottom
//       left: 20,
//       right: 20,
//       child: Card(
//         color: Colors.redAccent,
//         elevation: 5,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Padding(
//           padding: EdgeInsets.all(12),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.warning, color: Colors.white),
//               SizedBox(width: 8),
//               Text(
//                 'Sync limit reached for today!',
//                 style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSyncVotesTab() {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // Text(
//             //   'Sync Votes to Database',
//             //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             //   textAlign: TextAlign.center,
//             // ),
//             if (!isSuccess)
//               Text(
//                 'Sync Votes to Database',
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center,
//               ),
//             SizedBox(height: 30),
//             isSyncing
//                 ? Column(
//                   children: [
//                     AnimatedBuilder(
//                       animation: _rotationAnimation,
//                       builder: (context, child) {
//                         return Transform.rotate(
//                           angle: _rotationAnimation.value,
//                           child: child,
//                         );
//                       },
//                       child: Image.asset(
//                         'assets/images/loading.png',
//                         width: 180,
//                         height: 180,
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     Text('Syncing Votes...', style: TextStyle(fontSize: 18)),
//                   ],
//             )
//                 : isSuccess
//                 ? Column(
//                   children: [
//                       Image.asset('assets/images/success.png', width: 180, height: 180),
//                       SizedBox(height: 10),
//                       Text(
//                         'Votes Synced Successfully!',
//                         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
//                       ),
//                       SizedBox(height: 20),
//                       ElevatedButton(
//                         onPressed: () {
//                           _tabController.animateTo(1);
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blueAccent,
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                           padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                         ),
//                         child: Text('View Results', style: TextStyle(fontSize: 16)),
//                       ),
//                     ],
//                   )
//                 : GestureDetector(
//                     onTap: syncLimitReached ? null : syncVotes,
//                     child: Container(
//                       width: 130,
//                       height: 130,
//                       decoration: BoxDecoration(
//                         color: syncLimitReached ? Colors.grey : Colors.blueAccent,
//                         borderRadius: BorderRadius.circular(25),
//                         boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12, spreadRadius: 3)],
//                       ),
//                       child: Center(
//                         child: Icon(Icons.sync, size: 60, color: Colors.white),
//                       ),
//                     ),
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Widget _buildSecondTab() {
//   //   return Center(
//   //     child: Text('Second Tab Content', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//   //   );
//   // }
// }
class ElectionResultState extends State<ElectionResult> with TickerProviderStateMixin {
  late TabController _tabController;
  bool isSyncing = false;
  bool isSuccess = false;
  int syncCount = 0;
  bool syncLimitReached = false;
  String lastSyncDate = "";
  List<String> syncTimes = []; // Store the sync timestamps
  int currentStage = 0;  // Global election stage variable.
  bool isFirebaseElectionActive = true; // Initialize to avoid uninitialized variable error
  late AnimationController _loadingAnimationController;
  late AnimationController _successAnimationController;
  late Animation<double> _loadingRotationAnimation;
  late Animation<double> _successRotationAnimation;

  Future<void> clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('SharedPreferences cleared!');
  }
  @override
  void initState() {
    super.initState();
    // clearPreferences();
    _tabController = TabController(length: 2, vsync: this);
    _loadSyncCount();

    _loadCurrentStage();      // Load the current election stage once the widget initializes.

    // Loading animation controller
    _loadingAnimationController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
      lowerBound: 0.0,
      upperBound: 2.0 * 3.1416,
    )
      // ..repeat()
    ;
    _loadingRotationAnimation = Tween(begin: 0.0, end: 2.0 * 3.1416).animate(_loadingAnimationController);

    // Success animation controller
    // _successAnimationController = AnimationController(
    //   duration: Duration(seconds: 1),
    //   vsync: this,
    //   lowerBound: 0.0,
    //   upperBound: 2.0 * 3.1416,
    // )
    //   // ..repeat()
    // ;
    // _successRotationAnimation = Tween(begin: 0.0, end: 2.0 * 3.1416).animate(_successAnimationController);

    _tabController.addListener(() {
      if (_tabController.index == 1) {
        _clearSyncTab();
      }
      // if (_tabController.indexIsChanging) {
      //   _loadingAnimationController.stop();
      //   _successAnimationController.stop();
      // }

    });
  }
  @override
  void dispose() {
    _loadingAnimationController.dispose();
    // _successAnimationController.dispose();
    _tabController.dispose();
    super.dispose();
  }
  void _clearSyncTab() {
    setState(() {
      isSyncing = false;
      isSuccess = false;
    });
  }
  Future<void> _loadCurrentStage() async {
    // Check the current election stage
    final electionDetails = ElectionDetails.instance;

    String electionActivityPath = "";
    if ( electionDetails.electionType == "General (Lok Sabha)" || electionDetails.electionType == "Council of States (Rajya Sabha)")
    {  electionActivityPath = "Vote Chain/Election/${electionDetails.year}/${electionDetails.electionType}/State/${electionDetails.state}/Admin/Election Activity"; }
    else if
    (
      electionDetails.electionType == "State Assembly (Vidhan Sabha)" || electionDetails.electionType == "Legislary Council (Vidhan Parishad)"  ||
      electionDetails.electionType == "Municipal" || electionDetails.electionType == "Panchayat"
    )
    {  electionActivityPath = "Vote Chain/State/${electionDetails.state}/Election/${electionDetails.year}/${electionDetails.electionType}/Admin/Election Activity";  }

    DocumentSnapshot electionActivity = await FirebaseFirestore.instance.doc('$electionActivityPath').get();
    setState(() { currentStage = (electionActivity['currentStage'] ?? 1).toInt(); });
    String isElectionActive = electionActivity.get("isElectionActive").toString().toLowerCase();
    if (isElectionActive == "false")
    { isFirebaseElectionActive = false; }
  }
  Future<void> _loadSyncCount() async {
    final prefs = await SharedPreferences.getInstance();
    final storedDate = prefs.getString('lastSyncDate') ?? "";
    final storedCount = prefs.getInt('syncCount') ?? 0;

    String currentDate = DateTime.now().toIso8601String().split("T")[0];

    if (storedDate != currentDate) {
      await prefs.setInt('syncCount', 0);
      await prefs.setString('lastSyncDate', currentDate);
      syncCount = 0;
      syncLimitReached = false;
      syncTimes.clear(); // Clear sync times for the new day
    } else {
      syncCount = storedCount;
      syncLimitReached = syncCount >= 3;
      syncTimes = prefs.getStringList('syncTimes') ?? []; // Load sync times
    }

    setState(() {});
  }
  Future<void> syncVotes() async {
    if (isSyncing || syncLimitReached) return;

    if
    ( currentStage < 7 )
    {
      SnackbarUtils.showErrorMessage(context, "Voting isn't started,\nSo no data is present.");
      return;
    }
    else if
    (
      currentStage > 7
      && isFirebaseElectionActive == false
      // && (await SmartContractService().checkElectionStatus(ElectionDetails.instance.year!, ElectionDetails.instance.electionType!, ElectionDetails.instance.state!) == 'STOPPED')
    )
    {
      SnackbarUtils.showErrorMessage(context, "As election is stopped,\nData is already synced.");
      return;
    }

    if (syncCount >= 3) {
      setState(() {
        syncLimitReached = true;
      });
      return;
    }

    setState(() {
      isSyncing = true;
      isSuccess = false;
    });

    // // await Future.delayed(Duration(seconds: 2));
    // // Just simulate the async task:
    // // await Future.delayed(Duration(seconds: 1)); // Simulating the async call delay
    // // Stop any previous animation immediately if it's still running
    // _loadingAnimationController.stop();
    // Reset the animation to start from the beginning every time the button is clicked
    _loadingAnimationController.reset();
    _loadingAnimationController.repeat(); // Ensure continuous rotation


    try { await syncingVotes(); }       // Await syncingVotes; if an error occurs, it will be caught below.
    catch (e) {
      _loadingAnimationController.stop();         // Stop the loading animation immediately.
      SnackbarUtils.showErrorMessage(context, "Error during syncing: $e");
      setState(() {
        isSyncing = false;
      });
      return;
    }


    // Simulate the extra 1-second delay after syncing
    await Future.delayed(Duration(seconds: 1));
    // Stop the loading animation
    _loadingAnimationController.stop();

    String syncTime = DateTime.now().toIso8601String();
    syncTimes.add(syncTime); // Store the sync time
    setState(() {
      isSyncing = false;     // This updates the state to stop the syncing process
      isSuccess = true;      // This sets the success state after syncing
      syncCount++;
      if (syncCount >= 3) {
        syncLimitReached = true;
      }
    });

    // // Start success animation for 1 second
    // _successAnimationController.reset();
    // _successAnimationController.forward();

    await Future.delayed(Duration(seconds: 1));

    // // Stop success animation after 1 second
    // _successAnimationController.stop();

    _saveSyncCount();
  }
  Future<void> syncingVotes() async {
    if
    (
      currentStage == 7
      && isFirebaseElectionActive == true
      // && (await SmartContractService().checkElectionStatus(ElectionDetails.instance.year!, ElectionDetails.instance.electionType!, ElectionDetails.instance.state!) == 'STARTED')
    )
    {
      // // Sync/get all complete results/data/voteCounts
      try                                                                         // **************  ********* ** *
      { await SmartContractService().syncVotesInFirebase(  ElectionDetails.instance.year!, ElectionDetails.instance.electionType!,ElectionDetails.instance.state!,);  }
      catch (e)
      {
        // If syncing fails, show error message and stop further execution.
        SnackbarUtils.showErrorMessage(context, "Syncing Failed: $e");
        print("Error in Sync function: $e");
        throw Exception("Syncing Failed: $e");          // Rethrow the error so that it can be caught by syncVotes().
      }
    }
    else
    { throw Exception("Conditions are not met for syncing."); }       // If conditions are not met, throw an exception.
  }
  Future<void> _saveSyncCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('syncCount', syncCount);
    await prefs.setString('lastSyncDate', DateTime.now().toIso8601String().split("T")[0]);
    await prefs.setStringList('syncTimes', syncTimes); // Save sync times
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Election Results',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: AppConstants.primaryColor,
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                icon: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sync),
                    SizedBox(width: 8),
                    Text('Sync Votes', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Tab(
                icon: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 8),
                    Text('View Result', style: TextStyle(fontWeight: FontWeight.bold)),
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
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            Stack(
              children: [
                _buildSyncInfo(), // Combined widget for sync info and limit message
                _buildSyncVotesTab(),
              ],
            ),
            ElectionResultSecondTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncInfo() {
    return Positioned(
      top: 10,
      left: 20,
      right: 20,
      child: Card(
        color: syncLimitReached ? Colors.redAccent : Colors.blueGrey,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                'Last Sync Times:',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              ...syncTimes.map((syncTime) {
                // Convert the syncTime to a DateTime and format it
                DateTime parsedTime = DateTime.parse(syncTime);
                String formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(parsedTime);
                return Text(
                  formattedTime,
                  style: TextStyle(color: Colors.white),
                );
              }).toList(),
              SizedBox(height: 5),
              if (!syncLimitReached)
                Text(
                  'Remaining Syncs Today: ${3 - syncCount}',
                  style: TextStyle(color: Colors.white),
                ),
              if (syncLimitReached)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Sync limit reached for today!',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSyncVotesTab() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!isSuccess)
              Text(
                'Sync Votes to Database',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            SizedBox(height: 30),
            isSyncing
                ? Column(
                  children: [
                    AnimatedBuilder(
                      animation: _loadingRotationAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _loadingRotationAnimation.value,
                          child: child,
                        );
                      },
                      child: Image.asset(
                        'assets/images/loading.png',
                        width: 180,
                        height: 180,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('Syncing Votes...', style: TextStyle(fontSize: 18)),
                  ],
                )
                : isSuccess
                ? Column(
                  children: [
                      Image.asset('assets/images/success.jpg', width: 190, height: 190),
                      // AnimatedBuilder(
                      //   animation: _successRotationAnimation,
                      //   builder: (context, child) {
                      //     return Transform.rotate(
                      //       angle: _successRotationAnimation.value,
                      //       child: child,
                      //     );
                      //   },
                      //   child: Image.asset('assets/images/ss.jpg', width: 180, height: 180),
                      // ),
                      SizedBox(height: 10),
                      Text(
                        'Votes Synced Successfully !',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          // Check if the election has stopped before navigating
                          if
                          (currentStage <= 6)
                          {
                            SnackbarUtils.showErrorMessage(context,"Election-Voting isn't started yet.\nYou can view result after election stops.");
                            return ;
                          }
                          else if
                          (currentStage == 7)
                          {
                            // If the election is still active, show a message or do nothing
                            SnackbarUtils.showErrorMessage(context,'Election is ongoing.\nYou can view result after election stops.');
                            return ;
                          }
                          else if
                          (
                            currentStage >= 8
                            && isFirebaseElectionActive == false
                            // && (await SmartContractService().checkElectionStatus(ElectionDetails.instance.year!, ElectionDetails.instance.electionType!, ElectionDetails.instance.state!) == 'STOPPED')
                          )
                          { _tabController.animateTo(1);  }      // If the election is stopped, navigate to the next page (tab 1)
                          else
                          {
                            // If the election is still active, show a message or do nothing
                            SnackbarUtils.showErrorMessage(context,'Problem occurred in viewing result.');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        child: Text('View Results', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ],
                  )
                : GestureDetector(
                    onTap: syncLimitReached ? null : syncVotes,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        color: syncLimitReached ? Colors.grey : Colors.teal.shade400,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 12, spreadRadius: 3)],
                      ),
                      child: Center(
                        child: Icon(Icons.sync, size: 60, color: Colors.white),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class ElectionResultSecondTab extends StatefulWidget {
  @override
  _ElectionResultSecondTabState createState() => _ElectionResultSecondTabState();
}

class _ElectionResultSecondTabState extends State<ElectionResultSecondTab> {
  Map<String, List<Map<String, dynamic>>> constituencyResults = {};
  Map<String, List<Map<String, dynamic>>> partyResults = {};

  // Define a Map to hold the expanded state for each party
  Map<String, bool> _expandedState = {};
  Map<String, Map<String, dynamic>> constituencyWinners = {};
  Map<String, int> partyWins = {};
  bool isLoading = true;
  String overallWinningParty = "";
  Map<String, bool> expandedConstituencies = {};
  Map<String, dynamic>? electionMetadata; // Populated in fetchElectionResults()
  bool hasTies = false ;
  int threshold = 0;


  // Check if the election is stopped
  Future<void> checkElectionStatus() async {
    final electionDetails = ElectionDetails.instance;
    String electionActivityPath = "";

    if (electionDetails.electionType == "General (Lok Sabha)" || electionDetails.electionType == "Council of States (Rajya Sabha)")
    { electionActivityPath = "Vote Chain/Election/${electionDetails.year}/${electionDetails.electionType}/State/${electionDetails.state}/Admin/Election Activity";  }
    else if
    (
        electionDetails.electionType == "State Assembly (Vidhan Sabha)" || electionDetails.electionType == "Legislary Council (Vidhan Parishad)" ||
        electionDetails.electionType == "Municipal" || electionDetails.electionType == "Panchayat"
    )
    {  electionActivityPath = "Vote Chain/State/${electionDetails.state}/Election/${electionDetails.year}/${electionDetails.electionType}/Admin/Election Activity";  }

    try
    {
      DocumentSnapshot electionActivity = await FirebaseFirestore.instance.doc(electionActivityPath).get();
      int currentStage = (electionActivity['currentStage'] ?? 1).toInt();
      bool isFirebaseElectionActive = true ;
      String isElectionActive = electionActivity.get("isElectionActive").toString().toLowerCase();
      if (isElectionActive == "false")
      { isFirebaseElectionActive = false; }

      if
      (currentStage <= 6)
      {
        setState(() {
          isLoading = false;  // Stop the loading spinner when the election voting isn't started
        });
        SnackbarUtils.showErrorMessage(context,"Election-Voting isn't started yet.\nYou can view result after election stops.");
        return ;
      }
      else if
      (currentStage == 7)
      {
        setState(() {
          isLoading = false;  // Stop the loading spinner when the election is ongoing
        });
        // If the election is still active, show a message or do nothing
        SnackbarUtils.showErrorMessage(context,'Election is ongoing.\nYou can view result after election stops.');
        return ;
      }
      else if
      (
          currentStage >= 8
          && isFirebaseElectionActive == false
          // && (await SmartContractService().checkElectionStatus(electionDetails.year! as int, electionDetails.electionType!, electionDetails.state!) == 'STOPPED')
      )
      { fetchElectionResults(); }         // If the election is stopped then show the result.
      else
      {
        setState(() {
          isLoading = false;  // Stop the loading spinner
        });
        SnackbarUtils.showErrorMessage(context,'Problem occurred in checking election status.');
        return ;
      }
    }
    catch (e)
    {
      setState(() {
        isLoading = false;  // Stop the loading spinner
      });
      print("Error checking election status: $e");
      SnackbarUtils.showErrorMessage(context,"Error checking election status: $e");
      return ;
    }
  }

  // Future<void> fetchElectionResults() async {
  //   var electionDetails = ElectionDetails.instance;
  //   String fetchedResultPath = electionDetails.electionType!.contains("General") || electionDetails.electionType!.contains("Council")
  //       ? "Vote Chain/Election/${electionDetails.year}/${electionDetails.electionType}/State/${electionDetails.state}/Result/Fetched_Result/"
  //       : "Vote Chain/State/${electionDetails.state}/Election/${electionDetails.year}/${electionDetails.electionType}/Result/Fetched_Result/";
  //
  //   try {
  //     var resultSnapshot = await FirebaseFirestore.instance.doc(fetchedResultPath).get();
  //     if (resultSnapshot.exists) {
  //       var votes = resultSnapshot.data()?['votes'] ?? {};
  //
  //       votes.forEach((candidateId, data) {
  //         String party = data['party'];
  //
  //         // Initialize the party in partyWins if not already initialized
  //         if (!partyWins.containsKey(party)) {
  //           partyWins[party] = 0;
  //         }
  //
  //         String constituency = data['constituency'];
  //         int voteCount = int.tryParse(data['vote_count'].toString()) ?? 0;
  //
  //         constituencyResults.putIfAbsent(constituency, () => []);
  //         constituencyResults[constituency]!.add({
  //           "candidateId": candidateId,
  //           "party": party,
  //           "voteCount": voteCount,
  //           // "constituency": constituency,
  //         });
  //
  //         // Populate partyResults for party-wise constituency results
  //         partyResults.putIfAbsent(party, () => []);
  //         partyResults[party]!.add({
  //         "candidateId": candidateId,
  //         "voteCount": voteCount,
  //         "constituency": constituency,
  //         });
  //       });
  //
  //       constituencyResults.forEach((constituency, candidates) {
  //         candidates.sort((a, b) => b["voteCount"].compareTo(a["voteCount"]));
  //         var winner = candidates.first;
  //
  //         constituencyWinners[constituency] = {
  //           "candidateId": winner["candidateId"],
  //           "party": winner["party"],
  //           "voteCount": winner["voteCount"],
  //         };
  //
  //         partyWins[winner["party"]] = (partyWins[winner["party"]] ?? 0) + 1;
  //       });
  //
  //       overallWinningParty = partyWins.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  //     }
  //   } catch (e) {
  //     print("Error fetching election results: $e");
  //   }
  //
  //   setState(() {
  //     isLoading = false;
  //   });
  // }
  Future<void> fetchElectionResults() async {
    var electionDetails = ElectionDetails.instance;
    String fetchedResultPath = electionDetails.electionType!.contains("General") ||
        electionDetails.electionType!.contains("Council")
        ? "Vote Chain/Election/${electionDetails.year}/${electionDetails.electionType}/State/${electionDetails.state}/Result/Fetched_Result/"
        : "Vote Chain/State/${electionDetails.state}/Election/${electionDetails.year}/${electionDetails.electionType}/Result/Fetched_Result/";

    // Reset/initialize maps
    partyWins = {}; // Map<String, int>
    partyResults = {}; // Map<String, List<Map<String, dynamic>>>
    constituencyResults = {}; // Map<String, List<Map<String, dynamic>>>
    constituencyWinners = {}; // Map<String, Map<String, dynamic>>
    overallWinningParty = "No clear winner";

    try {
      var resultSnapshot = await FirebaseFirestore.instance.doc(fetchedResultPath).get();
      if (resultSnapshot.exists) {
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
          if (candidates.isNotEmpty) {
            int topVotes = candidates.first["voteCount"];
            bool isTie = candidates.length > 1 &&
                candidates[1]["voteCount"] == topVotes;
            if (topVotes > 0 && !isTie) {
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
            } else {
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
      }
    } catch (e) {
      print("Error fetching election results: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    checkElectionStatus();
  }

  // Widget detailRow(String label, String? value) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 2),
  //     child: Row(
  //       children: [
  //         Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
  //         SizedBox(width: 5),
  //         Text(value ?? 'N/A', style: TextStyle(color: Colors.black87)),
  //       ],
  //     ),
  //   );
  // }
  Widget detailRow(String label, String? value) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : constituencyResults.isEmpty
          ? Center(
              child: Text(
                'No results available.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Card(
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
                        /// shows constituency name + party names in which tie is there among top candidates
                        ...partyWins.entries.map((entry) {
                          return Text("\n${entry.key}: \n${entry.value} constituencies won");
                        }).toList(),
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
                        if (hasTies) ...[
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
                          ...constituencyWinners.entries.map((entry) {
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
                            child: Text("$overallWinningParty",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black))),

                        SizedBox(height: 15),
                        if (overallWinningParty == "No clear winner") ...[
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
                          ...findWinningAlliances(partyWins, threshold).map((alliance) {
                            return Text("\nAlliance: ${alliance.join(' + ')} → ${alliance.fold(0, (sum, party) => sum + (partyWins[party] ?? 0))} constituencies");
                          }).toList(),
                        ],

                      ],
                    ),
                  ),
                ),

                SizedBox(height: 15),
                Card(
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
                      (partyResults.keys.toList()..sort())                // Sort party names alphabetically
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
                                  (partyResults[party]!..sort((a, b) => a["constituency"].compareTo(b["constituency"])))      // showing constituencies in alphabetical order
                                      .map((constituencyData) {

                                    // Get winner data, if any.
                                    bool isWinner = constituencyData["candidateId"] ==
                                        constituencyWinners[constituencyData["constituency"]]?["candidateId"];
                                    int leadMargin = (constituencyData["voteCount"] - (constituencyWinners[constituencyData["constituency"]]?["voteCount"] ?? 0)).abs();

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
                                                detailRow("Age:", constituencyData["age"]?.toString()),
                                                detailRow("Gender:", constituencyData["gender"]),
                                                detailRow("Education:", constituencyData["education"]),
                                                detailRow("Profession:", constituencyData["profession"]),
                                                detailRow("Home State:", constituencyData["candidateHomeState"]),
                                                detailRow("Email:", constituencyData["candidateId"]),
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
                ),

                SizedBox(height: 15),
                Card(
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
                      (constituencyResults.keys.toList()..sort())           // Showing constituencies alphabetically
                          .map((constituency) {

                        // Retrieve the NOTA vote count for the current constituency.
                        String notaCount = "0";
                        if (electionMetadata != null && electionMetadata!.containsKey(constituency)) {
                          var meta = electionMetadata![constituency];
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
                                    print("Party results: ${partyResults.length}");
                                    print("Constituency winners: ${constituencyWinners.length}");
                                    print("Overall winner: $overallWinningParty");

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
                                    ...constituencyResults[constituency]!.map((candidate) {
                                      var winnerData = constituencyWinners[constituency];
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
                                                  detailRow("Age:", candidate["age"]?.toString()),
                                                  detailRow("Gender:", candidate["gender"]),
                                                  detailRow("Education:", candidate["education"]),
                                                  detailRow("Profession:", candidate["profession"]),
                                                  detailRow("Home State:", candidate["candidateHomeState"]),
                                                  detailRow("Email:", candidate["candidateId"]),
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
                                        ),                                        title: Row(
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
                ),
            ],
        ),
      ),
    );
  }
}


