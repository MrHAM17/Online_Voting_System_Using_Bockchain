class ElectionDetails {
  // Private constructor
  ElectionDetails._privateConstructor();

  // Singleton instance
  static final ElectionDetails _instance = ElectionDetails._privateConstructor();

  // Get instance
  static ElectionDetails get instance => _instance;

  // Election details
  String? electionType;
  String? year;
  String? state;
}

String getBasePath() {
  final electionDetails = ElectionDetails.instance;

  if
  (
      electionDetails.electionType == "State Assembly (Vidhan Sabha)" || electionDetails.electionType == "Legislary Council (Vidhan Parishad)" ||
      electionDetails.electionType == "Municipal" || electionDetails.electionType == "Panchayat"
  )
  { return 'Vote Chain/State/${electionDetails.state}/Election/${electionDetails.year}/${electionDetails.electionType}';  }
  else if
  ( electionDetails.electionType == "General (Lok Sabha)" || electionDetails.electionType == "Council of States (Rajya Sabha)" )
  { return 'Vote Chain/Election/${electionDetails.year}/${electionDetails.electionType}/State/${electionDetails.state}';  }
  else if
  (electionDetails.electionType == "Presidential" || electionDetails.electionType == "Vice-Presidential")
  { return 'Vote Chain/Election/${electionDetails.year}/Special Electoral Commission/${electionDetails.electionType}';  }
  return '';

}