//
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/screen.dart' as pw;
// import 'package:csv/csv.dart';
//
// class ReportDetails extends StatelessWidget {
//   final Map<String, dynamic> election;
//
//   ReportDetails(this.election);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('${election['electionName']} Report'),
//         actions: [
//           PopupMenuButton<String>(
//             onSelected: (value) {
//               if (value == 'PDF') {
//                 exportAsPDF();
//               } else if (value == 'CSV') {
//                 exportAsCSV();
//               }
//             },
//             itemBuilder: (context) => [
//               PopupMenuItem(value: 'PDF', child: Text('Export as PDF')),
//               PopupMenuItem(value: 'CSV', child: Text('Export as CSV')),
//             ],
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Election Name: ${election['electionName']}'),
//             SizedBox(height: 10),
//             Text('Start Date: ${election['startDate']}'),
//             Text('End Date: ${election['endDate']}'),
//             SizedBox(height: 20),
//             Text('Blockchain TX Hash: ${election['txHash']}'),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future Apply[ (reg) & no login ]<void> exportAsPDF() async {
//     final pdf = pw.Document();  // Correct class for PDF document
//     pdf.addPage(pw.Page(build: (pw.Context context) {
//       return pw.Column(
//         children: [
//           pw.Text('Election Report', style: pw.TextStyle(fontSize: 18)),
//           pw.Text('Election Name: ${election['electionName']}', style: pw.TextStyle(fontSize: 12)),
//           pw.Text('Start Date: ${election['startDate']}', style: pw.TextStyle(fontSize: 12)),
//           pw.Text('End Date: ${election['endDate']}', style: pw.TextStyle(fontSize: 12)),
//           pw.Text('Blockchain TX Hash: ${election['txHash']}', style: pw.TextStyle(fontSize: 12)),
//         ],
//       );
//     }));
//
//     final directory = await getApplicationDocumentsDirectory();
//     final file = File('${directory.path}/election_report.pdf');
//     await file.writeAsBytes(await pdf.save());
//
//     print('PDF exported to: ${file.path}');
//   }
//
//   Future Apply[ (reg) & no login ]<void> exportAsCSV() async {
//     final data = [
//       ['Election Name', 'Start Date', 'End Date', 'Blockchain TX Hash'],
//       [election['electionName'], election['startDate'], election['endDate'], election['txHash']],
//     ];
//
//     final csvData = const ListToCsvConverter().convert(data);
//
//     final directory = await getApplicationDocumentsDirectory();
//     final file = File('${directory.path}/election_report.csv');
//     await file.writeAsString(csvData);
//
//     print('CSV exported to: ${file.path}');
//   }
// }



import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ReportDetails extends StatefulWidget {
  @override
  _ReportDetailsState createState() => _ReportDetailsState();
}

class _ReportDetailsState extends State<ReportDetails> {
  final _firestore = FirebaseFirestore.instance;

  String? _state;
  String? _year;
  String? _electionName;

  // Fetch election reports based on citizen selection
  Stream<QuerySnapshot> _fetchElectionReports() {
    if (_state == null || _year == null || _electionName == null) {
      return const Stream.empty();
    }
    return _firestore
        .collection('Vote Chain')
        .doc('State')
        .collection(_state!)
        .doc('Election')
        .collection(_year!)
        .doc(_electionName!)
        .collection('Reports')
        .snapshots();
  }

  // Build chart data for graphical representation
  List<PieSeries<Map<String, dynamic>, String>> _buildChartData(
      List<Map<String, dynamic>> reports) {
    return [
      PieSeries<Map<String, dynamic>, String>(
        dataSource: reports,
        xValueMapper: (Map<String, dynamic> report, _) => report['category'],
        yValueMapper: (Map<String, dynamic> report, _) => report['value'],
        dataLabelSettings: DataLabelSettings(isVisible: true),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Election Reports'),
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

            // Display reports
            _state != null && _year != null && _electionName != null
                ? StreamBuilder<QuerySnapshot>(
              stream: _fetchElectionReports(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text('No reports found for the selected election.'),
                  );
                }

                final reports = snapshot.data!.docs
                    .map((doc) => {
                  'category': doc['category'],
                  'value': doc['value'],
                })
                    .toList();

                return Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Tabular view of reports
                        DataTable(
                          columns: [
                            DataColumn(label: Text('Category')),
                            DataColumn(label: Text('Value')),
                          ],
                          rows: reports
                              .map(
                                (report) => DataRow(
                              cells: [
                                DataCell(Text(report['category'])),
                                DataCell(Text(report['value'].toString())),
                              ],
                            ),
                          )
                              .toList(),
                        ),
                        SizedBox(height: 20),
                        // Graphical view of reports
                        Text(
                          'Graphical Representation:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 300,
                          child: SfCircularChart(
                            series: _buildChartData(reports),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
                : Center(
              child: Text('Select state, year, and election name to view reports.'),
            ),
          ],
        ),
      ),
    );
  }
}
