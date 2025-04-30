import 'candidate.dart';

class Election {
  final String electionId;
  final String electionName;
  final String electionType;
  final List<Candidate> candidates;

  Election({
    required this.electionId,
    required this.electionName,
    required this.electionType,
    required this.candidates,
  });
}
