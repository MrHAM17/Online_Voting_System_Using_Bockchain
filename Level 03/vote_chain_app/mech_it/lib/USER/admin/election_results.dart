import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ElectionResult extends StatefulWidget {
  @override
  _ElectionResultState createState() => _ElectionResultState();
}

class _ElectionResultState extends State<ElectionResult> {
  final _firestore = FirebaseFirestore.instance;

  String? _state;
  String? _year;
  String? _electionName;

  // Fetch election results based on citizen selection
  Stream<QuerySnapshot> _fetchElectionResults() {
    return _firestore
        .collection('Vote Chain')
        .doc('State')
        .collection(_state!)
        .doc('Election')
        .collection(_year!)
        .doc(_electionName!)
        .collection('Candidates')
        .snapshots();
  }

  // Build pie chart data for graphical representation
  List<PieSeries<Map<String, dynamic>, String>> _buildPieChartData(
      List<Map<String, dynamic>> candidates) {
    return [
      PieSeries<Map<String, dynamic>, String>(
        dataSource: candidates,
        xValueMapper: (candidate, _) => candidate['candidateName'],
        yValueMapper: (candidate, _) => candidate['voteCount'],
        dataLabelMapper: (candidate, _) =>
        '${candidate['candidateName']}: ${candidate['voteCount']}',
        dataLabelSettings: DataLabelSettings(isVisible: true),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Election Results'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown inputs for state, year, and election name
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'State'),
              items: ['State1', 'State2', 'State3'] // Add your states here
                  .map((state) => DropdownMenuItem(
                value: state,
                child: Text(state),
              ))
                  .toList(),
              onChanged: (value) => setState(() => _state = value),
              validator: (value) => value == null ? 'Select a state' : null,
            ),
            SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(labelText: 'Year'),
              keyboardType: TextInputType.number,
              onChanged: (value) => setState(() => _year = value),
            ),
            SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(labelText: 'Election Name'),
              onChanged: (value) => setState(() => _electionName = value),
            ),
            SizedBox(height: 20),

            // Display results
            _state != null && _year != null && _electionName != null
                ? StreamBuilder<QuerySnapshot>(
              stream: _fetchElectionResults(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator());
                }
                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                        'No results found for the selected election.'),
                  );
                }

                final candidates = snapshot.data!.docs
                    .map((doc) => {
                  'candidateName': doc['candidateName'],
                  'partyName': doc['partyName'] ?? 'Independent',
                  'voteCount': doc['voteCount'],
                })
                    .toList();

                return Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Tabular view of results
                        DataTable(
                          columns: [
                            DataColumn(label: Text('candidate')),
                            DataColumn(label: Text('Party')),
                            DataColumn(label: Text('Votes')),
                          ],
                          rows: candidates
                              .map(
                                (candidate) => DataRow(
                              cells: [
                                DataCell(Text(candidate[
                                'candidateName'])),
                                DataCell(Text(
                                    candidate['partyName'])),
                                DataCell(Text(candidate['voteCount']
                                    .toString())),
                              ],
                            ),
                          )
                              .toList(),
                        ),
                        SizedBox(height: 20),
                        // Graphical view of results (Pie Chart)
                        Text(
                          'Graphical Representation:',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 300,
                          child: SfCircularChart(
                            legend: Legend(
                              isVisible: true,
                              overflowMode: LegendItemOverflowMode.wrap,
                            ),
                            series: _buildPieChartData(candidates),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
                : Center(
              child: Text(
                  'Select state, year, and election name to view results.'),
            ),
          ],
        ),
      ),
    );
  }
}
