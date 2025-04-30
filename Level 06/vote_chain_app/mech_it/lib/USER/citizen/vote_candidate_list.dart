
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:location/location.dart';
// import 'package:location/location.dart' as loc;
// import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:mech_it/SERVICE/screen/styled_widget.dart';
import 'package:mech_it/USER/citizen/vote_candidate.dart';

import '../../Future Apply[ (reg) & no login ]/login.dart';
import '../../SERVICE/backend_connectivity/smart_contract_service.dart';
import '../../SERVICE/utils/app_constants.dart';
import '../admin/election_details.dart';
import 'eligible_elections.dart';

class VoteCandidateList extends StatefulWidget {
  final String state;
  final String userEmail;
  final String electionId;
  final String electionPath;
  final String electionType;

  const VoteCandidateList({ required this.state, required this.userEmail, required this.electionId, required this.electionPath, required this.electionType });

  @override
  _VoteCandidateListState createState() => _VoteCandidateListState();
}

class _VoteCandidateListState extends State<VoteCandidateList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _candidates = [];
  List<Map<String, dynamic>> fetchedCandidates = []; // Define the variable here

  String? userConstituency;

  @override
  void initState() {
    super.initState();
    _fetchUserConstituency();
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16, color: Colors.black),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Fetches the user's assigned constituency from their profile
  Future<void> _fetchUserConstituency() async
  {
    try
    {
      var userDoc = await _firestore.collection("Vote Chain/State/${widget.state}/Citizen/Citizen")
          .doc(widget.userEmail)
          .get();

      if (userDoc.exists)
      {
        setState(() { userConstituency = userDoc.data()?['Original_Constituency']; });
        if
        (widget.electionType == "State")
        {  setState(() { userConstituency = userDoc.data()?['vidhanSabhaConstituency']; });   }
        else if
        (widget.electionType == "National")
        {  setState(() { userConstituency = userDoc.data()?['locSabhaConstituency']; });  }

        if
        (userConstituency != null)
        { _fetchCandidates(); }
      }
      else
      { print("User profile not found."); }
    }
    catch (e)
    { print("Error fetching user profile: $e"); }
  }

  /// Fetches candidates based on the user's constituency
  /// Below code fetches candidate but not mail
  /// ...
  /// Below code fetches candidate + tried to get email but failing....will c --> listCollections() @ version scene....
  /// ...
  /// Below code fetches all detaills   --> *** As the path structure to store is change so...getting
  Future<void> _fetchCandidates() async {
    if (userConstituency == null)
    {
      print("❌ User's constituency is not set.");
      return;
    }

    String basePath = '';
    String electionYear = AppConstants.getCurrentYear();


    // Determine the correct base path
    if
    (widget.electionType == "State")
    // { basePath = "Vote Chain/State/${widget.state}/Election/2024/${widget.electionId}/Result"; }
    { basePath = "Vote Chain/State/${widget.state}/Election/$electionYear/${widget.electionId}/Result"; }
    else if
    (widget.electionType == "National")
    // { basePath = "Vote Chain/Election/2024/${widget.electionId}/State/${widget.state}/Result"; }
    { basePath = "Vote Chain/Election/$electionYear/${widget.electionId}/State/${widget.state}/Result"; }

    else
    {
      print("❌ Invalid election type");
      return;
    }

    // Access the Election_Result document (before constituency and parties)
    String electionResultPath = "$basePath";

    print("📌 Fetching candidates from: $electionResultPath");

    try
    {
      List<Map<String, dynamic>> fetchedCandidates = [];

      // Fetch the parties for the specific constituency
      var partySnapshots = await _firestore
          .collection("$electionResultPath/Election_Result/$userConstituency")
          .get();

      // Traverse through the parties to fetch candidates
      for (var partyDoc in partySnapshots.docs)
      {
        String partyName = partyDoc.id;
        String candidateName = '';
        String candidateEmail = '';
        String voteCount = '';

        String candidateAge = '';
        String candidateGender = '';
        String candidateEducation = '';
        String candidateProfession = '';
        String candidateHomestate = '';


        print("📌 Found party: $partyName");

        // Fetch the candidate email stored as a field inside the party document
        var partyDocSnapshot = await partyDoc.reference.get();

        if (partyDocSnapshot.exists)
        {
          var partyData = partyDocSnapshot.data();

          // // Print the party data again for clarity
          // print("✅ Party Data (again): $partyData");

          if (partyData != null)
          {
            // Directly check if the field exists and print
            var candidateNameField = partyData['name'];
            var candidateEmailField = partyData['candidate_email'];
            var voteCountField = partyData['vote_count'];

            var candidateAgeField = partyData['age'];
            var candidateGenderField = partyData['gender'];
            var candidateEducationField = partyData['education'];
            var candidateProfessionField = partyData['profession'];
            var candidateHomestateField = partyData['candidateHomeState'];


            // print("✅ Type of candidate_email field: ${candidateEmailField.runtimeType}");
            // print("✅ Value of candidate_email field: $candidateEmailField");
            // print("✅ Type of vote_count field: ${voteCountField.runtimeType}");
            // print("✅ Value of vote_count field: voteCountField");

            /// was working suddenly not on 27 feb 25 because
            /*
                The error is occurring because your code is trying to assign a numerical value (the vote count) directly to a variable that’s expected to be a string.
                Even though earlier data might have been stored as strings, if the vote count is now a number, you need to convert it to a string before assigning it.

                By calling .toString() on the vote count (and any other fields), you ensure that even if they’re stored as numbers (or any other type) in Firebase,
                your variables will always be strings.
                This should resolve the “type 'int' is not a subtype of type 'String'” error.
            */

            // // Check if candidate_email is a String
            // if
            // (
            //   candidateEmailField != null
            //   && candidateEmailField is String
            // )
            // {
            //   candidateName = candidateNameField;
            //   candidateEmail = candidateEmailField;
            //   voteCount = voteCountField;
            //
            //   candidateAge = candidateAgeField;
            //   candidateGender = candidateGenderField;
            //   candidateEducation = candidateEducationField;
            //   candidateProfession = candidateProfessionField;
            //   candidateHomestate = candidateHomestateField;
            //   // print("✅ Candidate email found: $candidateEmail");
            // }
            ///
            // Instead of checking only if candidateEmailField is a String,
            // check for null and then convert all values to string.
            if (candidateEmailField != null) {
              candidateName = candidateNameField.toString();
              candidateEmail = candidateEmailField.toString();
              voteCount = voteCountField.toString();

              candidateAge = candidateAgeField.toString();
              candidateGender = candidateGenderField.toString();
              candidateEducation = candidateEducationField.toString();
              candidateProfession = candidateProfessionField.toString();
              candidateHomestate = candidateHomestateField.toString();
            }
            else
            { print("❌ Candidate email field is either missing, null, or not a String");  }
          }
          else
          { print("❌ Party data is null"); }
        }
        else
        { print("❌ Document does not exist"); }

        // Add candidate information to the list
        fetchedCandidates.add({
          'name': candidateName ?? '',  // Candidate's email is the document ID
          'email': candidateEmail ?? '',
          'party': partyName,
          'constituency': userConstituency,
          'vote_count': voteCount ?? '0',

          'age': candidateAge ?? 'N/A',
          'gender': candidateGender ?? 'N/A',
          'education': candidateEducation ?? 'N/A',
          'profession': candidateProfession ?? 'N/A',
          'home_state': candidateHomestate ?? 'N/A',
        });

        // print("✅ Candidate: $candidateEmail (Party: $partyName, Constituency: $userConstituency)");
      }

      // Update the state with fetched candidates
      setState(() { _candidates = fetchedCandidates; });

      // Debugging the candidates list before the UI rebuild
      // print("✅ Successfully fetched ${_candidates.length} candidates.");
      // print("Candidates List: $_candidates");  // Make sure this is printing the correct data
    }
    catch (e)
    {  print("❌ Error fetching candidates: $e"); }
  }

  /// Handles the voting action
  // Future<void> _authenticateAndVote(String candidateEmail) async {
  //
  //   String electionYear = AppConstants.getCurrentYear();
  //   // First, check if the citizen has already voted for this election.
  //   if (await _hasAlreadyVoted(electionYear))
  //   {
  //     SnackbarUtils.showErrorMessage(context, "You have already voted in this election.");
  //     return;
  //   }
  //
  //   String enteredPassword = "";
  //   await showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text("Enter Password"),
  //       content: TextField(
  //         obscureText: true,
  //         onChanged: (value) => enteredPassword = value,
  //         decoration: InputDecoration(hintText: "Enter your password"),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text("Cancel"),
  //         ),
  //         TextButton(
  //           onPressed: () async {
  //             if (await _verifyPassword(enteredPassword))
  //             {
  //               Navigator.pop(context);
  //               _confirmVote(candidateEmail);
  //             }
  //             else
  //             {  SnackbarUtils.showErrorMessage(context,"Invalid Password"); }
  //           },
  //           child: Text("Confirm"),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  ///
  Future<void> _authenticateAndVote(String candidateEmail) async {
    String electionYear = AppConstants.getCurrentYear();

    // Check if the citizen is underage.
    if (await _isUnderage()) {
      SnackbarUtils.showErrorMessage(context, "You must be at least 18 years old to vote.");
      return;
    }

    // // First, check if the citizen has already voted for this election.
    if (await _hasAlreadyVoted(electionYear)) {
      SnackbarUtils.showErrorMessage(context, "You have already voted in this election.");
      return;
    }

    String enteredPassword = "";
    /// working but not includes otp part
    // await showDialog(
    //   context: context,
    //   // barrierColor: Colors.grey.shade100, // More opaque barrier to obscure background details.
    //   barrierColor: Color(0xFFFCFDFD), //  0xFFCFEEE4
    //   barrierDismissible: false,
    //   builder: (context) => Dialog(
    //     insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
    //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    //     child: Container(
    //       padding: EdgeInsets.all(20),
    //       // Use SingleChildScrollView to handle smaller devices.
    //       child: SingleChildScrollView(
    //         child: Column(
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             Text(
    //               "Enter Password",
    //               style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    //             ),
    //             SizedBox(height: 20),
    //             TextField(
    //               obscureText: true,
    //               onChanged: (value) => enteredPassword = value,
    //               decoration: InputDecoration(
    //                 hintText: "Enter your password",
    //                 border: OutlineInputBorder(),
    //               ),
    //             ),
    //             SizedBox(height: 20),
    //             Row(
    //               mainAxisAlignment: MainAxisAlignment.end,
    //               children: [
    //                 TextButton(
    //                   onPressed: () => Navigator.pop(context),
    //                   child: Text("Cancel"),
    //                 ),
    //                 SizedBox(width: 8),
    //                 ElevatedButton(
    //                   onPressed: () async {
    //                     if (await _verifyPassword(enteredPassword)) {
    //                       Navigator.pop(context);
    //                       _confirmVote(candidateEmail);
    //                     } else {
    //                       SnackbarUtils.showErrorMessage(context, "Invalid Password");
    //                     }
    //                   },
    //                   child: Text("Confirm"),
    //                 ),
    //               ],
    //             )
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // );
    /// includes otp part
    bool showOTPField = false;
    List<TextEditingController> otpController = List.generate(6, (index) => TextEditingController());
    String enteredOTP = "";

    await showDialog(
      context: context,
      barrierColor: Color(0xFFFCFDFD),
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(
              padding: EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      showOTPField ? "Enter OTP" : "Enter Password",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),

                    // Password Input
                    if (!showOTPField) ...[
                      TextField(
                        obscureText: true,
                        onChanged: (value) => enteredPassword = value,
                        decoration: InputDecoration(
                          hintText: "Enter your password",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],

                    // OTP Input
                    if (showOTPField) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(6, (index) {
                          return Container(
                            width: 40,
                            height: 50,
                            margin: EdgeInsets.symmetric(horizontal: 4),
                            child: TextField(
                              controller: otpController[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              decoration: InputDecoration(
                                counterText: "",
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty && index < 5) {
                                  FocusScope.of(context).nextFocus();
                                }
                                if (otpController.every((c) => c.text.isNotEmpty)) {
                                  setState(() {}); // Hide OTP field when fully entered
                                }
                              },
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: 20),
                    ],

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Cancel"),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            if (!showOTPField) {
                              if (enteredPassword.isEmpty) {
                                SnackbarUtils.showErrorMessage(context, "Password cannot be empty");
                                return;
                              }

                              if (await _verifyPassword(enteredPassword)) {
                                setState(() => showOTPField = true);
                              } else {
                                SnackbarUtils.showErrorMessage(context, "Invalid Password");
                                return;
                              }
                            } else {
                              enteredOTP = otpController.map((c) => c.text).join();

                              if (enteredOTP.length < 6) {
                                SnackbarUtils.showErrorMessage(context, "OTP cannot be empty");
                                return;
                              }

                              if (enteredOTP == "123456") {
                                Navigator.pop(context);
                                _confirmVote(candidateEmail);
                              } else {
                                SnackbarUtils.showErrorMessage(context, "Invalid OTP");
                                return;
                              }
                            }
                          },
                          child: Text(showOTPField ? "Confirm" : "Next"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );


  }
  Future<bool> _isUnderage() async {
    // Get the citizen's profile document.
    DocumentSnapshot userDoc = await _firestore
        .collection("Vote Chain/State/${widget.state}/Citizen/Citizen")
        .doc(widget.userEmail)
        .get();

    Map<String, dynamic> citizenData = userDoc.data() as Map<String, dynamic>;
    String birthDateStr = citizenData['birthDate'] ?? "";

    // If no birth date is stored, consider the user underage (or not eligible).
    if (birthDateStr.isEmpty) return true;

    DateTime? birthDate = DateTime.tryParse(birthDateStr);
    if (birthDate == null) return true;

    // Calculate age.
    int age = DateTime.now().year - birthDate.year;
    if (DateTime.now().month < birthDate.month ||
        (DateTime.now().month == birthDate.month && DateTime.now().day < birthDate.day)) {
      age--;
    }
    return age < 18;
  }
  Future<bool> _hasAlreadyVoted(String electionYear) async {
    // Get the citizen's profile document.
    DocumentSnapshot citizenDoc = await _firestore
        .collection("Vote Chain/State/${widget.state}/Citizen/Citizen")
        .doc(widget.userEmail)
        .get();

    Map<String, dynamic> citizenData = citizenDoc.data() as Map<String, dynamic>;

    // If there's no electionData field, the citizen hasn't voted yet.
    if (!citizenData.containsKey("electionData")) return false;

    // Determine the election field based on the election ID.
    String electionField = "";
    if (widget.electionId == "State Assembly (Vidhan Sabha)") { electionField = 'vidhanSabha'; }
    else if (widget.electionId == "General (Lok Sabha)") { electionField = 'locSabha'; }
    else if (widget.electionId.contains("Municipal")) { electionField = 'municipal'; }
    else if (widget.electionId.contains("Panchayat")) { electionField = 'Panchayat'; }

    // Check if the electionData map contains the election field.
    Map<String, dynamic> electionData = citizenData["electionData"];
    if (electionData.containsKey(electionField))
    {
      Map<String, dynamic> fieldMap = electionData[electionField];
      // If there's already a record for this election year, the citizen has voted.
      if (fieldMap.containsKey(electionYear))
      { return true; }
    }
    return false;
  }
  Future<bool> _verifyPassword(String password) async {
    try
    {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: widget.userEmail,
        password: password,
      );
      return true; // Authentication successful
    }
    catch (e)
    {
      SnackbarUtils.showErrorMessage(context,"Invalid Password");
      print("Authentication failed: $e");
      return false;
    }
  }

  /// original
  // void _confirmVote(String candidateEmail) {
  //   showDialog(
  //     context: context,
  //     // barrierColor: Colors.blueGrey.shade900, // More opaque barrier to obscure background details.
  //     barrierColor: Color(0xFFFCFDFD), //  0xFFCFEEE4
  //     builder: (context) => AlertDialog(
  //       title: Text("Confirm Your Vote"),
  //       content: Text("Are you sure you want to vote for this candidate?"),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text("Cancel"),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             _submitVote(candidateEmail);
  //           },
  //           child: Text("Yes, Vote"),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  /// improved
  // void _confirmVote(String candidateEmail) {
  //   TextEditingController privateKeyController = TextEditingController();
  //   showDialog(
  //     context: context,
  //     barrierColor: Color(0xFFFCFDFD),
  //     builder: (context) => AlertDialog(
  //       title: Text("Enter Your Private Key"),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Text("Enter your MetaMask private key to confirm your vote."),
  //           TextField(
  //             controller: privateKeyController,
  //             obscureText: true, // Hide input for security
  //             decoration: InputDecoration(
  //               hintText: "Enter Private Key",
  //               border: OutlineInputBorder(),
  //             ),
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text("Cancel"),
  //         ),
  //         TextButton(
  //           onPressed: () {
  //             String privateKey = privateKeyController.text.trim();
  //             if (privateKey.isNotEmpty) {
  //               Navigator.pop(context); // Close dialog
  //               _submitVote(candidateEmail,);
  //             } else {
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                   SnackBar(content: Text("Private key is required to vote!"))
  //               );
  //             }
  //           },
  //           child: Text("Confirm & Vote"),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  /// improved++
  void _confirmVote(String candidateEmail) {
    TextEditingController privateKeyController = TextEditingController();

    showDialog(
      context: context,
      barrierColor: Color(0xFFFCFDFD),
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Center(
          child: Text(
            "Secure Voting",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_outline_rounded, size: 55, color: Colors.blueAccent),
                SizedBox(height: 15),
                Text(
                  "Enter your MetaMask private key to confirm your vote.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17, color: Colors.black87),
                ),
                SizedBox(height: 18),
                TextField(
                  controller: privateKeyController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Private Key",
                    prefixIcon: Icon(Icons.vpn_key_rounded, color: Colors.blueAccent),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text("Cancel", style: TextStyle(fontSize: 16)),
                  ),
                ),
                SizedBox(width: 6),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      String privateKey = privateKeyController.text.trim();
                      if (privateKey.isNotEmpty) {
                        // Assign the entered private key to the singleton instance
                        ElectionDetails.instance.privateKeyMetaMask = privateKey;
                        Navigator.pop(context); // Close dialog
                        _submitVote(candidateEmail);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Private key is required to vote!")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text("Confirm & Vote", style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Future<void> _submitVote(String candidateEmail) async
  {
    // Show a loading animation until the vote process is complete.
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Color(0xFFFCFDFD), //  0xFFCFEEE4
      builder: (context) => Center(child: CircularProgressIndicator()),
    );
    String electionYear = AppConstants.getCurrentYear();

    // Declare collectionPath as a mutable variable
    String electionActivityPath = "";

    if
    (   widget.electionId == "General (Lok Sabha)" || widget.electionId == "Council of States (Rajya Sabha)")
    { electionActivityPath = "Vote Chain/Election/$electionYear/${widget.electionId}/State/${widget.state}/Admin/Election Activity";    }
    else if
    (
        widget.electionId == "State Assembly (Vidhan Sabha)" || widget.electionId == "Legislary Council (Vidhan Parishad)" ||
        widget.electionId == "Municipal" || widget.electionId == "Panchayat"
    )
    { electionActivityPath = "Vote Chain/State/${widget.state}/Election/$electionYear/${widget.electionId}/Admin/Election Activity";  }
    else if
    (  (widget.electionId == "Presidential" || widget.electionId == "Vice-Presidential") && widget.state == "_PAN India")
    { electionActivityPath = "Vote Chain/Election/$electionYear/Special Electoral Commission/${widget.electionId}/Admin/Election Activity"; }
    else if
    (widget.electionId == "By-elections"
    // &&
    // (subElectionType == "General (Lok Sabha)" || subElectionType == "Council of States (Rajya Sabha)")
    )
    {
      SnackbarUtils.showErrorMessage(context,"This functionality for ${widget.electionId} is under development.\nPlease choose another.");
      // collectionPath = "Vote Chain/Election/$selectedYear/Special Electoral Commission/$selectedElectionType/$subElectionType/State/$selectedState/Party_Candidate/$selectedParty/$selectedConstituency/Candidate_Application";
    }
    else if
    (widget.electionId == "By-elections"
    // &&
    // (
    //     subElectionType == "State Assembly (Vidhan Sabha)" || subElectionType == "Legislary Council (Vidhan Parishad)" ||
    //     subElectionType == "Municipal" || subElectionType == "Panchayat"
    // )
    )
    {
      SnackbarUtils.showErrorMessage(context,"This functionality for ${widget.electionId} is under development.\nPlease choose another.");
      // collectionPath = "Vote Chain/State/$selectedState/Election/$selectedYear/Special Electoral Commission/$selectedElectionType/Party_Candidate/$selectedParty/$selectedConstituency/Candidate_Application";
    }

    // Debugging prints
    print("Election Type: ${widget.electionId}");
    print("State: ${widget.state}");
    print("Election Activity Path: $electionActivityPath");

    if (electionActivityPath.isEmpty)
    {
      print("\n\n****************\nError: electionActivityPath is empty.");
      SnackbarUtils.showErrorMessage(context, "Election path is invalid. Please try again.");
      return;
    }

    DocumentSnapshot electionActivity = await FirebaseFirestore.instance.doc('$electionActivityPath').get();
    if (!electionActivity.exists)
    { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Election has not been created yet.'))); return; }

    int currentStage = (electionActivity['currentStage'] ?? 1).toInt();
    bool isFirebaseElectionActive = false; // Initialize to avoid uninitialized variable error
    if (electionActivity.exists)
    {
      String isElectionActive = electionActivity.get("isElectionActive").toString().toLowerCase();
      if (isElectionActive == "true")
      { isFirebaseElectionActive = true; }
    }




    /// ******************    **********    *******   ***   *             ******************    **********    *******   ***   *    Can comment-out below fun to not use solidity fun          ******************    **********    *******   ***   *             ******************    **********    *******   ***   *
    /// ******************    **********    *******   ***   *             ******************    **********    *******   ***   *    Can comment-out below fun to not use solidity fun          ******************    **********    *******   ***   *             ******************    **********    *******   ***   *

    // String electionStatus = await SmartContractService().checkElectionStatus(electionYear, widget.electionType, widget.state);
    // String partyApplication = await SmartContractService().checkPartyApplicationStatus(electionYear, widget.electionType, widget.state);
    // String candidateApplication = await SmartContractService().checkCandidateApplicationStatus(electionYear, widget.electionType, widget.state);

    /// ******************    **********    *******   ***   *             ******************    **********    *******   ***   *    Can comment-out above fun to not use solidity fun          ******************    **********    *******   ***   *             ******************    **********    *******   ***   *
    /// ******************    **********    *******   ***   *             ******************    **********    *******   ***   *    Can comment-out above fun to not use solidity fun          ******************    **********    *******   ***   *             ******************    **********    *******   ***   *




    try
    {
      // 1. Call the blockchain vote function.
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
      { SnackbarUtils.showErrorMessage(context, "Party registration phase itself isn't started yet."); return; } // If Stage 1 has not started
      else if
      (
        currentStage == 3
        // && electionStatus == 'STARTED'
        // && partyApplication == 'STARTED'
      )
      { SnackbarUtils.showErrorMessage(context, "Party registration phase is on as of now."); return; }
      else if
      (
        currentStage == 4
        // && electionStatus == 'STARTED'
        // && partyApplication == 'STOPPED'
        // && candidateApplication == 'NOT_STARTED'
      )
      { SnackbarUtils.showErrorMessage(context,"Candidate Application phase is not started yet, will start soon."); return; } // cand app acceptance is not started
      else if
      (
        currentStage == 5                                  //......allow candidate to apply
        // && electionStatus == 'STARTED'
        // && partyApplication == 'STOPPED'
        // && candidateApplication == 'STARTED'
        /// Voting != 'STARTED'  ...................  Not in contract
      )
      { SnackbarUtils.showErrorMessage(context,"Candidate Application phase is on as of now."); return; } // cand app acceptance is not started
      else if
      (
      currentStage == 6                                  //......allow candidate to apply
      // && electionStatus == 'STARTED'
      // && partyApplication == 'STOPPED'
      // && candidateApplication == 'STOPPED'
      /// Voting != 'STARTED'  ...................  Not in contract
      )
      { SnackbarUtils.showErrorMessage(context,"Voting phase is not started yet, will start soon."); return; } // cand app acceptance is not started
      else if
      (
         currentStage == 7
         && isFirebaseElectionActive == true
         // && electionStatus == 'STARTED'
         // && partyApplication == 'STOPPED'
         // && candidateApplication == 'STOPPED'
         // /// Voting != 'STARTED'  ...................  Not in contract
      )
      {
        // **Call the vote function and check if it succeeds**
        try
        {  await SmartContractService().vote(electionYear, widget.electionId, widget.state, candidateEmail);     }          // **************  ********* ** *
        catch (e)
        {
          // If voting fails, show error message and stop further execution.
          Navigator.pop(context);
          SnackbarUtils.showErrorMessage(context, "Voting Failed: $e");
          print("Error in vote function: $e");
          return;
        }  // Stops further execution
        // await Future.delayed(Duration(seconds: 2)); // Simulate blockchain delay
      }
      else if
      (
      currentStage >= 8
      && isFirebaseElectionActive == false
      // && electionStatus == 'STARTED'
      // && partyApplication == 'STOPPED'
      // && candidateApplication == 'STOPPED'
      /// Voting == 'STOPPED'  ...................  Not in contract
      )
      { SnackbarUtils.showErrorMessage(context, "Voting phase is stopped."); return; }

      // **If voting succeeds, then proceed with updating metadata and citizen records**

      // 2. Update aggregated meta data for reporting.
      await updateAggregatedMetaData(candidateEmail);

      // 3. Update the citizen's election record.
      await updateCitizenElectionRecord(electionYear);

      // 4. Show a success message.
      _showSuccessMessage();
    }
    catch (e)
    {
      // Dismiss the loading animation.
      Navigator.pop(context);
      SnackbarUtils.showErrorMessage(context, "Voting failed.. Something went wrong.");
      print("Error during vote submission: $e");
    }
  }

  /// original
  // Future<void> updateAggregatedMetaData() async
  // {
  //   // Fetch citizen's profile
  //   DocumentSnapshot userDoc = await _firestore
  //       .collection("Vote Chain/State/${widget.state}/Citizen/Citizen")
  //       .doc(widget.userEmail)
  //       .get();
  //
  //   Map<String, dynamic> citizenData = userDoc.data() as Map<String, dynamic>;
  //   String gender = citizenData['gender'] ?? '';
  //   String educationStatus = citizenData['education'] ?? '';
  //   String employmentStatus = citizenData['employmentStatus'] ?? '';
  //   String residence = citizenData['residence'] ?? '';
  //   String voterCategory = citizenData['voterCategory'] ?? '';
  //   String disabilityStatus = citizenData['disabilityStatus'] ?? '';
  //   String birthDateStr = citizenData['birthDate'] ?? ''; // Expected "yyyy-MM-dd"
  //
  //   DateTime? birthDate = DateTime.tryParse(birthDateStr);
  //   String ageGroup = calculateAgeGroup(birthDate ?? DateTime(2000));
  //   // Determine current time slot
  //   int hour = DateTime.now().hour;
  //   String timeSlot = (hour >= 5 && hour < 12)
  //       ? "morning"
  //       : (hour >= 12 && hour < 17)
  //       ? "afternoon"
  //       : (hour >= 17 && hour < 21)
  //       ? "evening"
  //       : "night" ;
  //
  //
  //   String electionYear = AppConstants.getCurrentYear();
  //
  //   String resultPath = '';
  //   if
  //   (widget.electionType == "State")
  //   { resultPath = "Vote Chain/State/${widget.state}/Election/$electionYear/${widget.electionId}/Result"; }
  //   else if
  //   (widget.electionType == "National")
  //   { resultPath = "Vote Chain/Election/$electionYear/${widget.electionId}/State/${widget.state}/Result"; }
  //   DocumentReference resultDoc = _firestore.doc("$resultPath/Fetched_Result");

  //   // Now update the fetched result document with a nested Metadata map.
  //   // The key "Metadata" holds a sub-map with the constituency name (userConstituency)
  //   // and under that sub-map, all your counters are stored.
  //   await resultDoc.set({
  //     "Metadata.$userConstituency.ageGroup_$ageGroup": FieldValue.increment(1),
  //     "Metadata.$userConstituency.gender_${gender}": FieldValue.increment(1),
  //     "Metadata.$userConstituency.educationStatus_${educationStatus}": FieldValue.increment(1),
  //     "Metadata.$userConstituency.employmentStatus_${employmentStatus}": FieldValue.increment(1),
  //     "Metadata.$userConstituency.residence_${residence}": FieldValue.increment(1),
  //     "Metadata.$userConstituency.voterCategory_${voterCategory}": FieldValue.increment(1),
  //     "Metadata.$userConstituency.disability_${disabilityStatus}": FieldValue.increment(1),
  //     "Metadata.$userConstituency.timeSlot_$timeSlot": FieldValue.increment(1),
  //     "Metadata.$userConstituency.constituencyTotalVotes": FieldValue.increment(1),
  //   }, SetOptions(merge: true));
  // }
  /// improved
  Future<void> updateAggregatedMetaData(String candidateEmail) async
  {
    // Fetch citizen's profile
    DocumentSnapshot userDoc = await _firestore
        .collection("Vote Chain/State/${widget.state}/Citizen/Citizen")
        .doc(widget.userEmail)
        .get();

    Map<String, dynamic> citizenData = userDoc.data() as Map<String, dynamic>;
    String gender = citizenData['gender'] ?? '';
    String educationStatus = citizenData['education'] ?? '';
    String employmentStatus = citizenData['employmentStatus'] ?? '';
    String residence = citizenData['residence'] ?? '';
    String voterCategory = citizenData['voterCategory'] ?? '';
    String disabilityStatus = citizenData['disabilityStatus'] ?? '';
    String birthDateStr = citizenData['birthDate'] ?? ''; // Expected "yyyy-MM-dd"

    DateTime? birthDate = DateTime.tryParse(birthDateStr);
    String ageGroup = calculateAgeGroup(birthDate ?? DateTime(2000));

    // Determine current time slot
    int hour = DateTime.now().hour;
    String timeSlot = (hour >= 5 && hour < 12)
        ? "morning"
        : (hour >= 12 && hour < 17)
        ? "afternoon"
        : (hour >= 17 && hour < 21)
        ? "evening"
        : "night";

    String electionYear = AppConstants.getCurrentYear();
    String resultPath = '';
    if
    (widget.electionType == "State")
    { resultPath = "Vote Chain/State/${widget.state}/Election/$electionYear/${widget.electionId}/Result"; }
    else if
    (widget.electionType == "National")
    { resultPath = "Vote Chain/Election/$electionYear/${widget.electionId}/State/${widget.state}/Result"; }

    DocumentReference resultDoc = _firestore.doc("$resultPath/Fetched_Result");

    // Fetch existing metadata to merge and increment values properly
    DocumentSnapshot resultSnapshot = await resultDoc.get();
    Map<String, dynamic> existingMetadata = resultSnapshot.exists
        ? (resultSnapshot.data() as Map<String, dynamic>)["Metadata"] ?? {}
        : {};

    // Create/update nested metadata structure
    Map<String, dynamic> constituencyMetadata = existingMetadata[userConstituency] ?? {};

    if (candidateEmail == "NOTA")
    { constituencyMetadata.update("notaVotes", (value) => value + 1, ifAbsent: () => 1); }

    constituencyMetadata.update("ageGroup_$ageGroup", (value) => value + 1, ifAbsent: () => 1);
    constituencyMetadata.update("gender_$gender", (value) => value + 1, ifAbsent: () => 1);
    constituencyMetadata.update("educationStatus_$educationStatus", (value) => value + 1, ifAbsent: () => 1);
    constituencyMetadata.update("employmentStatus_$employmentStatus", (value) => value + 1, ifAbsent: () => 1);
    constituencyMetadata.update("residence_$residence", (value) => value + 1, ifAbsent: () => 1);
    constituencyMetadata.update("voterCategory_$voterCategory", (value) => value + 1, ifAbsent: () => 1);
    constituencyMetadata.update("disability_$disabilityStatus", (value) => value + 1, ifAbsent: () => 1);
    constituencyMetadata.update("timeSlot_$timeSlot", (value) => value + 1, ifAbsent: () => 1);
    constituencyMetadata.update("constituencyTotalVotes", (value) => value + 1, ifAbsent: () => 1);

    // Update Firestore with the corrected nested structure
    await resultDoc.set({
      "Metadata": {
        userConstituency: constituencyMetadata
      }
    }, SetOptions(merge: true));
  }
  String calculateAgeGroup(DateTime birthDate) {
    DateTime now = DateTime.now();

    // If the birthDate is in the future, consider it invalid.
    if (birthDate.isAfter(now)) { return "invalid"; }

    // Calculate age
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    // Ensure age is non-negative
    if (age < 0) age = 0;

    // Determine age group precisely.
    // if (age >= 18 && age <= 25) return "teenager";
    // if (age >= 26 && age <= 40) return "yuva";
    if (age >= 18 && age <= 40) return "yuva";
    if (age >= 41 && age <= 60) return "Adult";
    return "senior citizen";               // 55 and above
  }
  Future<void> updateCitizenElectionRecord(String electionYear) async
  {
    DocumentReference citizenDoc = _firestore
        .collection("Vote Chain/State/${widget.state}/Citizen/Citizen")
        .doc(widget.userEmail);

    DocumentSnapshot doc = await citizenDoc.get();
    Map<String, dynamic> citizenData = doc.data() as Map<String, dynamic>;

    // Determine the election field, counter, and constituency key based on election type.
    String electionField = "";
    String counterField = "";
    String constituencyKey = "";

    if
    (widget.electionId == "State Assembly (Vidhan Sabha)") {
      electionField = 'vidhanSabha';
      counterField = 'totalVidhanSabhaVotes';
      constituencyKey = 'vidhanSabhaConstituency';
    }
    else if
    (widget.electionId == "General (Lok Sabha)") {
      electionField = 'locSabha';
      counterField = 'totalLocSabhaVotes';
      constituencyKey = 'locSabhaConstituency';
    }
    else if
    (widget.electionId.contains("Municipal")) {
      electionField = 'municipal';
      counterField = 'totalMunicipalVotes';
      constituencyKey = 'municipalConstituency';
    }
    else if
    (widget.electionId.contains("Panchayat")) {
      electionField = 'Panchayat';
      counterField = 'totalPanchayatVotes';
      constituencyKey = 'panchayatConstituency';
    }

    // // Instead of using the static constituency name, fetch the live location.
    // String liveLocation = await _getCurrentLocation();

    // Create the vote record to store.
    Map<String, dynamic> voteRecord = {
      'voteTimestamp': Timestamp.now(),
      'day': DateFormat('EEEE').format(DateTime.now()),
      'date': DateFormat('dd').format(DateTime.now()),
      'month': DateFormat('MMMM').format(DateTime.now()),
      'year': electionYear,
      'time': DateFormat('HH:mm').format(DateTime.now()),
      // 'location': citizenData[constituencyKey] ?? '',
      // 'location': liveLocation, // Use live location here.
    };

    // Build the field path for the sub-map (e.g., "electionData.vidhanSabha.2023")
    String fieldPath = "electionData.$electionField.$electionYear";

    // Update the citizen document.
    await citizenDoc.update({
      'totalVotes': FieldValue.increment(1),
      counterField: FieldValue.increment(1),
      fieldPath: voteRecord,
    });
  }

  /// Location Scene 1 - basic
  // Future<String> _getCurrentLocation() async {
  //   // Request permissions if not granted yet.
  //   LocationPermission permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied ||
  //       permission == LocationPermission.deniedForever) {
  //     permission = await Geolocator.requestPermission();
  //   }
  //
  //   // Get current position.
  //   Position position = await Geolocator.getCurrentPosition(
  //     desiredAccuracy: LocationAccuracy.high,
  //   );
  //
  //   // Reverse geocode to get human-readable address.
  //   List<Placemark> placemarks = await placemarkFromCoordinates(
  //     position.latitude,
  //     position.longitude,
  //   );
  //   Placemark place = placemarks.first;
  //
  //   // Build a detailed address string using available fields.
  //   String address = "";
  //   if (place.name?.isNotEmpty ?? false) {
  //     address += "${place.name}, ";
  //   }
  //   if (place.thoroughfare?.isNotEmpty ?? false) {
  //     address += "${place.thoroughfare}, ";
  //   }
  //   if (place.subLocality?.isNotEmpty ?? false) {
  //     address += "${place.subLocality}, ";
  //   }
  //   if (place.locality?.isNotEmpty ?? false) {
  //     address += "${place.locality}, ";
  //   }
  //   if (place.administrativeArea?.isNotEmpty ?? false) {
  //     address += "${place.administrativeArea}, ";
  //   }
  //   if (place.country?.isNotEmpty ?? false) {
  //     address += "${place.country}, ";
  //   }
  //   if (place.postalCode?.isNotEmpty ?? false) {
  //     address += "${place.postalCode}";
  //   }
  //
  //   // Clean up the address by removing any trailing comma and space.
  //   address = address.trim();
  //   if (address.endsWith(",")) {
  //     address = address.substring(0, address.length - 1).trim();
  //   }
  //
  //   // Append latitude and longitude with fixed decimal precision.
  //   String coordinates = "(${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)})";
  //
  //   // Return the combined detailed location.
  //   return "$address $coordinates";
  // }
  /// Location Scene 2 - due to this voting data is not storing in citizens' profile
  // Future<String> _getCurrentLocation() async {
  //   // Create an instance of the location package using the alias.
  //   loc.Location location = loc.Location();
  //
  //   // Check if location services are enabled.
  //   bool serviceEnabled = await location.serviceEnabled();
  //   if (!serviceEnabled) {
  //     serviceEnabled = await location.requestService();
  //     if (!serviceEnabled) {
  //       throw Exception("Location services are disabled.");
  //     }
  //   }
  //
  //   // Check for location permissions.
  //   loc.PermissionStatus permissionGranted = await location.hasPermission();
  //   if (permissionGranted == loc.PermissionStatus.denied ||
  //       permissionGranted == loc.PermissionStatus.deniedForever) {
  //     permissionGranted = await location.requestPermission();
  //     if (permissionGranted != loc.PermissionStatus.granted) {
  //       throw Exception("Location permissions are denied.");
  //     }
  //   }
  //
  //   // Get current location.
  //   loc.LocationData locationData = await location.getLocation();
  //
  //   // Reverse geocode to get a human-readable address.
  //   List<Placemark> placemarks = await placemarkFromCoordinates(
  //     locationData.latitude!,
  //     locationData.longitude!,
  //   );
  //   Placemark place = placemarks.first;
  //
  //   // Build a detailed address string using available fields.
  //   String address = "";
  //   if (place.name?.isNotEmpty ?? false) {
  //     address += "${place.name}, ";
  //   }
  //   if (place.thoroughfare?.isNotEmpty ?? false) {
  //     address += "${place.thoroughfare}, ";
  //   }
  //   if (place.subLocality?.isNotEmpty ?? false) {
  //     address += "${place.subLocality}, ";
  //   }
  //   if (place.locality?.isNotEmpty ?? false) {
  //     address += "${place.locality}, ";
  //   }
  //   if (place.administrativeArea?.isNotEmpty ?? false) {
  //     address += "${place.administrativeArea}, ";
  //   }
  //   if (place.country?.isNotEmpty ?? false) {
  //     address += "${place.country}, ";
  //   }
  //   if (place.postalCode?.isNotEmpty ?? false) {
  //     address += "${place.postalCode}";
  //   }
  //
  //   // Clean up the address by removing any trailing comma and space.
  //   address = address.trim();
  //   if (address.endsWith(",")) {
  //     address = address.substring(0, address.length - 1).trim();
  //   }
  //
  //   // Append latitude and longitude with fixed decimal precision.
  //   String coordinates = "(${locationData.latitude!.toStringAsFixed(6)}, ${locationData.longitude!.toStringAsFixed(6)})";
  //
  //   return "$address $coordinates";
  // }

  void _showSuccessMessage() {
    Navigator.pop(context);
    /// original
    // Dismiss the loading animation.

    // //Show a dialog with a success icon.
    // showDialog(
    //   context: context,
    //   barrierDismissible: false,
    //   barrierColor: Color(0xFFFCFDFD), //  0xFFCFEEE4
    //   builder: (context) => AlertDialog(
    //     title: Text("Vote Successful !"),
    //     content: Icon(Icons.check_circle, color: Colors.green, size: 80),
    //   ),
    // );
    // // After 5 seconds, dismiss the dialog and navigate to the EligibleElections screen.
    // Future.delayed(Duration(seconds: 5), () {
    //   Navigator.pop(context); // Dismiss the success dialog.
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(
    //       builder: (context) => EligibleElections(
    //         state: widget.state,
    //         email: widget.userEmail,
    //       ),
    //     ),
    //   );
    // });
    /// improved
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Color(0xFFFCFDFD), //  0xFFCFEEE4
      // barrierColor: Colors.black.withOpacity(0.5), // Dim background for better focus
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Smooth rounded corners
        ),
        child: Container(
          width: MediaQuery.of(context).size.width, // * 0.85, // 85% of screen width
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10), // Adjust padding
          decoration: BoxDecoration(
            // color: Colors.yellow,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15), // Rounded corners for image
                child: Image.asset(
                  'assets/images/vote_counted.jpg',
                  width: 400, // Bigger width
                  height: 220, // Maintain aspect ratio
                  fit: BoxFit.cover, // Ensures full image display
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Vote Successful!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Your vote has been recorded successfully.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog first
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                        //     EligibleElections(
                        //       state: widget.state,
                        //       email: widget.userEmail,
                        //     ),
                        LoginScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    "OK",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Candidates in $userConstituency",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 5,
        backgroundColor: AppConstants.primaryColor,
      ),
      body: _candidates.isEmpty
          ? Center(child: CircularProgressIndicator()) // Loading indicator until candidates are fetched
          : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: ListView.builder(
            itemCount: _candidates.length + 1, // +1 for the NOTA option
            itemBuilder: (context, index)
            {
              if (index < _candidates.length)
              {
                var candidate = _candidates[index]; // Get each candidate from list
                /// original
                // return Card(
                //   elevation: 10,
                //   margin: EdgeInsets.symmetric(vertical: 12),
                //   shape: RoundedRectangleBorder(
                //     borderRadius: BorderRadius.circular(15),
                //   ),
                //   color: Colors.white,
                //   child: Padding(
                //     padding: const EdgeInsets.all(16.0),
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         // Row for Party Logo (Left) and Vote Button (Right)
                //         Row(
                //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //           children: [
                //             // Party logo
                //             Container(
                //               width: 80, // Logo size
                //               height: 80,
                //               decoration: BoxDecoration(
                //                 image: DecorationImage(
                //                   image: AssetImage('assets/images/default_party_logo.png'),
                //                   fit: BoxFit.cover,
                //                 ),
                //                 borderRadius: BorderRadius.circular(12),
                //               ),
                //             ),
                //             // Vote button
                //             ElevatedButton(
                //               onPressed: () => _voteForCandidate(candidate['email']),
                //               style: ElevatedButton.styleFrom(
                //                 backgroundColor: AppConstants.primaryColor,
                //                 foregroundColor: Colors.white, // Text color
                //                 shape: RoundedRectangleBorder(
                //                   borderRadius: BorderRadius.circular(20),
                //                 ),
                //                 padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                //                 elevation: 6,
                //               ),
                //               child: Text(
                //                 "Vote",
                //                 style: TextStyle(fontSize: 16),
                //               ),
                //             ),
                //           ],
                //         ),
                //         SizedBox(height: 10), // Space between logo & vote button and details
                //         // Party and candidate name
                //         Text(
                //           "Party: ${candidate['party']}",
                //           style: TextStyle(
                //             fontWeight: FontWeight.bold,
                //             fontSize: 18,
                //             color: Colors.black87,
                //           ),
                //           overflow: TextOverflow.ellipsis,
                //         ),
                //         SizedBox(height: 6),
                //         Text(
                //           "Candidate: ${candidate['name']}",
                //           style: TextStyle(
                //             fontSize: 16,
                //             color: Colors.black87,
                //           ),
                //           overflow: TextOverflow.ellipsis,
                //         ),
                //         SizedBox(height: 8), // Space between name and email
                //         // Candidate email
                //         Text(
                //           "📧 Email: ${candidate['email']}",
                //           style: TextStyle(fontSize: 14, color: Colors.black54),
                //         ),
                //         Divider(),
                //         Text("📅 Age: ${candidate['age']}", style: TextStyle(fontSize: 14)),
                //         Text("⚧ Gender: ${candidate['gender']}", style: TextStyle(fontSize: 14)),
                //         Text("🎓 Education: ${candidate['education']}", style: TextStyle(fontSize: 14)),
                //         Text("💼 Profession: ${candidate['profession']}", style: TextStyle(fontSize: 14)),
                //         Text("🏠 Home State: ${candidate['home_state']}", style: TextStyle(fontSize: 14)),
                //       ],
                //     ),
                //   ),
                // );
                /// trying to improve
                return Card(
                elevation: 8,
                margin: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                // 14
                color: Colors.white,
                // Glassmorphism effect
                // color: Colors.teal, // Glassmorphism effect
                shadowColor: Colors.black.withOpacity(0.3),
                // shadow at border of card
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      // colors: [Colors.teal, Colors.grey.shade100],
                      colors: [Colors.teal.shade300, Colors.white],
                      // colors: [Color(0xFF5ACCC3), Colors.grey.shade100],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        // Softer, premium shadow
                        blurRadius: 14,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    // borderRadius: BorderRadius.circular(20),   // overlapping card on main card
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Party Logo & Vote Button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Party Logo
                              Container(
                                width: 75,
                                height: 75,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(candidate['logo'] ??
                                        'assets/images/default_party_logo.png'),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.white54, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: Offset(0, 5),
                                    )
                                  ],
                                ),
                              ),

                              // Vote Button with Animation
                              ElevatedButton(
                                // // onPressed: () => _showSuccessMessage(),  // for testing, this line of code is here
                                // onPressed: () => _authenticateAndVote(candidate['email']),

                                /// ////////////////////  ////////////////  //////////////    IIIIIIIIIIII   MMMMMMMMMMMMMMM   PPPPPPPPPPPPPPPPP  -------->
                                /*
                                   All code which executes after Vote button is clicked, is moved to "vote_candidate.dart" file
                                   which appears as a new screen on candidate list instead of just white colored layer in between authentication (by whcih snackbar messages get hide.)
                                */
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VoteCandidate(
                                        state: widget.state,
                                        userConstituency: userConstituency,
                                        userEmail: widget.userEmail,
                                        electionType: widget.electionType,
                                        electionId: widget.electionId,
                                        candidateEmail: candidate['email'],
                                      ),
                                    ),
                                  );
                                },

                                  style: ElevatedButton.styleFrom(
                                  // backgroundColor: Colors.blueAccent,
                                  backgroundColor: Colors.teal,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 36, vertical: 14),
                                  elevation: 8,
                                  shadowColor: Colors.blueAccent.withOpacity(
                                      0.4),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.how_to_vote, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      "Vote",
                                      style: TextStyle(fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 25), // Spacing

                          // Candidate & Party Name
                          Text(
                            "Party: ${candidate['party']}",
                            style: TextStyle(fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Candidate: ${candidate['name']}",
                            style: TextStyle(fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Colors.black),
                          ),

                          SizedBox(height: 10),

                          Divider(
                            height: 10,
                            // color: Colors.black.shade300,  // Set the color to black with shade 300 (lighter)
                            color: Colors.black.withOpacity(
                                0.5), // Softer, premium shadow
                          ),

                          // Candidate Details with Icons
                          _buildDetailRow(
                              Icons.email, "Email: ${candidate['email']}"),
                          _buildDetailRow(
                              Icons.calendar_today, "Age: ${candidate['age']}"),
                          _buildDetailRow(
                              Icons.person, "Gender: ${candidate['gender']}"),
                          _buildDetailRow(Icons.school,
                              "Education: ${candidate['education']}"),
                          _buildDetailRow(Icons.work,
                              "Profession: ${candidate['profession']}"),
                          _buildDetailRow(Icons.location_on,
                              "Home State: ${candidate['home_state']}"),
                        ],
                      ),
                    ),
                  ),
                ),
              );
              }
              else
              {
                // Build the NOTA option card.
                return Card(
                  elevation: 8,
                  margin: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  color: Colors.white,
                  shadowColor: Colors.black.withOpacity(0.3),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red.shade300, Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 14,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Icon(Icons.not_interested, size: 60, color: Colors.redAccent),
                            SizedBox(height: 20),
                            Text(
                              "NOTA",
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "None Of The Above",
                              style: TextStyle(fontSize: 17, color: Colors.black54),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              // onPressed: () => _authenticateAndVote("NOTA"),

                              /// ////////////////////  ////////////////  //////////////    IIIIIIIIIIII   MMMMMMMMMMMMMMM   PPPPPPPPPPPPPPPPP  -------->
                              /*
                                   All code which executes after Vote button is clicked, is moved to "vote_candidate.dart" file
                                   which appears as a new screen on candidate list instead of just white colored layer in between authentication (by whcih snackbar messages get hide.)
                              */
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VoteCandidate(
                                      state: widget.state,
                                      userConstituency: userConstituency,
                                      userEmail: widget.userEmail,
                                      electionType: widget.electionType,
                                      electionId: widget.electionId,
                                      candidateEmail: "NOTA",
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                padding: EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                                elevation: 8,
                                shadowColor: Colors.redAccent.withOpacity(0.4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.how_to_vote, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    "Vote NOTA",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ),
    );
  } //
}
