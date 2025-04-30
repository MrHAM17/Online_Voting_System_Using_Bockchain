


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../SERVICE/utils/app_constants.dart';
import 'election_details.dart';

class ManageElection extends StatefulWidget {
  @override
  _ManageElectionState createState() => _ManageElectionState();
}

class _ManageElectionState extends State<ManageElection> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String electionPath;
  int currentStage = 1;

  @override
  void initState() {
    super.initState();
    electionPath = getBasePath();
    _fetchCurrentStage();
  }

  Future<void> _fetchCurrentStage() async {
    try {
      DocumentSnapshot electionDoc =
      await _firestore.doc('$electionPath/Admin/Election Activity').get();
      if (electionDoc.exists) {
        setState(() {
          currentStage = (electionDoc['currentStage'] ?? 1).toInt();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching stage: $e")));
    }
  }

  Future<void> _updateStage(int stage) async {
    bool confirmAction = await _showConfirmationDialog(stage);
    if (!confirmAction) return;

    try
    {
      await _firestore.doc('$electionPath/Admin/Election Activity').set({
        'currentStage': stage + 1,
        '${AppConstants.stageFirestoreNames[stage - 1]}': 'Completed',
        '${AppConstants.stageFirestoreNames[stage - 1]}_timestamp':
        DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
      setState(() {
        currentStage = stage + 1;
      });
    }
    catch (e)
    { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error updating stage: $e"))); }
  }

  Future<bool> _showConfirmationDialog(int stage) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Action"),
        content: Text(
            "Are you sure you want to proceed with ${AppConstants.stageLabels[stage - 1]}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Yes"),
          ),
        ],
      ),
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.appBarColor,
        title: Center(
          child: Text(
            'Manage Election',
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Image
          // Positioned(
          //   top: 0,
          //   left: 0,
          //   right: 0,
          //   child: Container(
          //     height: 200,
          //     decoration: BoxDecoration(
          //       image: DecorationImage(
          //         image: AssetImage("assets/images/election_banner.jpg"), // Change image path
          //         fit: BoxFit.cover,
          //       ),
          //     ),
          //   ),
          // ),

          // Card with Buttons
          Positioned(
            top: 40,
            bottom: 40,
            left: 0,
            right: 0,
            child: Card(
              color: Colors.white,
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(7, (index) {
                    int stage = index + 1;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: ElevatedButton(
                        onPressed: (stage == currentStage)
                            ? () => _updateStage(stage)
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          (stage == currentStage) ? Colors.teal : Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: Text(
                          AppConstants.stageLabels[index],
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
