

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../SERVICE/backend_connectivity/smart_contract_service.dart';
import '../../SERVICE/screen/styled_widget.dart';
import '../../SERVICE/utils/app_constants.dart';
import '../admin/election_details.dart';

class PartyApplicationForElection extends StatefulWidget {
  final String stateName;
  final String partyName;

  const PartyApplicationForElection({Key? key,required this.stateName, required this.partyName}) : super(key: key);

  @override
  _PartyApplicationForElectionState createState() => _PartyApplicationForElectionState();
}

class _PartyApplicationForElectionState extends State<PartyApplicationForElection>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  final _privateKeyMetaMaskController = TextEditingController();
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
    _privateKeyMetaMaskController.dispose();
    super.dispose();
  }

  Future<void> _applyForElection() async
  {
    if
    (
      selectedElectionType == null || selectedYear == null || selectedState == null

      /// ******************    **********    *******   ***   *             ******************    **********    *******   ***   *    Can comment-out below condition to not use take MetaMask Key for solidity fun          ******************    **********    *******   ***   *             ******************    **********    *******   ***   *

      // || _privateKeyMetaMaskController.text.isEmpty

      /// ******************    **********    *******   ***   *             ******************    **********    *******   ***   *    Can comment-out above condition to not use take MetaMask Key for solidity fun          ******************    **********    *******   ***   *             ******************    **********    *******   ***   *

    )
    { SnackbarUtils.showErrorMessage(context, "Please select all required fields before applying.");  return; }

    if (_symbolController.text.isEmpty || _membersController.text.isEmpty)
    { SnackbarUtils.showErrorMessage(context,"Please provide party symbol and members' details."); return; }

    final privateKey = _privateKeyMetaMaskController.text.trim(); //  Get private key from input
    // Store privateKeyMetaMask in the election_details.dart singleton
    ElectionDetails.instance.privateKeyMetaMask = privateKey;

    String electionActivityPath = "";
    String  partyPath = "";

    if (selectedElectionType == "General (Lok Sabha)" || selectedElectionType == "Council of States (Rajya Sabha)")
    {
      electionActivityPath = "Vote Chain/Election/$selectedYear/$selectedElectionType/State/$selectedState/Admin/Election Activity";
      partyPath = "Vote Chain/Election/$selectedYear/$selectedElectionType/State/$selectedState/Party_Candidate/${widget.partyName}";
    }
    else if
    (
      selectedElectionType == "State Assembly (Vidhan Sabha)" || selectedElectionType == "Legislary Council (Vidhan Parishad)"  ||
      selectedElectionType == "Municipal" || selectedElectionType == "Panchayat"
    )
    {
      electionActivityPath = "Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Admin/Election Activity";
      partyPath = "Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Party_Candidate/${widget.partyName}";
    }
    else if
    (selectedElectionType == "By-elections" || selectedElectionType == "Referendum" || selectedElectionType == "Confidence Motion (Floor Test)" || selectedElectionType == "No Confidence Motion")
    {
      SnackbarUtils.showErrorMessage(context,"This functionality for $selectedElectionType is under development.\nPlease choose another.");
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

    // Fetch current stage of election
    DocumentSnapshot electionActivity = await FirebaseFirestore.instance.doc('$electionActivityPath').get();

    if (!electionActivity.exists)
    { SnackbarUtils.showErrorMessage(context, "Election has not been created yet."); return;  }         // If election does not exist (created)

    int currentStage = (electionActivity['currentStage'] ?? 1).toInt();
    // bool isStageStopped = electionActivity['stage1Completed'] ?? false;  // Assuming stage1Completed indicates if stage 1 is stopped or completed


    /// ******************    **********    *******   ***   *             ******************    **********    *******   ***   *    Can comment-out below fun to not use solidity fun          ******************    **********    *******   ***   *             ******************    **********    *******   ***   *
    /// ******************    **********    *******   ***   *             ******************    **********    *******   ***   *    Can comment-out below fun to not use solidity fun          ******************    **********    *******   ***   *             ******************    **********    *******   ***   *

    // String electionStatus = await SmartContractService().checkElectionStatus(selectedYear!, selectedElectionType!, selectedState!);
    // String partyApplication = await SmartContractService().checkPartyApplicationStatus(selectedYear!, selectedElectionType!, selectedState!);

    /// ******************    **********    *******   ***   *             ******************    **********    *******   ***   *    Can comment-out above fun to not use solidity fun          ******************    **********    *******   ***   *             ******************    **********    *******   ***   *
    /// ******************    **********    *******   ***   *             ******************    **********    *******   ***   *    Can comment-out above fun to not use solidity fun          ******************    **********    *******   ***   *             ******************    **********    *******   ***   *

    if
    (
         currentStage <= 1
         // && electionStatus == 'NOT_STARTED'
    )
    { SnackbarUtils.showErrorMessage(context, "Election isn't started yet."); return; }         // If Stage 1 has not started
    else if
    (
        currentStage == 2
        // && electionStatus == 'STARTED'
        // && partyApplication == 'NOT_STARTED'
    )
    { SnackbarUtils.showErrorMessage(context, "Party registration phase isn't started yet."); return; }         // If Stage 1 has not started
    else if
    (
        currentStage == 3
        // && electionStatus == 'STARTED'
        // && partyApplication == 'STARTED'
    )
    {
      // If Stage 1 has started but not stopped
      // Allow party head to register
      // Continue with registration logic

      final docRef = FirebaseFirestore.instance.doc(partyPath);
      final existingData = await docRef.get();

      if (existingData.exists) {
        SnackbarUtils.showErrorMessage(
            context, "Your party has already applied for this election.");
        return;
      }



      await docRef.set({
        "partyName": widget.partyName,
        "home_state": "${widget.stateName}",
        "symbol": _symbolController.text.trim(),
        "members": _membersController.text.trim(),
        "isPartyApproved": "Pending Verification",
        "timestamp": FieldValue.serverTimestamp(),
      });

      SnackbarUtils.showSuccessMessage(context,"Application submitted successfully. ECI will verify your details.");

      // Clear fields after successful submission
      setState(() {
        _partyNameController.clear();
        _symbolController.clear();
        _membersController.clear();
        _privateKeyMetaMaskController.clear();
        selectedElectionType = null;
        selectedYear = null;
        selectedState = null;
      });
    }
    else if
    (
        currentStage >= 4
        // && electionStatus == 'STARTED'
        // && partyApplication == 'STOPPED'
    )
    { SnackbarUtils.showErrorMessage(context, "Party registration is closed as Stage 1 has been completed."); return; }    // If Stage 1 is completed (stopped)
  }

  Future<void> _checkPartyStatus() async
  {
    if
    (
      selectedElectionType == null || selectedYear == null || selectedState == null

      /// ******************    **********    *******   ***   *             ******************    **********    *******   ***   *    Can comment-out below condition to not use take MetaMask Key for solidity fun          ******************    **********    *******   ***   *             ******************    **********    *******   ***   *

      // || _privateKeyMetaMaskController.text.isEmpty

      /// ******************    **********    *******   ***   *             ******************    **********    *******   ***   *    Can comment-out above condition to not use take MetaMask Key for solidity fun          ******************    **********    *******   ***   *             ******************    **********    *******   ***   *

    )
    { SnackbarUtils.showErrorMessage(context,"Please select all required fields to check the status."); return;  }

    final privateKey = _privateKeyMetaMaskController.text.trim(); //  Get private key from input
    // Store privateKeyMetaMask in the election_details.dart singleton
    ElectionDetails.instance.privateKeyMetaMask = privateKey;

    String electionActivityPath = "";
    String  partyPath = "";

    if (selectedElectionType == "General (Lok Sabha)" || selectedElectionType == "Council of States (Rajya Sabha)")
    {
      electionActivityPath = "Vote Chain/Election/$selectedYear/$selectedElectionType/State/$selectedState/Admin/Election Activity";
      partyPath = "Vote Chain/Election/$selectedYear/$selectedElectionType/State/$selectedState/Party_Candidate/${widget.partyName}";
    }
    else if
    (
      selectedElectionType == "State Assembly (Vidhan Sabha)" || selectedElectionType == "Legislary Council (Vidhan Parishad)"  ||
      selectedElectionType == "Municipal" || selectedElectionType == "Panchayat"
    )
    {
      electionActivityPath = "Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Admin/Election Activity";
      partyPath = "Vote Chain/State/$selectedState/Election/$selectedYear/$selectedElectionType/Party_Candidate/${widget.partyName}";
    }
    else if
    (selectedElectionType == "By-elections" || selectedElectionType == "Referendum" || selectedElectionType == "Confidence Motion (Floor Test)" || selectedElectionType == "No Confidence Motion")
    {
      SnackbarUtils.showErrorMessage(context,"This functionality for $selectedElectionType is under development.\nPlease choose another.");

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


    // Fetch current stage of election
    DocumentSnapshot electionActivity = await FirebaseFirestore.instance.doc('$electionActivityPath').get();

    if (!electionActivity.exists)
    { SnackbarUtils.showErrorMessage(context, "Election has not been created yet."); return;  }         // If election does not exist (created)

    int currentStage = (electionActivity['currentStage'] ?? 1).toInt();
    // bool isStageStopped = electionActivity['stage1Completed'] ?? false;  // Assuming stage1Completed indicates if stage 1 is stopped or completed



    /// ******************    **********    *******   ***   *             ******************    **********    *******   ***   *    Can comment-out below fun to not use solidity fun          ******************    **********    *******   ***   *             ******************    **********    *******   ***   *
    /// ******************    **********    *******   ***   *             ******************    **********    *******   ***   *    Can comment-out below fun to not use solidity fun          ******************    **********    *******   ***   *             ******************    **********    *******   ***   *

    // String electionStatus = await SmartContractService().checkElectionStatus(selectedYear!, selectedElectionType!, selectedState!);
    // String partyApplication = await SmartContractService().checkPartyApplicationStatus(selectedYear!, selectedElectionType!, selectedState!);

    /// ******************    **********    *******   ***   *             ******************    **********    *******   ***   *    Can comment-out above fun to not use solidity fun          ******************    **********    *******   ***   *             ******************    **********    *******   ***   *
    /// ******************    **********    *******   ***   *             ******************    **********    *******   ***   *    Can comment-out above fun to not use solidity fun          ******************    **********    *******   ***   *             ******************    **********    *******   ***   *



    if
    (
        currentStage <= 1
        // && electionStatus == 'NOT_STARTED'
    )
    { SnackbarUtils.showErrorMessage(context, "Election isn't started yet."); return; }         // If Stage 1 has not started
    else if
    (
        currentStage == 2
        // && electionStatus == 'STARTED'
        // && partyApplication == 'NOT_STARTED'
    )
    { SnackbarUtils.showErrorMessage(context, "Party registration phase isn't started yet."); return; }         // If Stage 1 has not started
    else if
    (
        currentStage == 3
        // && electionStatus == 'STARTED'
        // && partyApplication == 'STARTED'
    )
    { SnackbarUtils.showErrorMessage(context, "Party registration phase is on.\nAfter this phase ends result will be available."); return; }
    else if
    (
        currentStage >= 4                                  // If Stage 1 is completed (stopped)
        // && electionStatus == 'STARTED'
        // && partyApplication == 'STOPPED'
    )
    {
      final docRef = FirebaseFirestore.instance.doc(partyPath);
      final existingData = await docRef.get();

      if (existingData.exists)
      {
        final status = existingData.data()?['status'] ?? "No Status Found";
        if
        (status == "Unreviewed")
        { SnackbarUtils.showErrorMessage( context, "Application Status: $status.\nNot reviewed by election authorities."); }
        else if
        (status == "Accepted")
        { SnackbarUtils.showSuccessMessage( context, "Application Status: $status"); }
        else if
        (status == "Rejected")
        { SnackbarUtils.showErrorMessage( context, "Application Status: $status"); }
        else if
        (status == "Pending Approval")
        { SnackbarUtils.showNeutralMessage( context, "Application Status: $status"); }


        // // Clear fields after successful submission
        // setState(() {
        //   _privateKeyMetaMaskController.clear();
        //   selectedElectionType = null;
        //   selectedYear = null;
        //   selectedState = null;
        // });
      }
    }
    else
    { SnackbarUtils.showErrorMessage(context,"No application found for your party in this election."); }
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
                      { SnackbarUtils.showErrorMessage(context,"This functionality for $selectedElectionType is under development.\nPlease choose another."); } });
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
                const SizedBox(height: 16),
                // TextField(
                //   controller: _privateKeyMetaMaskController, // New input field
                //   obscureText: true, // Hide private key for security
                //   decoration: InputDecoration(labelText: 'MetaMask Private Key', border: OutlineInputBorder()),
                // ),
                TextField(
                  controller: _privateKeyMetaMaskController,
                  obscureText: true, // Hide private key for security
                  decoration: InputDecoration(
                    labelText: 'MetaMask Private Key (Optional)',
                    labelStyle: TextStyle(color: Colors.grey), // Optional text with gray color
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey), // Lighter border for optional field
                    ),
                    hintText: 'Can be leave empty..', // Optional hint text
                    hintStyle: TextStyle(color: Colors.grey), // Hint text in gray
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: buildStyledButton(
                    text: "Apply for Election",
                    onPressed: _applyForElection,
                    // color: AppConstants.primaryColor,
                    // color: Colors.blueAccent,
                    color: AppConstants.primaryColor,
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
                        SnackbarUtils.showErrorMessage(context,"This functionality for $selectedElectionType is under development.\nPlease choose another.");
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
                const SizedBox(height: 16),
                // TextField(
                //   controller: _privateKeyMetaMaskController, // New input field
                //   obscureText: true, // Hide private key for security
                //   decoration: InputDecoration(labelText: 'MetaMask Private Key', border: OutlineInputBorder()),
                // ),
                TextField(
                  controller: _privateKeyMetaMaskController,
                  obscureText: true, // Hide private key for security
                  decoration: InputDecoration(
                    labelText: 'MetaMask Private Key',
                    labelStyle: TextStyle(color: Colors.grey), // Optional text with gray color
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey), // Lighter border for optional field
                    ),
                    hintText: 'Optional for now..', // Optional hint text
                    hintStyle: TextStyle(color: Colors.grey), // Hint text in gray
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: buildStyledButton(
                    text: "Check Application Status",
                    onPressed: _checkPartyStatus,
                    // color: Colors.blueAccent,
                    color: AppConstants.primaryColor,
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

