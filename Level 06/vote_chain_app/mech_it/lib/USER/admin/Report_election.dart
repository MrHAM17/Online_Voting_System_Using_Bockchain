import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../SERVICE/screen/report.dart';
import '../../SERVICE/screen/styled_widget.dart';
import '../../SERVICE/utils/app_constants.dart';
import 'election_details.dart';

class ReportDetails extends StatefulWidget {
  const ReportDetails({Key? key}) : super(key: key);

  @override
  _ReportDetailsState createState() => _ReportDetailsState();
}

class _ReportDetailsState extends State<ReportDetails> {
  bool isLoading = true;
  bool showReportScreen = false;
  final electionDetails = ElectionDetails.instance;


  @override
  void initState() {
    super.initState();
    checkElectionStatus();
  }

  Future<void> checkElectionStatus() async {
    String electionActivityPath = "";

    // Build Firestore path based on the election type.
    if
    ( electionDetails.electionType == "General (Lok Sabha)" || electionDetails.electionType == "Council of States (Rajya Sabha)")
    { electionActivityPath =  "Vote Chain/Election/${electionDetails.year}/${electionDetails.electionType}/State/${electionDetails.state}/Admin/Election Activity"; }
    else if
    (
      electionDetails.electionType == "State Assembly (Vidhan Sabha)" || electionDetails.electionType == "Legislary Council (Vidhan Parishad)" ||
      electionDetails.electionType == "Municipal" || electionDetails.electionType == "Panchayat"
    )
    { electionActivityPath =  "Vote Chain/State/${electionDetails.state}/Election/${electionDetails.year}/${electionDetails.electionType}/Admin/Election Activity"; }

    try
    {
      DocumentSnapshot activitySnapshot =  await FirebaseFirestore.instance.doc(electionActivityPath).get();

      // Assume currentStage and isElectionActive are stored in this document.
      int currentStage = (activitySnapshot['currentStage'] ?? 1).toInt();
      String isElectionActive = activitySnapshot.get("isElectionActive").toString().toLowerCase();
      bool firebaseElectionActive = isElectionActive == "true";

      if (currentStage <= 6)
      {
        setState(() {
          isLoading = false;
          showReportScreen = false;
        });
        SnackbarUtils.showErrorMessage(context,"Election voting isn't started yet.\nYou can view reports after the election stops.",  );
      }
      else if (currentStage == 7 && firebaseElectionActive)
      {
        setState(() {
          isLoading = false;
          showReportScreen = false;
        });
        SnackbarUtils.showSuccessMessage(context,"Election is ongoing.\nYou can view results after the election stops.",);
      }
      else if (currentStage >= 8 && !firebaseElectionActive)
      {
        // Election is stopped; display the ReportScreen within this widget.
        setState(() {
          isLoading = false;
          showReportScreen = true;
        });
      }
      else
      {
        setState(() {
          isLoading = false;
          showReportScreen = false;
        });
        SnackbarUtils.showErrorMessage(context,"Problem occurred in checking election status.", );
      }
    }
    catch (e)
    {
      setState(() {
        isLoading = false;
        showReportScreen = false;
      });
      print("Error checking election status: $e");
      SnackbarUtils.showErrorMessage(context,"Error checking election status: $e", );
    }
  }

  @override
  Widget build(BuildContext context) {
    // When report should be shown, render the ReportScreen widget in place.
    return Scaffold(
      appBar: AppBar(
        title: const Text("Election Reports",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppConstants.appBarColor,
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppConstants.appBarColor),
              ),
            )
          : showReportScreen
          ? ReportScreen(
              electionType: "${electionDetails.electionType}",
              state: "${electionDetails.state}",
              year: "${electionDetails.year}",
              role: "Admin_specificElectionViewingReport",
            )
          : Center(
              child: Text(
                "Reports will be available once the election concludes.",
                textAlign: TextAlign.center,  // Ensures text is centered inside the container
                style: TextStyle(fontSize: 16),
              ),
            ),
    );
  }
}
