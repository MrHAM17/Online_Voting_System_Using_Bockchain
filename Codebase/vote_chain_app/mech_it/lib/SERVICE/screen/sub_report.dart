// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import '../../SERVICE/utils/app_constants.dart';
// import '../../USER/admin/election_details.dart';
//
// /// Data model for detailed report data (if needed)
// class ReportDetail {
//   final String constituency;
//   final Map<String, dynamic> data;
//
//   ReportDetail({required this.constituency, required this.data});
// }
//
// /// DetailedElectionReportScreen displays a text-based, detailed summary
// /// of the election metadata and votes for each constituency.
// class SubReportScreen extends StatefulWidget {
//   const SubReportScreen({Key? key}) : super(key: key);
//
//   @override
//   _SubReportScreenState createState() => _SubReportScreenState();
// }
//
// class _SubReportScreenState extends State<SubReportScreen> {
//   bool isLoading = true;
//   Map<String, dynamic> reportData = {};
//   List<ReportDetail> constituencyReports = [];
//   Map<String, double> overallPartyVotes = {};
//
//   @override
//   void initState() {
//     super.initState();
//     fetchAndProcessData();
//   }
//
//   Future<void> fetchAndProcessData() async {
//     try {
//       // Use your ElectionDetails singleton (or any other source) for filters
//       final electionDetails = ElectionDetails.instance;
//       final isGeneral = electionDetails.electionType!.contains("General") ||
//           electionDetails.electionType!.contains("Council");
//       final path = isGeneral
//           ? "Vote Chain/Election/${electionDetails.year}/${electionDetails.electionType}/State/${electionDetails.state}/Result/Fetched_Result/"
//           : "Vote Chain/State/${electionDetails.state}/Election/${electionDetails.year}/${electionDetails.electionType}/Result/Fetched_Result/";
//
//       DocumentSnapshot snapshot = await FirebaseFirestore.instance.doc(path).get();
//       if (snapshot.exists) {
//         reportData = snapshot.data() as Map<String, dynamic>;
//         final metadata = reportData['Metadata'] as Map<String, dynamic>? ?? {};
//         final votes = reportData['votes'] as Map<String, dynamic>? ?? {};
//
//         // Process each constituency from metadata
//         metadata.forEach((constituency, data) {
//           if (data is Map<String, dynamic>) {
//             constituencyReports.add(ReportDetail(constituency: constituency, data: data));
//           }
//         });
//
//         // Aggregate overall party votes from votes map
//         final partyVotes = <String, double>{};
//         votes.forEach((_, candidateData) {
//           if (candidateData is Map<String, dynamic> && candidateData['party'] != null) {
//             String party = candidateData['party'];
//             double voteCount = (candidateData['vote_count'] as num).toDouble();
//             partyVotes[party] = (partyVotes[party] ?? 0) + voteCount;
//           }
//         });
//         overallPartyVotes = partyVotes;
//       }
//     } catch (e) {
//       print("Error fetching detailed report data: $e");
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   /// Helper: Format the metadata for a single constituency as a paragraph.
//   String formatConstituencyReport(Map<String, dynamic> data) {
//     // Remove keys we don't want to display (optional).
//     // In this example, we display all key-value pairs.
//     StringBuffer buffer = StringBuffer();
//     data.forEach((key, value) {
//       // Skip 'dataTable' if present.
//       if (key == 'dataTable') return;
//       // Clean the key: remove any prefixes if desired.
//       String cleanKey = key.replaceAll('_', ' ');
//       buffer.writeln("$cleanKey: $value");
//     });
//     return buffer.toString();
//   }
//
//   /// Helper: Format overall party votes as a paragraph.
//   String formatPartyVotes(Map<String, double> partyVotes) {
//     StringBuffer buffer = StringBuffer();
//     partyVotes.forEach((party, votes) {
//       buffer.writeln("$party: $votes votes");
//     });
//     return buffer.toString();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: isLoading
//           ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppConstants.appBarColor)))
//           : SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Report Title
//             Center(
//               child: Text(
//                 "${ElectionDetails.instance.electionType}\n${ElectionDetails.instance.state}, ${ElectionDetails.instance.year}",
//                 textAlign: TextAlign.center,
//                 style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                   fontWeight: FontWeight.bold,
//                   color: AppConstants.appBarColor,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),
//
//             // Section: Constituency Details
//             Text("Constituency Details:", style: Theme.of(context).textTheme.titleLarge),
//             const Divider(),
//             ListView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: constituencyReports.length,
//               itemBuilder: (context, index) {
//                 final report = constituencyReports[index];
//                 return Card(
//                   elevation: 3,
//                   margin: const EdgeInsets.symmetric(vertical: 8),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           report.constituency,
//                           style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           formatConstituencyReport(report.data),
//                           style: const TextStyle(fontSize: 14, color: Colors.black87),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//
//             const SizedBox(height: 24),
//
//             // Section: Overall Party Performance
//             Text("Overall Party Performance:", style: Theme.of(context).textTheme.titleLarge),
//             const Divider(),
//             Card(
//               elevation: 3,
//               margin: const EdgeInsets.symmetric(vertical: 8),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Text(
//                   formatPartyVotes(overallPartyVotes),
//                   style: const TextStyle(fontSize: 14, color: Colors.black87),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


/// 1 - above code has only logs in text
/// 2 - below code only has graphs

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../SERVICE/utils/app_constants.dart';

/// Data model for generic charts.
class ChartData {
  final String label;
  final double value;
  ChartData(this.label, this.value);
}

/// Data model for time series charts.
class TimeSeriesData {
  final String time;
  final double votes;
  TimeSeriesData(this.time, this.votes);
}

/// SubReportScreen fetches real data from Firestore (both from "Metadata" and "votes")
/// and then displays additional graphs per constituency inside an expandable card view.
class SubReportScreen extends StatelessWidget {
  final String electionType;
  final String state;
  final String year;
  final String role;

  const SubReportScreen({
    Key? key,
    required this.electionType,
    required this.state,
    required this.year,
    required this.role,
  }) : super(key: key);

  /// Fetch report data from Firestore using the provided filters.
  Future<Map<String, dynamic>> fetchReportData() async {
    final isGeneral =
        electionType.contains("General") || electionType.contains("Council");
    final path = isGeneral
        ? "Vote Chain/Election/$year/$electionType/State/$state/Result/Fetched_Result/"
        : "Vote Chain/State/$state/Election/$year/$electionType/Result/Fetched_Result/";
    print("Fetching report data from: $path");
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.doc(path).get();
    return snapshot.exists ? snapshot.data() as Map<String, dynamic> : {};
  }

  /// Builds a list of ChartData for the given prefix from a provided data map.
  List<ChartData> _buildChartData(Map<String, dynamic> data, String prefix) {
    final aggregated = <String, double>{};
    data.forEach((key, value) {
      if (key.startsWith(prefix)) {
        final cleanKey = key.replaceAll(prefix, '').replaceAll('_', ' ');
        aggregated[cleanKey] =
            (aggregated[cleanKey] ?? 0) + (value as num).toDouble();
         // (aggregated[cleanKey] ?? 0.0) + (value as num).toDouble();
      }
    });
    return aggregated.entries
        .map((e) => ChartData(e.key, e.value))
        .toList();
  }

  /// Aggregates party votes directly from the votes map.
  Future<List<ChartData>> _getPartyVotes(
      Map<String, dynamic> votes, {
        double? notaVotes,
      }) async {
    final partyVotes = <String, double>{};

    // Aggregate candidate votes for parties (ignoring "_NOTA" candidates)
    votes.forEach((_, candidateData) {
      if (candidateData is Map<String, dynamic>) {
        final party = candidateData['party'];
        if (party == null || party == "_NOTA") return;
        final v = (candidateData['vote_count'] as num).toDouble();
        partyVotes[party] = (partyVotes[party] ?? 0) + v;
      }
    });

    // Always add a NOTA entry (if notaVotes is null, treat it as 0)
    partyVotes["NOTA"] = (notaVotes ?? 0);

    return partyVotes.entries
        .map((e) => ChartData(e.key, e.value))
        .toList();
  }

  /// Helper method to build a section header.
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Center(
        child: Text(title,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppConstants.appBarColor)),
      ),
    );
  }

  /// Helper method to build a chart card (one card per row).
  Widget _buildChartCard({
    required String title,
    required Widget child,
    Color headerColor = AppConstants.appBarColor,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Card(
        elevation: 4,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Center(
                child: Text(title,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: headerColor)),
              ),
              const SizedBox(height: 12),
              Container(
                height: 300,
                width: double.infinity,
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }


  /// Build graphs per constituency in an expandable card.
  /// Each constituency is represented by an ExpansionTile with a header and a list of chart cards.
  Widget _buildConstituencySection(Map<String, dynamic> metadata, Map<String, dynamic> votes) {
    List<Widget> constituencyWidgets = [];

    // Extract constituency names and sort them alphabetically
    List<String> sortedConstituencies = metadata.keys.toList()..sort();

    for (String constituencyName in sortedConstituencies) {
      final data = metadata[constituencyName];

      // metadata.forEach((constituencyName, data) {
      if (data is Map<String, dynamic>) {
        List<Widget> chartCards = [];
        // Get the votes for this constituency from the global votes map.
        final constituencyVotes = votes[constituencyName];
        // // Get notaVotes from local metadata (if exists)
        final notaVotes = data["notaVotes"] is num ? (data["notaVotes"] as num)
            .toDouble() : 0;

        // Add Party Performance Chart separately
        chartCards.add(
          _buildChartCard(
            title: "Party Performance",
            child: Builder(builder: (context) {
              // Filter global votes: select only candidate data for this constituency.
              Map<String, dynamic> filteredVotes = {};
              votes.forEach((_, candidateData) {
                if (candidateData is Map<String, dynamic> &&
                    candidateData["constituency"] == constituencyName) {
                  filteredVotes[_] = candidateData;
                }
              });

              // Get notaVotes from local metadata (if exists)
              final notaVotes = data["notaVotes"] is num
                  ? (data["notaVotes"] as num).toDouble()
                  : 0.0;

              // If no candidate votes for this constituency, show either a NOTA-only chart or a message.
              if (filteredVotes.isEmpty) {
                if (notaVotes > 0) {
                  return SfCircularChart(
                    legend: Legend(
                      isVisible: true,
                      overflowMode: LegendItemOverflowMode.wrap,
                      position: LegendPosition.bottom,
                    ),
                    series: <PieSeries<ChartData, String>>[
                      PieSeries<ChartData, String>(
                        dataSource: [ChartData("NOTA", notaVotes)],
                        xValueMapper: (ChartData d, _) => d.label,
                        yValueMapper: (ChartData d, _) => d.value,
                        dataLabelSettings: const DataLabelSettings(
                          isVisible: true,
                          textStyle: TextStyle(fontSize: 12),
                        ),
                      )
                    ],
                  );
                }
                return Center(
                  child: Text(
                    "No party performance data available.",
                    style: TextStyle(
                        fontSize: 16, color: AppConstants.appBarColor),
                  ),
                );
              }

              // Use FutureBuilder to aggregate votes for the filtered candidates.
              return FutureBuilder<List<ChartData>>(
                future: _getPartyVotes(filteredVotes, notaVotes: notaVotes),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor:
                        AlwaysStoppedAnimation<Color>(AppConstants.appBarColor),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error loading party performance data.",
                        style: TextStyle(
                            fontSize: 16, color: AppConstants.appBarColor),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        "No party performance data available.",
                        style: TextStyle(
                            fontSize: 16, color: AppConstants.appBarColor),
                      ),
                    );
                  }
                  return SfCircularChart(
                    legend: Legend(
                      isVisible: true,
                      overflowMode: LegendItemOverflowMode.wrap,
                      position: LegendPosition.bottom,
                    ),
                    series: <PieSeries<ChartData, String>>[
                      PieSeries<ChartData, String>(
                        dataSource: snapshot.data!,
                        xValueMapper: (ChartData d, _) => d.label,
                        yValueMapper: (ChartData d, _) => d.value,
                        dataLabelSettings: const DataLabelSettings(
                          isVisible: true,
                          textStyle: TextStyle(fontSize: 12),
                        ),
                      )
                    ],
                  );
                },
              );
            }),
          ),
        );

        // Define your categories and corresponding chart builders.
        final categories = [
          {
            "prefix": "ageGroup_",
            "title": "Age Distribution",
            "chart": (Map<String, dynamic> d) =>
                SfCircularChart(
                  legend: Legend(
                      isVisible: true, overflowMode: LegendItemOverflowMode.wrap, position: LegendPosition.bottom),
                  series: <PieSeries<ChartData, String>>[
                    PieSeries<ChartData, String>(
                      dataSource: _buildChartData(d, "ageGroup_"),
                      xValueMapper: (ChartData d, _) => d.label,
                      yValueMapper: (ChartData d, _) => d.value,
                      dataLabelSettings:
                      const DataLabelSettings(isVisible: true),
                    )
                  ],
                )
          },
          {
            "prefix": "gender_",
            "title": "Gender Ratio",
            "chart": (Map<String, dynamic> d) =>
                SfCircularChart(
                  legend: Legend(
                      isVisible: true, position: LegendPosition.bottom),
                  series: <DoughnutSeries<ChartData, String>>[
                    DoughnutSeries<ChartData, String>(
                      dataSource: _buildChartData(d, "gender_"),
                      xValueMapper: (ChartData d, _) => d.label,
                      yValueMapper: (ChartData d, _) => d.value,
                      innerRadius: '40%',
                      dataLabelSettings:
                      const DataLabelSettings(isVisible: true),
                    )
                  ],
                )
          },
          {
            "prefix": "educationStatus_",
            "title": "Education Levels",
            "chart": (Map<String, dynamic> d) =>
                SfCartesianChart(
                  primaryXAxis: CategoryAxis(labelRotation: -45),
                  primaryYAxis: NumericAxis(),
                  series: <BarSeries<ChartData, String>>[
                    BarSeries<ChartData, String>(
                        dataSource: _buildChartData(d, "educationStatus_"),
                        xValueMapper: (ChartData d, _) => d.label,
                        yValueMapper: (ChartData d, _) => d.value,
                        color: Colors.greenAccent,
                        dataLabelSettings:
                        const DataLabelSettings(isVisible: true))
                  ],
                )
          },
          {
            "prefix": "employmentStatus_",
            "title": "Employment Status",
            "chart": (Map<String, dynamic> d) =>
                SfCartesianChart(
                  primaryXAxis: CategoryAxis(labelRotation: -45),
                  primaryYAxis: NumericAxis(),
                  series: <BarSeries<ChartData, String>>[
                    BarSeries<ChartData, String>(
                        dataSource: _buildChartData(d, "employmentStatus_"),
                        xValueMapper: (ChartData d, _) => d.label,
                        yValueMapper: (ChartData d, _) => d.value,
                        color: Colors.orangeAccent,
                        dataLabelSettings:
                        const DataLabelSettings(isVisible: true))
                  ],
                )
          },
          {
            "prefix": "timeSlot_",
            "title": "Time Slot Trend",
            "chart": (Map<String, dynamic> d) =>
                SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  primaryYAxis: NumericAxis(),
                  series: <LineSeries<ChartData, String>>[
                    LineSeries<ChartData, String>(
                      dataSource: _buildChartData(d, "timeSlot_"),
                      xValueMapper: (ChartData d, _) => d.label,
                      yValueMapper: (ChartData d, _) => d.value,
                      color: Colors.redAccent,
                      markerSettings: const MarkerSettings(isVisible: true),
                      dataLabelSettings:
                      const DataLabelSettings(isVisible: true),
                    )
                  ],
                )
          },
          {
            "prefix": "voterCategory_",
            "title": "Voter Categories",
            "chart": (Map<String, dynamic> d) =>
                SfCircularChart(
                  legend: Legend(
                      isVisible: true, overflowMode: LegendItemOverflowMode.wrap, position: LegendPosition.bottom),
                  series: <RadialBarSeries<ChartData, String>>[
                    RadialBarSeries<ChartData, String>(
                      dataSource: _buildChartData(d, "voterCategory_"),
                      xValueMapper: (ChartData d, _) => d.label,
                      yValueMapper: (ChartData d, _) => d.value,
                      maximumValue: 40,
                      dataLabelSettings:
                      const DataLabelSettings(isVisible: true),
                    )
                  ],
                )
          },
          {
            "prefix": "disability_",
            "title": "Disability Statistics",
            "chart": (Map<String, dynamic> d) =>
                SfCartesianChart(
                  primaryXAxis: CategoryAxis(labelRotation: -45),
                  primaryYAxis: NumericAxis(),
                  series: <BarSeries<ChartData, String>>[
                    BarSeries<ChartData, String>(
                        dataSource: _buildChartData(d, "disability_"),
                        xValueMapper: (ChartData d, _) => d.label,
                        yValueMapper: (ChartData d, _) => d.value,
                        color: Colors.indigoAccent,
                        dataLabelSettings:
                        const DataLabelSettings(isVisible: true))
                  ],
                )
          },
          // Corrected "Constituency Votes" using a ColumnSeries.
          {
            "prefix": "constituencyTotalVotes",
            "title": "Constituency Votes",
            "chart": (Map<String, dynamic> d) =>
                SfCartesianChart(
                  primaryXAxis: CategoryAxis(labelRotation: -45),
                  primaryYAxis: NumericAxis(),
                  series: <ColumnSeries<ChartData, String>>[
                    ColumnSeries<ChartData, String>(
                      dataSource: _buildChartData(d, "constituencyTotalVotes"),
                      xValueMapper: (ChartData d, _) => d.label,
                      yValueMapper: (ChartData d, _) => d.value,
                      color: Colors.brown[300],
                      dataLabelSettings: const DataLabelSettings(
                          isVisible: true,
                          textStyle: TextStyle(fontSize: 12)),
                    )
                  ],
                )
          },
        ];

        // // Build a list of chart cards for each category.
        for (var cat in categories) {
          chartCards.add(_buildChartCard(
            title: cat["title"] as String,
            child:
            (cat["chart"] as Widget Function(Map<String, dynamic>))(data),
            headerColor: AppConstants.appBarColor,
          ));
        }
        // In your _buildConstituencySection method, when building the chartCards:
        // Wrap the charts in an ExpansionTile for expand/collapse functionality.
        constituencyWidgets.add(
          Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),  // 8 & 12
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ExpansionTile(
              title: Text(
                "Constituency: $constituencyName",
                style: TextStyle(
                    fontSize: 18,  // 20
                    fontWeight: FontWeight.bold,
                    color: AppConstants.appBarColor),
              ),
              children: chartCards,
            ),
          ),
        );
      }
      // });

    }
    return Column(children: constituencyWidgets);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchReportData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        AppConstants.appBarColor)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text("No report data available.",
                    style: TextStyle(fontSize: 18)));
          }

          final reportData = snapshot.data!;
          // Global metadata holds aggregated data for overall charts.
          final metadata = reportData['Metadata'] ?? {};
          final votes = reportData['votes'] ?? {};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      electionType,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$state, $year",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
                const SizedBox(height: 20),
                // New Section: Constituency Breakdown
                _buildSectionHeader("Detailed Breakdown"),
                // _buildConstituencySection(metadata),
                // Main card with gradient background
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),  // 12
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.teal.shade200, Colors.teal.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(0),  // 16
                    // All constituency cards are placed inside this main gradient card
                    child: _buildConstituencySection(metadata, votes),
                  ),
                ),

              ],
            ),
          );
        },
      ),
    );
  }
}

