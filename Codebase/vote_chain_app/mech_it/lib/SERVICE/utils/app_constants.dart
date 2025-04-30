import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../USER/admin/election_details.dart';
import '../screen/styled_widget.dart';

class AppConstants {

  // Color Constants
  static const Color primarySwatch = Colors.blue;

  static const Color primaryColor = Colors.teal;
  static const Color secondaryColor = Colors.grey;
  static const Color appBarColor = Colors.teal;
  static const Color selectedItemColor = Colors.teal;
  static const Color unselectedItemColor = Colors.grey;

  static const Color cardStartColor = Color(0xFF4DB6AC); // Light Teal
  static const Color cardEndColor = Color(0xFF00796B); // Darker Teal



  // Make these lists static

  /// ***************  *************    *****     ***************  *************    *****     Profile-related constants   ***************  *************    *****     ***************  *************    *****
  /// ***************  *************    *****     ***************  *************    *****     Profile-related constants   ***************  *************    *****     ***************  *************    *****
  static const List<String> genders = [
    'Male',
    'Female',
    'Other'
  ];
  static const List<String> educationLevels = [
    'No Formal Education',
    'Primary',
    'Secondary',
    'Higher Secondary',
    'Graduate',
    'Postgraduate',
    'Doctorate'
  ];
  static const List<String> employmentStatuses = [
    'Government Employee',
    'Private Sector Employee',
    'Self-Employed',
    'Retired',
    'Unemployed',
    'Other'
  ];

  static const List<String> incomeLevels = [
    'Up to ₹4,00,000',
    '₹4,00,001 – ₹8,00,000',
    '₹8,00,001 – ₹12,00,000',
    '₹12,00,001 – ₹16,00,000',
    '₹16,00,001 – ₹20,00,000',
    '₹20,00,001 – ₹24,00,000',
    'Above ₹24,00,000'
  ];
  static const List<String> residenceTypes = [
    'Urban',
    'Semi-Urban',
    'Rural',
    'Town'
  ];
  static const List<String> disabilityStatuses = ['None', 'Visual Impairment', 'Hearing Impairment', 'Physical Disability'];
  static const List<String> voterCategories = [
    'Normal Citizen',
    'On-Duty Personnel',
    'Non-Resident Indian (NRI)',
  ];

  /// Returns the current year as a selected year.
  static String getCurrentYear() {
    return DateTime.now().year.toString();
  }
  // static String getCurrentYear() {
  //   return "2024";
  // }


  /// ***************  *************    *****     ***************  *************    *****     Election-related constants   ***************  *************    *****     ***************  *************    *****
  /// ***************  *************    *****     ***************  *************    *****     Election-related constants   ***************  *************    *****     ***************  *************    *****
  static const List<String> electionYear = [
    // "1951", "1952", "1953", "1954", "1955", "1956", "1957", "1958", "1959", "1960",
    // "1961", "1962", "1963", "1964", "1965", "1966", "1967", "1968", "1969", "1970",
    // "1971", "1972", "1973", "1974", "1975", "1976", "1977", "1978", "1979", "1980",
    // "1981", "1982", "1983", "1984", "1985", "1986", "1987", "1988", "1989", "1990",
    // "1991", "1992", "1993", "1994", "1995", "1996", "1997", "1998", "1999", "2000",
    // "2001", "2002", "2003", "2004", "2005", "2006", "2007", "2008", "2009", "2010",
    // "2011", "2012", "2013", "2014", "2015", "2016", "2017", "2018", "2019", "2020",
    "2021", "2022", "2023", "2024", "2025", "2026", "2027"
  ];
  static const List<String> electionTypes = [
    "Panchayat",
    "Municipal",
    "State Assembly (Vidhan Sabha)",
    "Legislary Council (Vidhan Parishad)",
    "General (Lok Sabha)",
    "Council of States (Rajya Sabha)",
    "Presidential",
    "Vice-Presidential",
    "By-elections",
    "Referendum",
    "Confidence Motion (Floor Test)",
    "No Confidence Motion"
  ];
  static const List<String> electionTypesForPartyHead = [
    "Panchayat",
    "Municipal",
    "State Assembly (Vidhan Sabha)",
    "Legislary Council (Vidhan Parishad)",
    "General (Lok Sabha)",
    "Council of States (Rajya Sabha)",
    "By-elections",
    "Referendum",
    "Confidence Motion (Floor Test)",
    "No Confidence Motion"
  ];
  static const List<String> electionTypesForCandidate = [
    "Presidential",
    "Vice-Presidential",
    "General (Lok Sabha)",
    "Council of States (Rajya Sabha)",
    "State Assembly (Vidhan Sabha)",
    "Legislary Council (Vidhan Parishad)",
    "Municipal",
    "Panchayat",
    "By-elections",
  ];
  static const List<String> statesAndUT = [
    "Andaman and Nicobar Islands",
    "Andhra Pradesh",
    "Arunachal Pradesh",
    "Assam",
    "Bihar",
    "Chhattisgarh",
    "Goa",
    "Gujarat",
    "Haryana",
    "Himachal Pradesh",
    "Jharkhand",
    "Karnataka",
    "Kerala",
    "Madhya Pradesh",
    "Maharashtra",
    "Manipur",
    "Meghalaya",
    "Mizoram",
    "Nagaland",
    "Odisha",
    "Punjab",
    "Rajasthan",
    "Sikkim",
    "Tamil Nadu",
    "Telangana",
    "Tripura",
    "Uttar Pradesh",
    "Uttarakhand",
    "West Bengal",
    "Chandigarh",
    "Dadra and Nagar Haveli and Daman and Diu",
    "Delhi",
    "Lakshadweep",
    "Ladakh",
    "Puducherry",
    "Jammu and Kashmir",
  ];
  static const List<String> statesAndUT_PAN_India = [ "_PAN India" ];
  static const List<String> All_Constituencies = [ "_All Constituencies" ];

  static List<String> constituencies = [];
  static const Map<String, String> electionTypeMapping = {
    "General (Lok Sabha)": "Lok Sabha",
    "Council of States (Rajya Sabha)": "Rajya Sabha",
    "State Assembly (Vidhan Sabha)": "Vidhan Sabha",
    "Legislary Council (Vidhan Parishad)": "Vidhan Parishad",
  };
  static Future<void> loadConstituencies(String stateName, String electionType, String role) async {
    try {
      final String response = await rootBundle.loadString('assets/constituencies.json');
      final data = json.decode(response);

      // Map the election type to JSON keys
      final String? mappedType = electionTypeMapping[electionType];

      if (mappedType != null &&
          data["India"]?[mappedType]?[stateName] != null)
      {
        constituencies = List<String>.from(data["India"][mappedType][stateName]);
        print('Loaded constituencies for $stateName ($mappedType): $constituencies');

        // Check role and add "All_Constituencies" at the top if role is Candidate_Application_applying
        if (role == "Party_Head_Viewing_Selected_Candidates_Over_All_Constituencies_SO_Want_'All_Constituencies'_as_option")
        {
          constituencies.insert(0, "All_Constituencies");
          print('Added "All_Constituencies" to the top for role: $role');
        }
      }
      else
      {
        constituencies = [];
        print('No data found for $stateName ($electionType)');
      }
    } catch (e) {
      constituencies = [];
      print('Error loading constituencies: $e');
    }
  }
  static const List<String> stageLabels = [
    "Create Election",
    "Start Stage 1",
    "Stop Stage 1",
    "Start Stage 2",
    "Stop Stage 2",
    "Start Election",
    "Stop Election"
  ];
  static const List<String> stageFirestoreNames = [
    "Created Election",
    "Started Stage 1",
    "Stopped Stage 1",
    "Started Stage 2",
    "Stopped Stage 2",
    "Started Election",
    "Stopped Election"
  ];





  /// ***************  *************    *****     ***************  *************    *****     Blockchain-related constants   ***************  *************    *****     ***************  *************    *****
  /// ***************  *************    *****     ***************  *************    *****     Blockchain-related constants   ***************  *************    *****     ***************  *************    *****
  static const String rpcUrl_string = 'https://snowy-wandering-sponge.ethereum-sepolia.quiknode.pro/000000000000000000000'; // Replace wth your QuickNode URL // will not change ***
  // static const String rpcUrl_string = "https://sepolia.infura.io/000/0000000000000000"; // Replace wth your Infura URL // will not change ***

  // static const String contractAddress_string = "0000000000000000000"; // Replace wth your Deployed 1st contract address
  static const String contractAddress_string = "000000000000000000000000";  // Replace wth your Deployed 2nd contract address

  static const String privateKey_string = "000000000000000000000000000000000000"; // Replace wth your Meta Mask Private key
  static const String privateKey_2_string = "0000000000000000000000000000000000000000000000000"; // Replace wth your Meta Mask Private key
}
