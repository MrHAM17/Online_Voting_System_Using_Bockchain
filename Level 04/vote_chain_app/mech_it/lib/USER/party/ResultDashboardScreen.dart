import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../SERVICE/screen/styled_widget.dart';
import '../../SERVICE/utils/app_constants.dart';

class ElectionResultsScreen extends StatefulWidget {
  final String partyId;

  ElectionResultsScreen({Key? key, required this.partyId}) : super(key: key);

  @override
  _ElectionResultsScreenState createState() => _ElectionResultsScreenState();
}

class _ElectionResultsScreenState extends State<ElectionResultsScreen> {
  final _electionYearController = TextEditingController();
  final _electionTypeController = TextEditingController();
  final _stateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.secondaryColor.withOpacity(0.1),
      appBar: AppBar(
        backgroundColor: AppConstants.appBarColor,
        title: Text('Election Results'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                _showFilterCard();
              },
              child: Text('Filter Results'),
            ),
            // Results will be displayed here after filtering
          ],
        ),
      ),
    );
  }

  void _showFilterCard() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Card(
          margin: EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _electionYearController,
                  decoration: InputDecoration(
                    labelText: 'Election Year',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _electionTypeController,
                  decoration: InputDecoration(
                    labelText: 'Election Type',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _stateController,
                  decoration: InputDecoration(
                    labelText: 'State Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _fetchResults,
                  child: Text('Fetch Results'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _fetchResults() async {
    String electionYear = _electionYearController.text;
    String electionType = _electionTypeController.text;
    String stateName = _stateController.text;

    if (electionYear.isEmpty || electionType.isEmpty || stateName.isEmpty) {
      SnackbarUtils.showErrorMessage(context,"Please fill all fields");
      return;
    }

    // Fetching election results from Firebase based on filters
    var resultData = await FirebaseFirestore.instance
        .collection('Vote Chain')
        .doc('State')
        .collection(stateName)
        .doc('Election')
        .collection(electionYear)
        .doc(electionType)
        .collection('Result')
        .get();

    // Display result data in your UI
    // You can modify this part as per your result display logic
    resultData.docs.forEach((result) {
      print(result.data());
    });
  }
}
