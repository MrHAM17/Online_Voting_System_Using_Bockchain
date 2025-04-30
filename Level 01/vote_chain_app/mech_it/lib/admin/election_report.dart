// // Election Report Screen
//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// import 'admin_service.dart';
//
// class ElectionReportScreen extends StatelessWidget {
//   final String electionId;
//   final AdminService _adminService = AdminService();
//
//   ElectionReportScreen({required this.electionId});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Election Report'),
//       ),
//       body: FutureBuilder<Map<String, dynamic>>(
//         future: _adminService.generateElectionReport(electionId),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (snapshot.hasData) {
//             Map<String, dynamic> reportData = snapshot.data!;
//             return SingleChildScrollView(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('Election Name: ${reportData['details']['name']}',
//                       style: TextStyle(fontWeight: FontWeight.bold)),
//                   SizedBox(height: 10),
//                   Text('Election Results:'),
//                   Text(reportData['results'].toString()),
//                 ],
//               ),
//             );
//           } else {
//             return Center(child: Text('No report available'));
//           }
//         },
//       ),
//     );
//   }
// }


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:csv/csv.dart';

class ReportDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> election;

  ReportDetailsScreen(this.election);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${election['electionName']} Report'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'PDF') {
                exportAsPDF();
              } else if (value == 'CSV') {
                exportAsCSV();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'PDF', child: Text('Export as PDF')),
              PopupMenuItem(value: 'CSV', child: Text('Export as CSV')),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Election Name: ${election['electionName']}'),
            SizedBox(height: 10),
            Text('Start Date: ${election['startDate']}'),
            Text('End Date: ${election['endDate']}'),
            SizedBox(height: 20),
            Text('Blockchain TX Hash: ${election['txHash']}'),
          ],
        ),
      ),
    );
  }

  Future<void> exportAsPDF() async {
    final pdf = pw.Document();  // Correct class for PDF document
    pdf.addPage(pw.Page(build: (pw.Context context) {
      return pw.Column(
        children: [
          pw.Text('Election Report', style: pw.TextStyle(fontSize: 18)),
          pw.Text('Election Name: ${election['electionName']}', style: pw.TextStyle(fontSize: 12)),
          pw.Text('Start Date: ${election['startDate']}', style: pw.TextStyle(fontSize: 12)),
          pw.Text('End Date: ${election['endDate']}', style: pw.TextStyle(fontSize: 12)),
          pw.Text('Blockchain TX Hash: ${election['txHash']}', style: pw.TextStyle(fontSize: 12)),
        ],
      );
    }));

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/election_report.pdf');
    await file.writeAsBytes(await pdf.save());

    print('PDF exported to: ${file.path}');
  }

  Future<void> exportAsCSV() async {
    final data = [
      ['Election Name', 'Start Date', 'End Date', 'Blockchain TX Hash'],
      [election['electionName'], election['startDate'], election['endDate'], election['txHash']],
    ];

    final csvData = const ListToCsvConverter().convert(data);

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/election_report.csv');
    await file.writeAsString(csvData);

    print('CSV exported to: ${file.path}');
  }
}
