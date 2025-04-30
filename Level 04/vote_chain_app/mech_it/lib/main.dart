import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'SERVICE/screen/onboarding.dart';
import 'SERVICE/screen/login.dart';
import 'SERVICE/screen/register.dart';


import 'USER/admin/Profile_admin_.dart';
import 'USER/citizen/citizen_home.dart';
import 'USER/citizen/current_previous_elections.dart';
import 'USER/citizen/eligible_elections.dart';
import 'USER/citizen/reports.dart';


import 'USER/party/Profile_party.dart';
import 'USER/party/Apply_Approval_Dashboard_party_application.dart';
import 'USER/party/Home_party_head.dart';
import 'USER/party/Review_View_Dashboard_candidate_applications.dart';


import 'USER/candidate/candidate_home.dart';


import 'USER/admin/Home_Profile_admin.dart';
import 'USER/admin/Dashboard_admin.dart';
import 'USER/admin/Manage_party_application.dart';
import 'USER/admin/Manage_election.dart';
import 'USER/admin/Report_election.dart';
import 'USER/admin/Results_election.dart';

import 'USER/guest/GuestHome.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(); // Initialize Firebase
  await Firebase.initializeApp(
    options: FirebaseOptions(

      /// Replace with your firebase project details...

        apiKey: '00000000000000000000',  // From your config
        authDomain: '00000000000000',            // This should be retrieved from Firebase Console
        projectId: '0000000000',
        storageBucket: '00000000000',
        messagingSenderId: '00000000000000',               // Should be available in your Firebase Console
        appId: '000000000000000000000000000000000', // Should be available in your Firebase Console
        // measurementId: 'G-XXXXXXX'                        // Should be available in your Firebase Console
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vote Chain',
      debugShowCheckedModeBanner: false, // Disable debug banner
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      // theme: ThemeData(
      //   useMaterial3: true,
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      //   textTheme: TextTheme(
      //     displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      //     bodyLarge: TextStyle(fontSize: 16),
      //   ),
      // ),

      initialRoute: '/Login', // Change to /Onboarding for first launch
      routes: {
        '/Onboarding': (context) => Onboarding(), // Add OnboardingScreen route
        '/Login': (context) => LoginScreen(),
        '/Register': (context) => RegisterScreen(),


        // '/CitizenHome': (context) => CitizenHome(),
        '/CurrentPreviousElections': (context) => CurrentPreviousElections(),
        // '/EligibleElections': (context) => EligibleElections(),
        '/Reports': (context) => Reports(),


        // '/PartyHeadHome': (context) => PartyHeadHome(),
        // '/PartyProfile': (context) => PartyProfile(stateName: '', partyName: '',),
        // '/PartyApplicationForElection': (context) => PartyApplicationForElection(partyName: '',),
        // '/ReviewCandidateApplication': (context) => ReviewCandidateApplication(partyName: '',),


        // '/CandidateHome': (context) => CandidateHome(),


        // '/AdminHome': (context) => AdminHome(),
        // '/AdminProfile': (context) => AdminProfile(),
        '/AdminDashboard': (context) => AdminDashboard(),
        '/ManagePartyApplication': (context) => ManagePartyApplication(),
        '/ManageElection': (context) => ManageElection(),
        '/ElectionResult': (context) => ElectionResult(),
        '/ReportDetails': (context) => ReportDetails(),


        '/GuestHome': (context) => GuestHome(),  // Define your Guest Home screen here

        // Add routes for adminDashboard and home as needed
      },
    );
  }
}

