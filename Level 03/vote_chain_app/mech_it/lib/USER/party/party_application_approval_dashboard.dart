

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../SERVICE/screen/styled_widget.dart';
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

  Future<void> _applyForElection() async
  {
    if (selectedElectionType == null || selectedYear == null || selectedState == null)
    { SnackbarUtils.showErrorMessage(context, "Please select all required fields before applying.");  return; }

    if (_symbolController.text.isEmpty || _membersController.text.isEmpty)
    { SnackbarUtils.showErrorMessage(context,"Please provide party symbol and members' details."); return; }

    String  partyPath = "";

    if (selectedElectionType == "General (Lok Sabha)" || selectedElectionType == "Council of States (Rajya Sabha)")
    {  partyPath = "Vote Chain/Election/$selectedYear/$selectedElectionType/State/$selectedState/Party_Candidate/${widget.partyName}";      }
    else if
    (
      selectedElectionType == "State Assembly (Vidhan Sabha)" || selectedElectionType == "Legislary Council (Vidhan Parishad)"  ||
      selectedElectionType == "Municipal" || selectedElectionType == "Panchayat"
    )
    {  partyPath = "Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Party_Candidate/${widget.partyName}";      }
    else if
    (selectedElectionType == "By-elections" || selectedElectionType == "Referendum" || selectedElectionType == "Confidence Motion (Floor Test)" || selectedElectionType == "No Confidence Motion")
    {
      SnackbarUtils.showSuccessMessage(context,"Application logic isn't ready for $selectedElectionType.\n Select other Election type.");
      return;

      // // Allow only if the Winning Party field is equal to the party name
      // // get winning party status from firebase.........so code ???
      // if (winningParty == widget.partyName)
      // {
      //   if(selectedElectionType == "General (Lok Sabha)" || selectedElectionType == "Council of States (Rajya Sabha)")
      //   {  partyPath = "Vote Chain/Election/$selectedYear/Special Electoral Commission/$selectedElectionType/State/$selectedState/Party_Candidate/${widget.partyName}";      }
      //   else
      //   {  partyPath = "Vote Chain/State/$selectedState/Election/$selectedYear/Special Electoral Commission/$selectedElectionType/Party_Candidate/${widget.partyName}";      }
      // }
      // else if (winningParty != widget.partyName)
      // {  _showErrorMessage("Only ruling party can apply for $selectedElectionType.");  return;  }

    }


    final docRef = FirebaseFirestore.instance.doc(partyPath);
    final existingData = await docRef.get();

    if (existingData.exists)
    {
      SnackbarUtils.showErrorMessage(context,"Your party has already applied for this election.");
      return;
    }

    await docRef.set({
      "partyName": widget.partyName,
      "symbol": _symbolController.text.trim(),
      "members": _membersController.text.trim(),
      "isPartyApproved": "Pending Verification",
      "timestamp": FieldValue.serverTimestamp(),
    });

    SnackbarUtils.showSuccessMessage(context,"Application submitted successfully. ECI will verify your details.");
  }

  Future<void> _checkPartyStatus() async
  {
    if (selectedElectionType == null || selectedYear == null || selectedState == null)
    {
      SnackbarUtils.showErrorMessage(context,"Please select all required fields to check the status.");
      return;
    }

    String  partyPath = "";

    if (selectedElectionType == "General (Lok Sabha)" || selectedElectionType == "Council of States (Rajya Sabha)")
    {  partyPath = "Vote Chain/Election/$selectedYear/$selectedElectionType/State/$selectedState/Party_Candidate/${widget.partyName}";      }
    else if
    (
      selectedElectionType == "State Assembly (Vidhan Sabha)" || selectedElectionType == "Legislary Council (Vidhan Parishad)"  ||
      selectedElectionType == "Municipal" || selectedElectionType == "Panchayat"
    )
    {  partyPath = "Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Party_Candidate/${widget.partyName}";    }
    else if
    (selectedElectionType == "By-elections" || selectedElectionType == "Referendum" || selectedElectionType == "Confidence Motion (Floor Test)" || selectedElectionType == "No Confidence Motion")
    {
      SnackbarUtils.showSuccessMessage(context,"Status-checking logic isn't ready for $selectedElectionType.\n Select other Election type.");

      // // Allow only if the Winning Party field is equal to the party name
      // // get winning party status from firebase.........so code ???
      // if (winningParty == widget.partyName)
      // {
      //   if(selectedElectionType == "General (Lok Sabha)" || selectedElectionType == "Council of States (Rajya Sabha)")
      //   {  partyPath = "Vote Chain/Election/$selectedYear/Special Electoral Commission/$selectedElectionType/State/$selectedState/Party_Candidate/${widget.partyName}";      }
      //   else
      //   {  partyPath = "Vote Chain/State/$selectedState/Election/$selectedYear/Special Electoral Commission/$selectedElectionType/Party_Candidate/${widget.partyName}";      }
      // }
      // else if (winningParty != widget.partyName)
      // {  _showErrorMessage("Only ruling party can apply for $selectedElectionType.");  return;  }

    }

    final docRef = FirebaseFirestore.instance.doc(partyPath);
    final existingData = await docRef.get();

    if (existingData.exists) {
      final status = existingData.data()?['isPartyApproved'] ?? "No Status Found";
      SnackbarUtils.showSuccessMessage(context,"Application Status: $status");
    } else {
      SnackbarUtils.showErrorMessage(context,"No application found for your party in this election.");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Party Registration & Status',
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
          tabs: const [
            // Tab(text: "Apply as Party"),        // Tab 1
            // Tab(text: "Party Approval Status"),   // Tab 2
            Tab(
              icon: Row(
                children: [
                  Icon(Icons.app_registration),
                  SizedBox(width: 8),  // Space between the icon and the text
                  Text('As Party', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Tab(
              icon: Row(
                children: [
                  Icon(Icons.check_circle_outline),
                  SizedBox(width: 8),  // Space between the icon and the text
                  Text('Approval', style: TextStyle(fontWeight: FontWeight.bold)),    // Approval Status++
                ],
              ),
            ),
          ],
          // Custom TabBar styling
          indicatorColor: Colors.white, // Color of the indicator (line under selected tab)
          labelColor: Colors.white, // Color of the selected tab text
          unselectedLabelColor: AppConstants.secondaryColor, // Color of unselected tab text
          indicatorWeight: 5.0, // Thickness of the indicator
          indicatorPadding: EdgeInsets.symmetric(horizontal: 8), // Padding for indicator
          labelStyle: TextStyle( fontWeight: FontWeight.bold, fontSize: 19 ),
          unselectedLabelStyle: TextStyle( fontWeight: FontWeight.normal, fontSize: 19),
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
                buildDropdownField(
                  label: "Year",
                  items: AppConstants.electionYear,
                  selectedValue: selectedYear,
                  onChanged: (value) => setState(() => selectedYear = value),
                ),
                buildDropdownField(
                  label: "Election Type",
                  items: AppConstants.electionTypesForPartyHead,
                  selectedValue: selectedElectionType,
                  // onChanged: (value) => setState(() => selectedElectionType = value),
                  onChanged: (value) {
                    setState(() {
                      selectedElectionType = value;
                      if
                      (   selectedElectionType == "By-elections" || selectedElectionType == "Referendum" ||
                          selectedElectionType == "Confidence Motion (Floor Test)" || selectedElectionType == "No Confidence Motion"
                      )
                      { SnackbarUtils.showErrorMessage(context, "The $selectedElectionType is under implementation...\nPlease change to other Election Type."); } });
                  },
                ),
                StateDropdownField(
                  label: "State",
                  // items: AppConstants.statesAndUT,
                  selectedState: selectedState,
                  onChanged: (value) => setState(() => selectedState = value), selectedElectionType: selectedElectionType,
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
                  child: buildStyledButton(
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
                buildDropdownField(
                  label: "Year",
                  items: AppConstants.electionYear,
                  selectedValue: selectedYear,
                  onChanged: (value) => setState(() => selectedYear = value),
                ),
                buildDropdownField(
                  label: "Election Type",
                  items: AppConstants.electionTypesForPartyHead,
                  selectedValue: selectedElectionType,
                  // onChanged: (value) => setState(() => selectedElectionType = value),
                  onChanged: (value) {
                    setState(() {
                      selectedElectionType = value;
                      if
                      (   selectedElectionType == "By-elections" || selectedElectionType == "Referendum" ||
                          selectedElectionType == "Confidence Motion (Floor Test)" || selectedElectionType == "No Confidence Motion"
                      )
                      {
                        SnackbarUtils.showErrorMessage(context,"Status-checking logic isn't ready for $selectedElectionType.\nSelect other Election type.");
                        selectedElectionType = null; // Reset state on election type change
                        setState(() {
                          selectedElectionType = null; // Reset state on unsupported election type
                          selectedState = null; // Reset state on election type change
                        });
                      }
                      // selectedState = null; // Reset state on election type change
                    });
                  },
                ),
                StateDropdownField(
                  label: "State",
                  // items: AppConstants.statesAndUT,
                  selectedState: selectedState,
                  onChanged: (value) => setState(() => selectedState = value), selectedElectionType: selectedElectionType,
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
                  child: buildStyledButton(
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
