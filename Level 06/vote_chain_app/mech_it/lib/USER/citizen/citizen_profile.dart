
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../SERVICE/utils/app_constants.dart';
import '../../SERVICE/screen/styled_widget.dart'; // For LogoutButton, etc.

class Profile extends StatelessWidget {
  final String state;
  final String email;

  const Profile({Key? key, required this.state, required this.email})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.appBarColor,
        title: Center(
          child: Text(
            'Citizen Profile',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        // elevation: 4,
        automaticallyImplyLeading: false,
        actions: [
          LogoutButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/Login');
            },
          ),
        ],
      ),
      body: CitizenProfileBody(state: state, email: email),
    );
  }
}

class CitizenProfileBody extends StatelessWidget {
  final String state;
  final String email;

  const CitizenProfileBody({Key? key, required this.state, required this.email})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Vote Chain')
            .doc('State')
            .collection(state)
            .doc('Citizen')
            .collection('Citizen')
            .doc(email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text("Citizen profile not found",
                  style: TextStyle(fontSize: 18)),
            );
          }

          // Extract citizen data from Firestore.
          var citizenData = snapshot.data!.data() as Map<String, dynamic>;
          // Extract electionData map if available.
          Map<String, dynamic> electionData = citizenData['electionData'] is Map
              ? citizenData['electionData'] as Map<String, dynamic>
              : {};

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header: Left-aligned avatar with details on the right.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CircleAvatar on the left.
                    CircleAvatar(
                      radius: 56,
                      backgroundColor: AppConstants.appBarColor,
                      child: ClipOval(
                        child: citizenData['imageUrl'] != null &&
                            (citizenData['imageUrl'] as String).isNotEmpty
                            ? Image.network(
                          citizenData['imageUrl'],
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        )
                            : Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    // Name, Constituency and Bio.
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10), // Add space above the name
                          Text(
                            citizenData['name'] ?? 'N/A',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // SizedBox(height: 0),
                          Text(
                            '${citizenData['locSabhaConstituency'] ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'No bio is available',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 13),
                // Section: Personal Information
                _buildSectionTitle("Personal Information"),
                _buildExpandableCard(
                  title: "Basic Details",
                  children: [
                    _buildProfileItem('Name', citizenData['name'] ?? 'N/A'),
                    _buildProfileItem('Email', citizenData['email'] ?? 'N/A'),
                    _buildProfileItem('Phone', citizenData['phone'] ?? 'N/A'),
                    _buildProfileItem('Gender', citizenData['gender'] ?? 'N/A'),
                    _buildProfileItem(
                        'Birth Date', citizenData['birthDate'] ?? 'N/A'),
                  ],
                ),
                _buildExpandableCard(
                  title: "Additional Details",
                  children: [
                    _buildProfileItem(
                        'Disability', citizenData['disabilityStatus'] ?? 'N/A'),
                    _buildProfileItem(
                        'Education', citizenData['education'] ?? 'N/A'),
                    _buildProfileItem(
                        'Employment', citizenData['employmentStatus'] ?? 'N/A'),
                    _buildProfileItem(
                        'Residence', citizenData['residence'] ?? 'N/A'),
                    _buildProfileItem(
                        'State', citizenData['state'] ?? 'N/A'),
                  ],
                ),
                SizedBox(height: 10),
                // Section: Voting Information
                _buildSectionTitle("Voting Information"),
                _buildExpandableCard(
                  title: "Constituency Details",
                  children: [
                    _buildProfileItem('Loc Sabha Constituency',
                        citizenData['locSabhaConstituency'] ?? 'N/A'),
                    _buildProfileItem('Vidhan Sabha Constituency',
                        citizenData['vidhanSabhaConstituency'] ?? 'N/A'),
                    _buildProfileItem('Voter Category',
                        citizenData['voterCategory'] ?? 'N/A'),
                  ],
                ),
                _buildExpandableCard(
                  title: "Voting History",
                  children: [
                    // For "Total Votes", we remove the dropdown.
                    _buildVotingHistoryItem(
                      context: context,
                      label: 'Total Votes',
                      value: citizenData['totalVotes']?.toString() ?? 'N/A',
                      dates: _extractVotingDatesFromElectionData(electionData, 'Total'),
                      showDropdown: false,
                    ),
                    _buildVotingHistoryItem(
                      context: context,
                      label: 'Vidhan Sabha Votes',
                      value: citizenData['totalVidhanSabhaVotes']?.toString() ?? 'N/A',
                      dates: _extractVotingDatesFromElectionData(electionData, 'vidhanSabha'),
                    ),
                    _buildVotingHistoryItem(
                      context: context,
                      label: 'Municipal Votes',
                      value: citizenData['totalMunicipalVotes']?.toString() ?? 'N/A',
                      dates: _extractVotingDatesFromElectionData(electionData, 'municipal'),
                    ),
                    _buildVotingHistoryItem(
                      context: context,
                      label: 'Panchayat Votes',
                      value: citizenData['totalPanchayatVotes']?.toString() ?? 'N/A',
                      dates: _extractVotingDatesFromElectionData(electionData, 'Panchayat'),
                    ),
                    _buildVotingHistoryItem(
                      context: context,
                      label: 'Loc Sabha Votes',
                      value: citizenData['totalLocSabhaVotes']?.toString() ?? 'N/A',
                      dates: _extractVotingDatesFromElectionData(electionData, 'locSabha'),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                // Action Button: Edit Profile.
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: _buildActionButtons(context),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Extract voting dates from electionData for a given voteType.
  /// For each election type (e.g. "vidhanSabha", "municipal", "Panchayat", "locSabha", "Total"),
  /// this function returns a list of formatted strings, e.g. "25 February 2024, 13:08:55".
  List<String> _extractVotingDatesFromElectionData(Map<String, dynamic> electionData, String voteType) {
    if (electionData.containsKey(voteType)) {
      var typeData = electionData[voteType];
      if (typeData is Map) {
        return typeData.entries.map((entry) {
          if (entry.value is Map) {
            Map details = entry.value;
            String date = details['date'] ?? '';
            String month = details['month'] ?? '';
            String year = details['year'] ?? entry.key.toString();
            String time = details['time'] ?? ''; // Expecting format like "13:08:55"
            return '$date $month $year, $time';
          }
          return entry.key.toString();
        }).toList();
      }
    }
    return []; // return empty list if no dates found.
  }

  // Section Title Widget.
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppConstants.appBarColor,
        ),
      ),
    );
  }

  // Expandable Card Widget.
  Widget _buildExpandableCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          title,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
        ),
        children: children,
      ),
    );
  }

  // Profile Item Widget.
  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  /// Voting History Item Widget with a small triangular button that shows a popup
  /// list of voting dates (including date, month, year, and time) when tapped.
  /// The button icon is shown in grey if there are no dates, or in black if one or more exist.
  /// If [showDropdown] is false, the dropdown is not shown.
  Widget _buildVotingHistoryItem({
    required BuildContext context,
    required String label,
    required String value,
    required List<String> dates,
    bool showDropdown = true,
  }) {
    Color iconColor = dates.isNotEmpty ? Colors.black : Colors.grey;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                if (showDropdown) ...[
                  SizedBox(width: 4),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.arrow_drop_down, size: 20, color: iconColor),
                    itemBuilder: (context) {
                      return dates.map((date) {
                        return PopupMenuItem<String>(
                          value: date,
                          child: Text('Date: $date'),
                        );
                      }).toList();
                    },
                    onSelected: (value) {
                      // Read-only; no action.
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Action Button: Edit Profile.
  Widget _buildActionButtons(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, '/EditProfile', arguments: {
          'state': state,
          'email': email,
        });
      },
      style: ElevatedButton.styleFrom(
        primary: AppConstants.appBarColor,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      child: Text(
        'Edit Profile',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}
