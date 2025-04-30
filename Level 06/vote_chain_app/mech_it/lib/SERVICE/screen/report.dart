
import 'dart:convert';
// //import 'dart:html' as html;   // If uncommented then --> App will not install on mobile  --> otherwise works for web
import 'package:universal_html/html.dart' as html;    // Cross-platform web support
import 'package:mech_it/SERVICE/screen/styled_widget.dart';

import 'package:path_provider/path_provider.dart';        // For mobile storage
import 'package:share_plus/share_plus.dart';    // To share/download the file on mobile

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mech_it/SERVICE/screen/sub_report.dart';
import 'dart:io' show File, Platform;
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


/// ReportScreen fetches real data from Firestore (both from "Metadata" and "votes")
/// and then displays 11 different chart cards (each on its own row) plus a detailed data table.
class ReportScreen extends StatelessWidget {
  final String electionType;
  final String state;
  final String year;
  final String role;

  const ReportScreen({
    Key? key,
    required this.electionType,
    required this.state,
    required this.year,
    required this.role,
    // this.role = "PartyHead_specificElectionViewingReport",
  }) : super(key: key);


  /// ***************************************   *********************************    **********************   *********************    ***************  ****************    ****************  *** ***  ** **  *
  /// ***************************************   *********************************    **********************   *********************    ***************  ****************    ****************  *** ***  ** **  *
  ///                                                                           Report functions code below
  /// ***************************************   *********************************    **********************   *********************    ***************  ****************    ****************  *** ***  ** **  *
  /// ***************************************   *********************************    **********************   *********************    ***************  ****************    ****************  *** ***  ** **  *

  /// Fetch report data from Firestore using the provided filters.
  Future<Map<String, dynamic>> fetchReportData() async {
    final isGeneral = electionType.contains("General") || electionType.contains("Council");
    final path = isGeneral
        ? "Vote Chain/Election/$year/$electionType/State/$state/Result/Fetched_Result/"
        : "Vote Chain/State/$state/Election/$year/$electionType/Result/Fetched_Result/";
    print("Fetching report data from: $path");
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.doc(path).get();
    return snapshot.exists ? snapshot.data() as Map<String, dynamic> : {};
  }

  /// Aggregates data from all constituencies in Metadata for keys starting with the given prefix.
  Map<String, double> _aggregateData(Map<String, dynamic> metadata, String prefix) {
    final aggregated = <String, double>{};
    metadata.forEach((_, constituencyData) {
      if (constituencyData is Map<String, dynamic>) {
        constituencyData.forEach((key, value) {
          if (key.startsWith(prefix)) {
            // Clean the key by removing the prefix and replacing underscores with spaces.
            final cleanKey = key.replaceAll(prefix, '').replaceAll('_', ' ');
            aggregated[cleanKey] = (aggregated[cleanKey] ?? 0) + (value as num).toDouble();
          }
        });
      }
    });
    return aggregated;
  }

  /// Builds a list of ChartData for the given prefix.
  List<ChartData> _buildChartData(Map<String, dynamic> metadata, String prefix) {
    return _aggregateData(metadata, prefix)
        .entries
        .map((e) => ChartData(e.key, e.value))
        .toList();
  }

  /// Builds time series data from Metadata['timeTrend'].
  List<TimeSeriesData> _buildTimeSeriesChartData(Map<String, dynamic> metadata) {
    List<TimeSeriesData> data = [];
    if (metadata.containsKey('timeTrend') && metadata['timeTrend'] is List) {
      for (var item in metadata['timeTrend']) {
        if (item is Map<String, dynamic>) {
          final time = item['time']?.toString() ?? "";
          final votes = (item['votes'] as num?)?.toDouble() ?? 0;
          data.add(TimeSeriesData(time, votes));
        }
      }
    }
    return data;
  }

  /// Aggregates party votes directly from the votes map.
  Future<List<ChartData>> _getPartyVotes(Map<String, dynamic> votes) async {
    final partyVotes = <String, double>{};

    // Iterate through votes to sum up party votes
    votes.forEach((_, candidateData) {
      if (candidateData is Map<String, dynamic> && candidateData['party'] != null) {
        final party = candidateData['party'];
        final v = (candidateData['vote_count'] as num).toDouble();
        partyVotes[party] = (partyVotes[party] ?? 0) + v;
      }
    });

    // // Add NOTA votes if available
    if (votes.containsKey('_NOTA') && votes['_NOTA'] is Map<String, dynamic>) {
      final notaVotes = (votes['_NOTA']['vote_count'] as num).toDouble();
      partyVotes['NOTA'] = notaVotes;
    }

    return partyVotes.entries.map((e) => ChartData(e.key, e.value)).toList();
  }

  /// Builds a detailed data table from Metadata['dataTable'].
  Widget _buildDataTable(Map<String, dynamic> metadata) {
    if (metadata.containsKey('dataTable') && metadata['dataTable'] is Map<String, dynamic>) {
      final tableData = metadata['dataTable'] as Map<String, dynamic>;
      final rows = tableData.entries.map((entry) {
        return DataRow(cells: [
          DataCell(Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold))),
          DataCell(Text(entry.value.toString())),
        ]);
      }).toList();
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Metric', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text('Value', style: TextStyle(fontWeight: FontWeight.bold))),
          ],
          rows: rows,
        ),
      );
    }
    return const SizedBox();
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Center(
                child: Text(title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: headerColor)),
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

  /// Helper method to build a section header.
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 16),
      child: Center(
        child: Text(title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppConstants.appBarColor)),
      ),
    );
  }

  /// Build the Demographic section (e.g. Age and Gender).
  Widget _buildDemographicSection(Map<String, dynamic> metadata) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // _buildSectionHeader("Demographic Analysis"),
        _buildChartCard(
          title: "Age Distribution",
          headerColor: Colors.blue.shade700,
          child: SfCircularChart(
            legend: Legend(
              isVisible: true,
              position: LegendPosition.bottom,
              overflowMode: LegendItemOverflowMode.wrap,
              textStyle: const TextStyle(fontSize: 12),
            ),
            series: <PieSeries<ChartData, String>>[
              PieSeries<ChartData, String>(
                dataSource: _buildChartData(metadata, 'ageGroup_'),
                xValueMapper: (ChartData d, _) => d.label,
                yValueMapper: (ChartData d, _) => d.value,
                dataLabelSettings: const DataLabelSettings(isVisible: true, textStyle: TextStyle(fontSize: 12)),
              )
            ],
          ),
        ),
        _buildChartCard(
          title: "Gender Ratio",
          headerColor: Colors.purple.shade700,
          child: SfCircularChart(
            legend: Legend(isVisible: true, position: LegendPosition.bottom),
            series: <DoughnutSeries<ChartData, String>>[
              DoughnutSeries<ChartData, String>(
                dataSource: _buildChartData(metadata, 'gender_'),
                xValueMapper: (ChartData d, _) => d.label,
                yValueMapper: (ChartData d, _) => d.value,
                innerRadius: '40%',
                dataLabelSettings: const DataLabelSettings(isVisible: true, textStyle: TextStyle(fontSize: 12)),
              )
            ],
          ),
        ),
      ],
    );
  }

  /// Build the Education & Employment section.
  Widget _buildEducationEmploymentSection(Map<String, dynamic> metadata) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // _buildSectionHeader("Education & Employment"),
        _buildChartCard(
          title: "Education Levels",
          headerColor: Colors.green.shade700,
          child: SfCartesianChart(
              primaryXAxis: CategoryAxis(labelRotation: -45),
              primaryYAxis: NumericAxis(),
              series: <BarSeries<ChartData, String>>[
              BarSeries<ChartData, String>(
              dataSource: _buildChartData(metadata, 'educationStatus_'),
              xValueMapper: (d, _) => d.label,
              yValueMapper: (d, _) => d.value,
              color: Colors.greenAccent,
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                textStyle: TextStyle(fontSize: 12),
              )
              )]
          ),
        ),
        const SizedBox(height: 16), // Added spacing
        _buildChartCard(
          title: "Employment Status",
          headerColor: Colors.orange.shade700,
          child: SfCartesianChart(
              primaryXAxis: CategoryAxis(labelRotation: -45),
              primaryYAxis: NumericAxis(),
              series: <BarSeries<ChartData, String>>[
              BarSeries<ChartData, String>(
              dataSource: _buildChartData(metadata, 'employmentStatus_'),
              xValueMapper: (d, _) => d.label,
              yValueMapper: (d, _) => d.value,
              color: Colors.orangeAccent,
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                textStyle: TextStyle(fontSize: 12),
              )
              )]
          ),
        ),
      ],
    );
  }

  /// Build the Voting Patterns section.
  Widget _buildVotingPatternsSection(Map<String, dynamic> metadata) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // _buildSectionHeader("Voting Patterns"),
        _buildChartCard(
          title: "Time Slot Trend",
          headerColor: Colors.red.shade700,
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            primaryYAxis: NumericAxis(),
            series: <LineSeries<ChartData, String>>[
              LineSeries<ChartData, String>(
                dataSource: _buildChartData(metadata, 'timeSlot_'),
                xValueMapper: (d, _) => d.label,
                yValueMapper: (d, _) => d.value,
                color: Colors.redAccent,
                markerSettings: const MarkerSettings(isVisible: true),
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(fontSize: 12),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildChartCard(
          title: "Voter Categories",
          headerColor: Colors.teal.shade700,
          child: SfCircularChart(
            legend: Legend(
              isVisible: true,
              position: LegendPosition.bottom,
              overflowMode: LegendItemOverflowMode.wrap,
            ),
            series: <RadialBarSeries<ChartData, String>>[
              RadialBarSeries<ChartData, String>(
                dataSource: _buildChartData(metadata, 'voterCategory_'),
                xValueMapper: (d, _) => d.label,
                yValueMapper: (d, _) => d.value,
                maximumValue: 40,
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(fontSize: 12),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  /// Build the Accessibility & Residence section.
  Widget _buildAccessibilityResidenceSection(Map<String, dynamic> metadata) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // _buildSectionHeader("Accessibility & Residence"),
        _buildChartCard(
          title: "Disability Statistics",
          headerColor: Colors.indigo.shade700,
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(labelRotation: -45),
            primaryYAxis: NumericAxis(),
            series: <BarSeries<ChartData, String>>[
              BarSeries<ChartData, String>(
                dataSource: _buildChartData(metadata, 'disability_'),
                xValueMapper: (d, _) => d.label,
                yValueMapper: (d, _) => d.value,
                color: Colors.indigoAccent,
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(fontSize: 12),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildChartCard(
          title: "Residence Types",
          headerColor: Colors.pink.shade700,
          child: SfCircularChart(
            legend: Legend(
              isVisible: true,
              position: LegendPosition.bottom,
              overflowMode: LegendItemOverflowMode.wrap,
            ),
            series: <DoughnutSeries<ChartData, String>>[
              DoughnutSeries<ChartData, String>(
                dataSource: _buildChartData(metadata, 'residence_'),
                xValueMapper: (d, _) => d.label,
                yValueMapper: (d, _) => d.value,
                innerRadius: '30%',
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(fontSize: 12),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  /// Build the Results Analysis section.
  Widget _buildResultsAnalysisSection(Map<String, dynamic> metadata, Map<String, dynamic> votes, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // _buildSectionHeader("Results Analysis"),
        _buildChartCard(
          title: "Constituency Votes",
          headerColor: Colors.brown.shade700,
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(labelRotation: -45),
            primaryYAxis: NumericAxis(),
            series: <ColumnSeries<ChartData, String>>[
              ColumnSeries<ChartData, String>(
                dataSource: _buildChartData(metadata, 'constituencyTotalVotes'),
                xValueMapper: (d, _) => d.label,
                yValueMapper: (d, _) => d.value,
                color: Colors.brown[300],
                dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  textStyle: TextStyle(fontSize: 12),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildChartCard(
          title: "Party Performance",
          headerColor: Colors.cyan.shade700,
          child: FutureBuilder<List<ChartData>>(
            future: _getPartyVotes(votes),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SfCircularChart(
                  legend: Legend(
                    isVisible: true,
                    overflowMode: LegendItemOverflowMode.wrap,
                    position: LegendPosition.bottom,
                  ),
                  series: <PieSeries<ChartData, String>>[
                    PieSeries<ChartData, String>(
                      dataSource: snapshot.data!,
                      xValueMapper: (d, _) => d.label,
                      yValueMapper: (d, _) => d.value,
                      dataLabelSettings: const DataLabelSettings(
                        isVisible: true,
                        textStyle: TextStyle(fontSize: 12),
                      ),
                    )
                  ],
                );
              }
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppConstants.appBarColor),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // _buildChartCard(
        //   title: "Detailed Metrics",
        //   headerColor: Colors.blueGrey,
        //   child: ConstrainedBox(
        //     constraints: BoxConstraints(maxHeight: 400),
        //     child: _buildDataTable(metadata),
        //   ),
        // ),
        _buildChartCard(
          title: "Detailed Metrics",
          headerColor: Colors.blueGrey,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 400), // 400
            child: Column(
              children: [
                // // Search Bar
                // Padding(
                //   padding: EdgeInsets.all(8),
                //   child: TextField(
                //     decoration: InputDecoration(
                //       hintText: "Search metrics...",
                //       prefixIcon: Icon(Icons.search),
                //       border: OutlineInputBorder(
                //         borderRadius: BorderRadius.circular(8),
                //       ),
                //     ),
                //     onChanged: (query) {
                //       // Implement search/filter logic
                //     },
                //   ),
                // ),
                // // Table with horizontal scrolling
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: _buildDataTable(metadata),
                  ),
                ),
                // Footer with summary and actions
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withOpacity(0.1),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // 👈 Text aligned to the left using Expanded
                      Expanded(
                        child: Text(
                          "Main Metric: ${metadata.length}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.download, size: 20),
                        onPressed: () {
                          // print("1. Data Table: ${metadata}");
                          /// basic approach
                          // //_downloadMainMetrics(metadata, context);
                          /// improved approach  below one
                          _exportMainMetrics(metadata: metadata, context: context, isDownload: true,);    // ✅ Download
                        },
                      ),
                      const SizedBox(width: 1),
                      IconButton(
                        icon: Icon(Icons.share, size: 20),
                        onPressed: () {
                          // print("2. Data Table: ${votes}");
                          _exportMainMetrics(metadata: metadata, context: context, isDownload: false,);      // ✅ Share
                        },
                      ),
                    ],

                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withOpacity(0.1),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // 👈 Text aligned to the left using Expanded
                      Expanded(
                        child: Text(
                          "Detailed Metric: ${metadata.length}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.download, size: 20),
                        onPressed: () {
                          // print("1. Data Table: ${metadata}");
                          _exportDetailedMetrics(metadata: metadata, context: context, isDownload: true,);    // ✅ Download
                        },
                      ),
                      const SizedBox(width: 1),
                      IconButton(
                        icon: Icon(Icons.share, size: 20),
                        onPressed: () {
                          // print("2. Data Table: ${votes}");
                          _exportDetailedMetrics(metadata: metadata, context: context, isDownload: false,);    // ✅ Download

                        },
                      ),
                    ],

                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withOpacity(0.1),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // 👈 Text aligned to the left using Expanded
                      Expanded(
                        child: Text(
                          "Constituency Metric: ${metadata.length}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.download, size: 20),
                        onPressed: () {
                          // print("3. Data Table: ${votes}");
                          _exportConstituencyMetrics(metadata: metadata, votes: votes, context: context, isDownload: true,);    // ✅ Download

                        },
                      ),
                      const SizedBox(width: 1),
                      IconButton(
                        icon: Icon(Icons.share, size: 20),
                        onPressed: () {
                          // print("2. Data Table: ${votes}");
                          _exportConstituencyMetrics(metadata: metadata, votes: votes, context: context, isDownload: false,);    // ✅ Download

                        },
                      ),
                    ],

                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withOpacity(0.1),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // 👈 Text aligned to the left using Expanded
                      Expanded(
                        child: Text(
                          "Party Metric: ${metadata.length}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.download, size: 20),
                        onPressed: () {
                          // print("2. Data Table: ${votes}");
                          // Add export functionality
                          // _downloadPartyMetrics(votes, context);
                          _exportPartyMetrics(votes: votes, context: context, isDownload: true,);    // ✅ Download
                        },
                      ),
                      const SizedBox(width: 1),
                      IconButton(
                        icon: Icon(Icons.share, size: 20),
                        onPressed: () {
                          // print("2. Data Table: ${votes}");
                          _exportPartyMetrics(votes: votes, context: context, isDownload: false,);    // ✅ Download

                        },
                      ),
                    ],

                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }





  /// ***************************************   *********************************    **********************   *********************    ***************  ****************    ****************  *** ***  ** **  *
  /// ***************************************   *********************************    **********************   *********************    ***************  ****************    ****************  *** ***  ** **  *
  ///                                                                           Sub-Report functions code below
  /// ***************************************   *********************************    **********************   *********************    ***************  ****************    ****************  *** ***  ** **  *
  /// ***************************************   *********************************    **********************   *********************    ***************  ****************    ****************  *** ***  ** **  *

  /// Aggregates party votes directly from the votes map.
  Future<List<ChartData>> _getPartyVotes_subReport(
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

  /// Builds a list of ChartData for the given prefix from a provided data map.
  List<ChartData> _buildChartData_subReport(Map<String, dynamic> data, String prefix) {
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
                future: _getPartyVotes_subReport(filteredVotes, notaVotes: notaVotes),
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
                      overflowMode:
                      LegendItemOverflowMode.wrap,
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
                      isVisible: true,overflowMode: LegendItemOverflowMode.wrap, position: LegendPosition.bottom),
                  series: <PieSeries<ChartData, String>>[
                    PieSeries<ChartData, String>(
                      dataSource: _buildChartData_subReport(d, "ageGroup_"),
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
                      dataSource: _buildChartData_subReport(d, "gender_"),
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
                        dataSource: _buildChartData_subReport(d, "educationStatus_"),
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
                        dataSource: _buildChartData_subReport(d, "employmentStatus_"),
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
                      dataSource: _buildChartData_subReport(d, "timeSlot_"),
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
                      isVisible: true,overflowMode: LegendItemOverflowMode.wrap, position: LegendPosition.bottom),
                  series: <RadialBarSeries<ChartData, String>>[
                    RadialBarSeries<ChartData, String>(
                      dataSource: _buildChartData_subReport(d, "voterCategory_"),
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
                        dataSource: _buildChartData_subReport(d, "disability_"),
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
                      dataSource: _buildChartData_subReport(d, "constituencyTotalVotes"),
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
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 6), // 8 & 12
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ExpansionTile(
              title: Text(
                "Constituency: $constituencyName",
                style: TextStyle(
                    fontSize: 18,  //  20
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





  /// ***************************************   *********************************    **********************   *********************    ***************  ****************    ****************  *** ***  ** **  *
  /// ***************************************   *********************************    **********************   *********************    ***************  ****************    ****************  *** ***  ** **  *
  ///                                                                           Main widget-context code below
  /// ***************************************   *********************************    **********************   *********************    ***************  ****************    ****************  *** ***  ** **  *
  /// ***************************************   *********************************    **********************   *********************    ***************  ****************    ****************  *** ***  ** **  *
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchReportData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppConstants.appBarColor)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No report data available.", style: TextStyle(fontSize: 18)));
          }

          final reportData = snapshot.data!;
          final metadata = reportData['Metadata'] ?? {};
          final votes = reportData['votes'] ?? {};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Report Title
                ///
                // Text("Detailed Report:\n$electionType\n$state\n$year",
                //     textAlign: TextAlign.center,
                //     style: Theme.of(context).textTheme.headlineSmall),
                ///
                // Padding(
                //   padding: const EdgeInsets.symmetric(vertical: 16),
                //   child: RichText(
                //     textAlign: TextAlign.center,
                //     text: TextSpan(
                //       children: [
                //         TextSpan(
                //           text: "Detailed Report:\n",
                //           style: TextStyle(
                //             fontSize: 24,
                //             fontWeight: FontWeight.bold,
                //             color: Colors.black87,
                //           ),
                //         ),
                //         TextSpan(
                //           text: "$electionType\n",
                //           style: TextStyle(
                //             fontSize: 20,
                //             fontStyle: FontStyle.italic,
                //             color: Colors.blueAccent,
                //           ),
                //         ),
                //         TextSpan(
                //           text: "$state\n",
                //           style: TextStyle(
                //             fontSize: 20,
                //             fontWeight: FontWeight.w500,
                //             color: Colors.deepPurple,
                //           ),
                //         ),
                //         TextSpan(
                //           text: "$year",
                //           style: TextStyle(
                //             fontSize: 20,
                //             fontWeight: FontWeight.w500,
                //             color: Colors.green,
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                ///
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Text(
                    //   "Detailed Report",
                    //   textAlign: TextAlign.center,
                    //   style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    //     fontWeight: FontWeight.bold,
                    //     color: AppConstants.appBarColor,
                    //   ),
                    // ),
                    const SizedBox(height: 8), // Spacing between title and subtitle
                    Text(
                      electionType,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4), // Smaller spacing for tighter grouping
                    Text(
                      "$state, $year",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 20), // Spacing after the title section
                  ],
                ),
                const SizedBox(height: 20),
                // Build Sections (each section has one card per row)
                _buildSectionHeader("Demographic Analysis"),
                _buildDemographicSection(metadata),
                _buildSectionHeader("Education & Employment"),
                _buildEducationEmploymentSection(metadata),
                _buildSectionHeader("Voting Patterns"),
                _buildVotingPatternsSection(metadata),
                _buildSectionHeader("Accessibility & Residence"),
                _buildAccessibilityResidenceSection(metadata),
                _buildSectionHeader("Results Analysis"),
                _buildResultsAnalysisSection(metadata, votes, context),

                if
                (role == "Candidate_electionViewReport" || role == "PartyHead_electionViewReport" || role == "Admin_specificElectionViewingReport")...
                [
                  const SizedBox(height: 20),
                  // New Section: Constituency Breakdown
                  _buildSectionHeader("Detailed Breakdown"),
                  // _buildConstituencySection(metadata),
                  // Main card with gradient background
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0), // 12
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.teal.shade200, Colors.teal.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(0), // 16
                      // All constituency cards are placed inside this main gradient card
                      child: _buildConstituencySection(metadata, votes),
                    ),
                  ),
                ],

              ],
            ),
          );
        },
      ),
    );
  }
}


/// Function to export & share  detailed metrics as CSV.   ------------------------->>>>>>>>>>>   true → download, false → share
// void _downloadMainMetrics(Map<String, dynamic> metadata, BuildContext context) {
//   final csvBuffer = StringBuffer();
//   csvBuffer.writeln("Metric,Value"); // CSV header
//   metadata.forEach((key, value) {
//     csvBuffer.writeln('"$key","$value"');
//   });
//
//   final csvContent = csvBuffer.toString();
//   final filename = 'Total_Metric_${DateTime.now().toIso8601String()}.csv';
//   downloadFile(filename, csvContent, context);
// }
void _exportMainMetrics ({ required Map<String, dynamic> metadata, required BuildContext context, required bool isDownload,  }) {
  final csvBuffer = StringBuffer();
  csvBuffer.writeln("Metric,Value");  // CSV header
  metadata.forEach((key, value) {
    csvBuffer.writeln('"$key","$value"');
  });

  final csvContent = csvBuffer.toString();
  final filename = 'Total_Metric_${DateTime.now().toIso8601String()}.csv';

  if (isDownload) { downloadFile(filename, csvContent, context); }  // ✅ Download
  else { shareFile(filename, csvContent, context);  }               // ✅ Share
}
void _exportDetailedMetrics({ required Map<String, dynamic> metadata, required BuildContext context, required bool isDownload,  }) {
  final csvBuffer = StringBuffer();
  final allHeaders = <String>{};
  final constituencyData = <String, Map<String, dynamic>>{};

  // 1. Process metadata and collect all possible headers
  metadata.forEach((constituencyName, metrics) {
    if (metrics is! Map<String, dynamic>) return;

    final cleanMetrics = <String, dynamic>{};

    // Normalize metric names and values
    metrics.forEach((key, value) {
      final cleanKey = key.replaceAll('_', ' ').replaceAllMapped(
          RegExp(r'([A-Z])'),
              (match) => ' ${match.group(1)}'
      ).trim();

      cleanMetrics[cleanKey] = value is num ? value.toInt() : value;
    });

    // Add calculated fields
    cleanMetrics['Total Metrics Count'] = metrics.length;

    // Store and collect headers
    constituencyData[constituencyName] = cleanMetrics;
    allHeaders.addAll(cleanMetrics.keys);
  });

  // 2. Generate CSV structure
  final sortedHeaders = [
    'Constituency',
    ...allHeaders.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()))
  ];

  // CSV Header
  csvBuffer.writeln(sortedHeaders.map((h) => '"${h.toUpperCase()}"').join(','));

  // CSV Rows
  constituencyData.forEach((name, data) {
    final row = ['"$name"'];
    for (final header in sortedHeaders.skip(1)) {
      final value = data[header] ?? 0;
      row.add('"$value"');
    }
    csvBuffer.writeln(row.join(','));
  });

  // 3. Create final file
  final csvContent = csvBuffer.toString();
  final filename = 'Detailed_Metric_${DateTime.now().toIso8601String()}.csv';

  if (isDownload) { downloadFile(filename, csvContent, context);  } // ✅ Download
  else { shareFile(filename, csvContent, context);  }               // ✅ Share
}
void _exportConstituencyMetrics({ required Map<String, dynamic> metadata, required Map<String, dynamic> votes, required BuildContext context, required bool isDownload,  }) {
  final csvBuffer = StringBuffer();
  final allHeaders = <String>{};
  final constituencyData = <String, Map<String, dynamic>>{};

  // 1. Process Metadata and Votes Data
  metadata.forEach((constituencyName, meta) {
    if (meta is! Map<String, dynamic>) return;

    // Initialize with metadata values
    final rowData = Map<String, dynamic>.from(meta);

    // 2. Add Party Votes
    final partyVotes = <String, int>{};
    votes.forEach((email, candidate) {
      if (candidate is Map<String, dynamic> &&
          candidate['constituency'] == constituencyName &&
          candidate['party'] != null) {
        final party = candidate['party'] as String;
        final votes = (candidate['vote_count'] as num?)?.toInt() ?? 0;
        partyVotes[party] = (partyVotes[party] ?? 0) + votes;
      }
    });

    // Add party columns
    partyVotes.forEach((party, count) {
      rowData['Party: $party'] = count;
    });

    // 3. Add NOTA Votes (from metadata)
    rowData['NOTA Votes'] = (meta['notaVotes'] as num?)?.toInt() ?? 0;

    // 4. Add calculated total votes (sum of all votes)
    final totalVotes = partyVotes.values.fold(0, (sum, votes) => sum + votes) + rowData['NOTA Votes'];
    rowData['Calculated Total Votes'] = totalVotes;

    // Store and collect headers
    constituencyData[constituencyName] = rowData;
    allHeaders.addAll(rowData.keys);
  });

  // 5. Generate CSV Structure
  final sortedHeaders = ['Constituency', ...allHeaders.toList()..sort()];

  // CSV Header
  csvBuffer.writeln(sortedHeaders.map((h) => '"$h"').join(','));

  // CSV Rows
  constituencyData.forEach((name, data) {
    final row = [name];
    for (final header in sortedHeaders.skip(1)) {
      row.add(data[header]?.toString() ?? '0');
    }
    csvBuffer.writeln(row.map((v) => '"$v"').join(','));
  });

  // 6. Create final CSV
  final csvContent = csvBuffer.toString();
  final filename = 'Constituency_Metric_${DateTime.now().toIso8601String()}.csv';

  if (isDownload) { downloadFile(filename, csvContent, context); }  // ✅ Download
  else { shareFile(filename, csvContent, context);  }               // ✅ Share
}
void _exportPartyMetrics({ required Map<String, dynamic> votes, required BuildContext context, required bool isDownload,  }) {
  final csvBuffer = StringBuffer();
  final allFields = <String>{};
  final partyData = <String, List<Map<String, dynamic>>>{};
  final partyStats = <String, Map<String, dynamic>>{};
  int notaVotes = 0;

  // 1. Collect all possible fields and organize data
  votes.forEach((key, value) {
    if (key == '_NOTA') {
      notaVotes = (value['vote_count'] as num).toInt();
      return;
    }

    if (value is! Map<String, dynamic>) return;

    final candidate = Map<String, dynamic>.from(value);
    final party = candidate['party'] ?? 'Independent';

    // Clean and normalize data
    // candidate['age'] = int.tryParse(candidate['age']?.toString() ?? 0;
    candidate['age'] = int.tryParse(candidate['age']?.toString() ?? '0');

    candidate.remove('party');  // Will handle separately

    // Collect all field names
    allFields.addAll(candidate.keys);

    // Organize by party
    partyData.putIfAbsent(party, () => []).add(candidate);
  });

  // 2. Calculate party statistics
  partyData.forEach((party, candidates) {
    final stats = <String, dynamic>{
      'Total Votes': 0,
      'Average Age': 0.0,
      'Gender Distribution': <String, int>{},
      'Top Constituency': '',
      'Common Profession': '',
      'Education Levels': <String, int>{},
      'Candidate Count': candidates.length,
    };

    int ageSum = 0;
    final constituencyCounts = <String, int>{};
    final professionCounts = <String, int>{};

    for (final candidate in candidates) {
      final votes = (candidate['vote_count'] as num).toInt();
      stats['Total Votes'] += votes;

      ageSum += candidate['age'] as int;

      // Gender analysis
      final gender = candidate['gender']?.toString() ?? 'Unknown';
      stats['Gender Distribution'][gender] =
          (stats['Gender Distribution'][gender] ?? 0) + 1;

      // Constituency analysis
      final constituency = candidate['constituency']?.toString() ?? '';
      constituencyCounts[constituency] =
          (constituencyCounts[constituency] ?? 0) + 1;

      // Profession analysis
      final profession = candidate['profession']?.toString() ?? '';
      professionCounts[profession] =
          (professionCounts[profession] ?? 0) + 1;

      // Education analysis
      final education = candidate['education']?.toString() ?? '';
      stats['Education Levels'][education] =
          (stats['Education Levels'][education] ?? 0) + 1;
    }

    stats['Average Age'] = ageSum / candidates.length;
    stats['Top Constituency'] = _findMostCommon(constituencyCounts);
    stats['Common Profession'] = _findMostCommon(professionCounts);

    partyStats[party] = stats;
  });

  // 3. Generate CSV Structure
  final headers = [
    'Party',
    'Total Votes',
    'Candidate Count',
    'Average Age',
    'Top Constituency',
    'Common Profession',
    ...allFields.toList()..sort(),
    'Gender Distribution',
    'Education Levels'
  ];

  // CSV Header
  csvBuffer.writeln(headers.map((h) => '"${_formatHeader(h)}"').join(','));

  // 4. Add party data
  partyData.forEach((party, candidates) {
    final stats = partyStats[party]!;

    // Main party row
    final row = [
      party,
      stats['Total Votes'],
      stats['Candidate Count'],
      stats['Average Age'].toStringAsFixed(1),
      stats['Top Constituency'],
      stats['Common Profession'],
    ];

    // Add all candidate fields (aggregated)
    for (final field in headers.skip(6).take(allFields.length)) {
      final values = candidates.map((c) => c[field]?.toString() ?? 'N/A').join('; ');
      row.add(values);
    }

    // Add distributions
    row.add(_formatMap(stats['Gender Distribution']));
    row.add(_formatMap(stats['Education Levels']));

    csvBuffer.writeln(row.map((v) => '"$v"').join(','));

    // Add NOTA entry if applicable
    if (party == 'NOTA') {
      csvBuffer.writeln('"NOTA","$notaVotes",1,0.0,"N/A","N/A",${List.filled(headers.length - 6, 'N/A').join(',')},"",""');
    }
  });

  // 5. Create final file
  final csvContent = csvBuffer.toString();
  final filename = 'Party_Metric_${DateTime.now().toIso8601String()}.csv';

  if (isDownload) { downloadFile(filename, csvContent, context); }  // ✅ Download
  else { shareFile(filename, csvContent, context);  }               // ✅ Share
}


/// Helper functions
Future<void> downloadFile(String filename, String csvContent, BuildContext context) async {
  if (kIsWeb)
  {
    // ✅ For Web: Download CSV with Try-Catch
    try
    {
      // Encode CSV content and create a Blob
      final bytes = utf8.encode(csvContent);
      final blob = html.Blob([bytes], 'text/csv');
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Create an anchor element for download
      final anchor = html.AnchorElement(href: url)
        ..style.display = 'none'
        ..download = filename;

      // Append and trigger download
      html.document.body!.append(anchor);
      anchor.click();

      // Clean up
      anchor.remove();
      html.Url.revokeObjectUrl(url);

      print("File downloaded for Web: $filename");

    }
    catch (error)
    {
      SnackbarUtils.showErrorMessage(context, "Download failed:\n$error");
      print("Download failed on Web: $error");
    }

  }
  else
  {
    // ✅ For Mobile: Save and Download CSV with Try-Catch
    try
    {
      // 1. Get the directory and path
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final file = File('$path/$filename');

      // 2. Write the CSV content into the file
      await file.writeAsString(csvContent);

      print("File downloaded on Mobile: $filename\nPath: $file");

      // Optionally, display a snackbar with download path
      SnackbarUtils.showSuccessMessage(context, "File saved: $file");

    }
    catch (error)
    {
      SnackbarUtils.showErrorMessage(context, "Download failed:\n$error");
      print("Download failed on Mobile: $error");
    }
  }
}
Future<void> shareFile(String filename, String csvContent, BuildContext context) async {
  if (kIsWeb)
  {
    // // For web, use dart:html.  // ✅ For Web: Create a CSV file and initiate download
    // // Make sure to import: import 'dart:html' as html;
    try {
      // Encode CSV content and create a Blob
      final bytes = utf8.encode(csvContent);
      final blob = html.Blob([bytes], 'text/csv');
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Use Web Share API
      await html.window.navigator.share({
        'title': 'CSV File',
        'text': 'Sharing CSV File: $filename',
        'url': url,
      });

      // Clean up the URL after sharing
      html.Url.revokeObjectUrl(url);
      print("File shared on Web: $filename");

    } catch (error) {
      SnackbarUtils.showErrorMessage(context,"Sharing failed:\n$error");
      print("Sharing failed: $error");
    }
  }
  else
  {
    // // For mobile, get the directory and write the file.      // ✅ For Mobile: Save and share the file
    try {
      // 1. Get the directory and path
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      final file = File('$path/$filename');

      // 2. Write the CSV content into the file
      await file.writeAsString(csvContent);

      // 3. Share the file
      await Share.shareFiles([file.path], text: 'Share file: $filename');
      print("File shared on Mobile: $filename");

    } catch (error) {
      SnackbarUtils.showErrorMessage(context, "Sharing failed:\n$error");
      print("Sharing failed on Mobile: $error");
    }
  }
}

String _formatHeader(String header) {
  return header
      .replaceAll('_', ' ')
      .replaceAllMapped(RegExp(r'(?<=[a-z])([A-Z])'), (m) => ' ${m.group(1)}')
      .toUpperCase();
}
String _formatMap(Map<String, dynamic> map) { return map.entries.map((e) => '${e.key}:${e.value}').join(' | '); }
String _findMostCommon(Map<String, int> counts) {
  String mostCommon = '';
  int maxCount = 0;

  for (var entry in counts.entries) {
    if (entry.value > maxCount) {
      mostCommon = entry.key;
      maxCount = entry.value;
    }
  }
  return mostCommon;
}

