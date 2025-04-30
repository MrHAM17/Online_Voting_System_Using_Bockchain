

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../SERVICE/utils/app_constants.dart';

class PartyApplicationForElection extends StatefulWidget {
  final String partyName;

  const PartyApplicationForElection({Key? key, required this.partyName}) : super(key: key);

  @override
  _PartyApplicationForElectionState createState() => _PartyApplicationForElectionState();
}

class _PartyApplicationForElectionState extends State<PartyApplicationForElection>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  String? selectedElectionType;
  String? selectedYear;
  String? selectedState;

  final TextEditingController _symbolController = TextEditingController();
  final TextEditingController _membersController = TextEditingController();
  late TextEditingController _partyNameController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _partyNameController = TextEditingController(text: widget.partyName); // Initialize the party name controller

  }

  @override
  void dispose() {
    _tabController?.dispose();
    _symbolController.dispose();
    _membersController.dispose();
    _partyNameController.dispose();

    super.dispose();
  }

  Future<void> _applyForElection() async {
    if (selectedElectionType == null || selectedYear == null || selectedState == null) {
      _showErrorMessage("Please select all required fields before applying.");
      return;
    }

    if (_symbolController.text.isEmpty || _membersController.text.isEmpty) {
      _showErrorMessage("Please provide party symbol and members' details.");
      return;
    }

    String  partyPath = "";

    if (selectedElectionType == "General (Lok Sabha)" || selectedElectionType == "Council of States (Rajya Sabha)")
    {  partyPath = "Vote Chain/Election/$selectedYear/$selectedElectionType/Party_Candidate/${widget.partyName}";      }
    else if
    ( selectedElectionType == "State Assembly (Vidhan Sabha)" || selectedElectionType == "Legislary Council (Vidhan Parishad)"  ||
      selectedElectionType == "Municipal" || selectedElectionType == "Panchayat" ||  selectedElectionType == "By-elections"
    )
    {  partyPath = "Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Party_Candidate/${widget.partyName}";      }


    final docRef = FirebaseFirestore.instance.doc(partyPath);
    final existingData = await docRef.get();

    if (existingData.exists)
    {
      _showErrorMessage("Your party has already applied for this election.");
      return;
    }

    await docRef.set({
      "partyName": widget.partyName,
      "symbol": _symbolController.text.trim(),
      "members": _membersController.text.trim(),
      "status": "Pending Verification",
      "timestamp": FieldValue.serverTimestamp(),
    });

    _showSuccessMessage("Application submitted successfully. ECI will verify your details.");
  }

  Future<void> _checkPartyStatus() async {
    if (selectedElectionType == null || selectedYear == null || selectedState == null) {
      _showErrorMessage("Please select all required fields to check the status.");
      return;
    }

    String  partyPath = "";

    if (selectedElectionType == "General (Lok Sabha)" || selectedElectionType == "Council of States (Rajya Sabha)")
    {  partyPath = "Vote Chain/Election/$selectedYear/$selectedElectionType/Party_Candidate/${widget.partyName}";      }
    else if
    ( selectedElectionType == "State Assembly (Vidhan Sabha)" || selectedElectionType == "Legislary Council (Vidhan Parishad)"  ||
        selectedElectionType == "Municipal" || selectedElectionType == "Panchayat" ||  selectedElectionType == "By-elections"
    )
    {  partyPath = "Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Party_Candidate/${widget.partyName}";      }

    final docRef = FirebaseFirestore.instance.doc(partyPath);
    final existingData = await docRef.get();

    if (existingData.exists) {
      final status = existingData.data()?['status'] ?? "No Status Found";
      _showSuccessMessage("Application Status: $status");
    } else {
      _showErrorMessage("No application found for your party in this election.");
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.red,
    ));
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.green,
    ));
  }

  Widget _buildDropdownField({
    required String label,
    required List<String> items,
    required String? selectedValue,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SingleChildScrollView(
            child: DropdownButtonFormField<String>(
              isExpanded: true,  // This will ensure the dropdown fills the available width
              value: selectedValue,
              items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
              onChanged: onChanged,
              decoration: InputDecoration(
                labelText: label,  // This will show the label inside the border
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
                floatingLabelBehavior: FloatingLabelBehavior.auto,  // This ensures the label floats
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateDropdownField({
    required String label,
    required String? selectedValue,
    required void Function(String?) onChanged,
  })
  {
    // Determine the list of states based on the selected election type
    List<String> items;
    if (selectedElectionType == "General (Lok Sabha)" || selectedElectionType == "Council of States (Rajya Sabha)")
    {  items = AppConstants.statesAndUT_PAN_India;  }
    else if (
    selectedElectionType == "State Assembly (Vidhan Sabha)" || selectedElectionType == "Legislary Council (Vidhan Parishad)"  ||
    selectedElectionType == "Municipal" || selectedElectionType == "Panchayat" ||  selectedElectionType == "By-elections" )
    {  items = AppConstants.statesAndUT;  }
    else {  items = [];   }

    return _buildDropdownField(
      label: label,
      items: items,
      selectedValue: selectedValue,
      onChanged: onChanged,
    );
  }

  Widget _buildStyledButton({
    required String text,
    required VoidCallback onPressed,
    required Color color,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
        ),
        icon: icon != null ? Icon(icon, color: Colors.white) : const SizedBox.shrink(),
        label: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Party & Election Management',
            style: TextStyle(
              fontSize: 20,                    // Font size for better visibility
              fontWeight: FontWeight.bold,     // Bold font for emphasis
              color: Colors.white,             // White color for better contrast
            ),
          ),
        ),
        backgroundColor: AppConstants.appBarColor,  // Use your custom color constant
        elevation: 4,                               // Add shadow for a modern look
        automaticallyImplyLeading: false,           // Disable the back button
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,             // White indicator for tabs
          indicatorWeight: 3,                       // Thicker indicator for better visibility
          labelStyle: const TextStyle(
            color: Colors.white,
            fontSize: 16,                           // Larger font size for tab text
            fontWeight: FontWeight.bold,            // Bold text for active tabs
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,                           // Slightly smaller font for inactive tabs
            fontWeight: FontWeight.normal,          // Normal weight for unselected tabs
          ),
          tabs: const [
            Tab(text: "Apply for Election"),        // Tab 1
            Tab(text: "Check Status"),              // Tab 2
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          // Apply for Election Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               _buildDropdownField(
                  label: "Year",
                  items: AppConstants.electionYear,
                  selectedValue: selectedYear,
                  onChanged: (value) => setState(() => selectedYear = value),
                ),
                _buildDropdownField(
                  label: "Election Type",
                  items: AppConstants.electionTypesForPartyHead,
                  selectedValue: selectedElectionType,
                  // onChanged: (value) => setState(() => selectedElectionType = value),
                  onChanged: (value) {
                    setState(() {
                      selectedElectionType = value;
                      selectedState = null; // Reset state on election type change
                    });
                  },
                ),
                _buildStateDropdownField(
                  label: "State",
                  // items: AppConstants.statesAndUT,
                  selectedValue: selectedState,
                  onChanged: (value) => setState(() => selectedState = value),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _partyNameController,
                  readOnly: true,  // Make it read-only since it's the default party name
                  decoration: const InputDecoration(
                    labelText: "Party Name",
                    border: OutlineInputBorder(),
                    labelStyle: const TextStyle(
                      // fontWeight: FontWeight.bold,  // Make the label bold
                      // color: Colors.grey,     // Change the label color to blue accent
                    ),
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,  // Make the party name bold
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _symbolController,
                  decoration: const InputDecoration(
                    labelText: "Party Symbol",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _membersController,
                  decoration: const InputDecoration(
                    labelText: "Party Members Info",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                Center(
                  child: _buildStyledButton(
                    text: "Apply for Election",
                    onPressed: _applyForElection,
                    // color: AppConstants.primaryColor,
                    color: Colors.blueAccent,
                    icon: Icons.send,
                  ),
                ),
              ],
            ),
          ),
          // Check Application Status Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDropdownField(
                  label: "Year",
                  items: AppConstants.electionYear,
                  selectedValue: selectedYear,
                  onChanged: (value) => setState(() => selectedYear = value),
                ),
                _buildDropdownField(
                  label: "Election Type",
                  items: AppConstants.electionTypesForPartyHead,
                  selectedValue: selectedElectionType,
                  // onChanged: (value) => setState(() => selectedElectionType = value),
                  onChanged: (value) {
                    setState(() {
                      selectedElectionType = value;
                      selectedState = null; // Reset state on election type change
                    });
                  },
                ),
                _buildStateDropdownField(
                  label: "State",
                  // items: AppConstants.statesAndUT,
                  selectedValue: selectedState,
                  onChanged: (value) => setState(() => selectedState = value),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _partyNameController,
                  readOnly: true,  // Make it read-only since it's the default party name
                  decoration: const InputDecoration(
                    labelText: "Party Name",
                    border: OutlineInputBorder(),
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,  // Make the label bold
                      color: Colors.grey,     // Change the label color to blue accent
                    ),
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,  // Make the party name bold
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: _buildStyledButton(
                    text: "Check Application Status",
                    onPressed: _checkPartyStatus,
                    color: Colors.blueAccent,
                    icon: Icons.check_circle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
