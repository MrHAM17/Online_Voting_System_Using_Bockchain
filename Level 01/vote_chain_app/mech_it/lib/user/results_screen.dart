// import 'package:flutter/material.dart';
//
// class ResultsScreen extends StatelessWidget {
//   final Map<String, int> results = {
//     "Candidate A": 120,
//     "Candidate B": 95,
//     "Candidate C": 60,
//   };
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Election Results'),
//       ),
//       body: ListView(
//         children: results.entries.map((entry) {
//           return ListTile(
//             title: Text(entry.key),
//             trailing: Text('${entry.value} votes'),
//           );
//         }).toList(),
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ResultsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Election Results')),
      body: FutureBuilder(
        // You can use Firebase or a mock list for the chart data
        future: fetchResults(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final results = snapshot.data as Map<String, int>;

          final chartData = results.entries
              .map((entry) => ChartData(entry.key, entry.value))
              .toList();

          return SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            series: <CartesianSeries<ChartData, String>>[
              BarSeries<ChartData, String>(
                dataSource: chartData,
                xValueMapper: (ChartData data, _) => data.candidate,
                yValueMapper: (ChartData data, _) => data.votes,
                color: Colors.blue,
              ),
            ],
          );
        },
      ),
    );
  }

  // Mock data fetching function (replace with Firebase data fetching)
  Future<Map<String, int>> fetchResults() async {
    await Future.delayed(Duration(seconds: 2)); // Simulate loading delay
    return {
      'Candidate A': 120,
      'Candidate B': 80,
      'Candidate C': 100,
    };
  }
}

class ChartData {
  final String candidate;
  final int votes;

  ChartData(this.candidate, this.votes);
}
