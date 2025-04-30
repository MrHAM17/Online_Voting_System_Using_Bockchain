
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

import '../../Future Apply[ (reg) & no login ]/login.dart';
import '../../SERVICE/backend_connectivity/smart_contract_service.dart';
import '../../SERVICE/utils/app_constants.dart';
import '../admin/election_details.dart';
import 'eligible_elections.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';


class VoteCandidate extends StatefulWidget {
  final String state;
  final String? userConstituency;
  final String userEmail;
  final String electionType;
  final String electionId;
  final String candidateEmail;
  // final String electionPath;

  const VoteCandidate({ required this.electionId, required this.state, required this.userEmail, /*required this.electionPath,*/ required this.electionType,  required this.userConstituency,  required this.candidateEmail });

  @override
  _VoteCandidateState createState() => _VoteCandidateState();
}

class _VoteCandidateState extends State<VoteCandidate> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // String? userConstituency;  // we cannot use this as we getting this from previous screen already as an argument
  String Default_otpCode = "211371";  // ✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅ Global OTP variable
  bool _isLoggingOut = false; // Add this flag

  @override
  void initState() {
    super.initState();
    initializeNotifications();
    _authenticateAndVote(widget.candidateEmail) ;
  }

  @override
  /// works good --> But not cover one of edge case --> while auto-logout if back button clicked quickly before auto-logout then it stops auto-logout process.
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text(
  //         "Voting with VoteChain",
  //         style: TextStyle(
  //           fontWeight: FontWeight.bold,
  //           fontSize: 20,
  //           color: Colors.white,
  //         ),
  //       ),
  //       centerTitle: true,
  //       elevation: 5,
  //       backgroundColor: AppConstants.primaryColor,
  //       automaticallyImplyLeading: false,
  //     ),
  //     // body: Center(
  //     //   child: ElevatedButton(
  //     //     onPressed: () => _authenticateAndVote(widget.candidateEmail),
  //     //     child: Text("Proceed to Vote"),
  //     //   ),
  //     // ),
  //   );
  // }
  /// covers above edge case....
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Block back button if logout is in progress
        if (_isLoggingOut) return false;
        return true; // Allow back navigation otherwise
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Voting with VoteChain",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          elevation: 5,
          backgroundColor: AppConstants.primaryColor,
          automaticallyImplyLeading: false,
        ),
        // body: Center(
        //   child: ElevatedButton(
        //     onPressed: () => _authenticateAndVote(widget.candidateEmail),
        //     child: Text("Proceed to Vote"),
        //   ),
        // ),
      ),
    );
  }


  /// /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  void initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  // Function to show OTP notification
  Future<void> showOTPNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'vote_chain_otp',                  // Channel ID
      'Vote Chain OTP',                  // Channel name
      channelDescription: 'OTP Notification',  // Channel description
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    // ✅ Show the OTP notification
    await flutterLocalNotificationsPlugin.show(
      0,                      // Notification ID
      'Your OTP for Voting',   // Title
      '$Default_otpCode (valid for 2 min)',  // Body with OTP
      platformChannelSpecifics,
    );

    // ✅ Auto-remove notification after 2 minutes
    const otpValidityDuration = Duration(minutes: 2);
    Timer(otpValidityDuration, () async {
      if (mounted) {
        await flutterLocalNotificationsPlugin.cancel(0);  // Remove the notification
        print("OTP notification cleared!");  // For debugging
      }
    });
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

    // // Check if the citizen is underage.
    if (await _isUnderage()) {
      setState(() => _isLoggingOut = true); // Block back button
      SnackbarUtils.showErrorMessage(context, "You must be at least 18 years old to vote.\nSo will be auto logged out in 3 second.");
      // Auto logout after 5 seconds
      Future.delayed(Duration(seconds: 3), () {
        if (context.mounted) {
          Navigator.pop(context); // Close current dialog or screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),  // Redirect to login
          );
        }
      });
      return;
    }

    // // First, check if the citizen has already voted for this election.
    if (await _hasAlreadyVoted(electionYear)) {
      setState(() => _isLoggingOut = true); // Block back button
      SnackbarUtils.showErrorMessage(context, "You have already voted in this election.\nSo will be auto logged out in 3 second.");
      // Auto logout after 5 seconds
      Future.delayed(Duration(seconds: 3), () {
        if (context.mounted) {
          Navigator.pop(context); // Close current dialog or screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),  // Redirect to login
          );
        }
      });

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


    // Auto_Focus Step 1 -  Add FocusNodes for automatic cursor focus
    FocusNode passwordFocusNode = FocusNode();
    List<FocusNode> otpFocusNodes = List.generate(6, (index) => FocusNode());

    await showDialog(
      context: context,
      barrierDismissible: false,  // Prevents closing on outside tap
      /// Now we dont need bg colored layer (below 1 line) to hide selected candidate for vote, Because now actual screen is in between on which authentication is happening.
      // barrierColor: Color(0xFFFCFDFD),

      /// works well but not cover the one of edge case (by clicking on mobile's back button boxes disappear & by one more click user navigates to candidate list screen --> which reveals user is voting to whom)
      // builder: (context) => StatefulBuilder(
      ///   // "WillPopScope" 👈 Prevents back navigation using the Android back button
      builder: (context) => WillPopScope(
        onWillPop: () async => false,       // 👈 Back button is disabled
        child: StatefulBuilder(
          builder: (context, setState) {

            // Auto_Focus Step 2 - Automatically focus the correct field when dialog opens
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!showOTPField) {
                passwordFocusNode.requestFocus();
              } else {
                otpFocusNodes[0].requestFocus();  // Focus first OTP box
              }
            });

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
                          focusNode: passwordFocusNode,   // Auto_Focus Step 3 - Auto-focus on password field
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
                          Wrap(                    // 👈 Automatically wraps to new line if overflow occurs
                            spacing: 7.0,          // Horizontal space between boxes
                            runSpacing: 12.0,      // Vertical space if wrapped
                            alignment: WrapAlignment.center,
                            children: List.generate(6, (index) {
                               return SizedBox(
                                  width: 37,               // Fixed width
                                  height: 50,              // Proportionate height
                                  child: TextField(
                                    controller: otpController[index],
                                    focusNode: otpFocusNodes[index],  // Auto_Focus Step 4 - Auto-focus on OTP fields
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    maxLength: 1,

                                    // // Hides OTP characters by masking them with dots
                                    // obscureText: true,
                                    // obscuringCharacter: '•',

                                    decoration: InputDecoration(
                                      counterText: "",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),  // Rounded borders
                                      ),
                                    ),
                                    onChanged: (value) {
                                      if (value.isNotEmpty)
                                      {
                                        // // if (value.isNotEmpty && index < 5) {  FocusScope.of(context).nextFocus();  }    // Moves focus forward
                                        if (index < 5) {  FocusScope.of(context).nextFocus();  }               // Only move focus if NOT on the last box
                                        else if (index == 5) {
                                          /// not worked as cursor goes to 1st box when 6th digit is entered.
                                          // // Prevent jumping back on the last box
                                          // Future.delayed(Duration(milliseconds: 10), () {
                                          //   otpFocusNodes[index].unfocus();
                                          // });
                                          /// Explicitly clear focus after the last digit is entered
                                          if (otpFocusNodes[index].hasFocus) { otpFocusNodes[index].unfocus(); }
                                          otpFocusNodes[index].unfocus();   // Clear focus after last digit is entered
                                        }
                                        // Handle backspace correctly
                                        else if (value.isEmpty) {
                                          if (index > 0) {
                                            otpController[index].clear();
                                            FocusScope.of(context).previousFocus();  // Move back on delete
                                          }
                                        }

                                        if (otpController.every((c) => c.text.isNotEmpty)) { setState(() {});  } // Hide OTP field when fully entered
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
                            /// keeps user there
                            // onPressed: () => Navigator.pop(context),
                            /// adds delay then logged out.
                            // onPressed: () {
                            //   Navigator.pop(context); // Close dialog first
                            //
                            //   Future.delayed(Duration(seconds: 3), () {
                            //     Navigator.pushReplacement(
                            //       context,
                            //       MaterialPageRoute(
                            //         builder: (context) =>
                            //         //     EligibleElections(
                            //         //       state: widget.state,
                            //         //       email: widget.userEmail,
                            //         //     ),
                            //         LoginScreen(), // Change this to your desired screen
                            //       ),
                            //     );
                            //   });
                            // },
                            /// ask, confirms then logged out without delay (because it creates issues to logged out as context lost in delayed time)
                            onPressed: () async {
                              bool? confirmLogout = await showDialog(
                                context: context,
                                // barrierDismissible: false,  // Prevents closing on outside tap
                                builder: (context) => AlertDialog(
                                  title: Text("Confirm Cancellation"),
                                  content: Text("By canceling, you will be completely logged out."),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false), // Stay in the dialog
                                      child: Text("No"),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true), // Confirm logout
                                      child: Text("Yes"),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmLogout == true) {
                                Navigator.pop(context); // Close main dialog
                                 Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                      //     EligibleElections(
                                      //         //       state: widget.state,
                                      //         //       email: widget.userEmail,
                                      //         //     ),
                                      LoginScreen(), // Redirect to login
                                    ),
                                  );
                              }
                            },
                            child: Text("Cancel"),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              if (!showOTPField)
                              {
                                if (enteredPassword.isEmpty) {  SnackbarUtils.showErrorMessage(context, "Password cannot be empty");   }

                                if (await _verifyPassword(enteredPassword))
                                {
                                  // ✅ Trigger Real OTP Notification
                                  await showOTPNotification();

                                  // ✅ Switch to OTP Field
                                  setState(() => showOTPField = true);
                                } else {  SnackbarUtils.showErrorMessage(context, "Invalid Password"); }
                              }
                              else
                              {
                                enteredOTP = otpController.map((c) => c.text).join();

                                if (enteredOTP.length < 6) {
                                  SnackbarUtils.showErrorMessage(context, "OTP cannot be empty");
                                }

                                if (enteredOTP == Default_otpCode) {
                                  Navigator.pop(context);
                                  _confirmVote(candidateEmail);
                                } else {
                                  SnackbarUtils.showErrorMessage(context, "Invalid OTP");
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
      ),
    );
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
    FocusNode privateKeyFocusNode = FocusNode();  // Add focus node

    // Automatically focus the private key field when dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      privateKeyFocusNode.requestFocus();
    });

    showDialog(
      context: context,
      barrierDismissible: false,  // Prevents closing on outside tap
      /// Now we dont need bg colored layer (below 1 line) to hide selected candidate for vote, Because now actual screen is in between on which authentication is happening.
      // barrierColor: Color(0xFFFCFDFD),

      //   builder: (context) => AlertDialog (.......),    // code before auto focus,
      //
      // builder: (context) {........},    // code before WillPopScope
      //
        builder: (context) => WillPopScope(      // 👈 Prevent back navigation
          onWillPop: () async => false,          // 👈 Disable back button

          // return AlertDialog(.....) ;    // code before WillPopScope
          child: AlertDialog(
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
                    focusNode: privateKeyFocusNode,   // Auto-focus here
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
                    /// keeps user there
                    // onPressed: () => Navigator.pop(context),
                    /// adds delay then logged out.
                    // onPressed: () {
                    //   Navigator.pop(context); // Close dialog first
                    //   Future.delayed(Duration(seconds: 3), () {
                    //     Navigator.pushReplacement(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) =>
                    //         //     EligibleElections(
                    //         //       state: widget.state,
                    //         //       email: widget.userEmail,
                    //         //     ),
                    //         LoginScreen(), // Change this to your desired screen
                    //       ),
                    //     );
                    //   });
                    // },
                    /// ask, confirms then logged out without delay (because it creates issues to logged out as context lost in delayed time)
                    onPressed: () async {
                      bool? confirmLogout = await showDialog(
                        context: context,
                        // barrierDismissible: false,  // Prevents closing on outside tap
                        builder: (context) => AlertDialog(
                          title: Text("Confirm Cancellation"),
                          content: Text("By canceling, you will be completely logged out."),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false), // Stay in the dialog
                              child: Text("No"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true), // Confirm logout
                              child: Text("Yes"),
                            ),
                          ],
                        ),
                      );

                      if (confirmLogout == true) {
                        Navigator.pop(context); // Close main dialog
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              //     EligibleElections(
                              //         //       state: widget.state,
                              //         //       email: widget.userEmail,
                              //         //     ),
                              LoginScreen(), // Redirect to login
                            ),
                          );
                      }
                    },
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
       ),
    );
  }
  Future<void> _submitVote(String candidateEmail) async {
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
          SnackbarUtils.showErrorMessage(context, "Voting Failed..\nError:\n$e");
          SnackbarUtils.showErrorMessage(context, "You will be auto logged out in 3 seconds.");

          print("Error in vote function: $e");

          // Auto logout after 3 seconds
          Future.delayed(Duration(seconds: 3), () {
            if (context.mounted) {
              Navigator.pop(context); // Close current dialog or screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),  // Redirect to login
              );
            }
          });

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
      SnackbarUtils.showErrorMessage(context, "Voting failed.. Something went wrong.\nError:\n$e");
      SnackbarUtils.showErrorMessage(context, "You will be auto logged out in 3 seconds.");
      print("Error during vote submission: $e");

      // Auto logout after 5 seconds
      Future.delayed(Duration(seconds: 3), () {
        if (context.mounted) {
          Navigator.pop(context); // Close current dialog or screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),  // Redirect to login
          );
        }
      });


    }
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
    // Map<String, dynamic> constituencyMetadata = existingMetadata[userConstituency] ?? {};
    Map<String, dynamic> constituencyMetadata = existingMetadata[widget.userConstituency] ?? {};

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
        // userConstituency: constituencyMetadata
        widget.userConstituency: constituencyMetadata
      }
    }, SetOptions(merge: true));
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
}


