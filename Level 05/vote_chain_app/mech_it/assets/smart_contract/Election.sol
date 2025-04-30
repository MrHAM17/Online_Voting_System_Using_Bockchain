

/////
//// SPDX-License-Identifier: MIT
//pragma solidity ^0.8.0;
//
//contract VoteChain {
//    struct Election {
//        string[] candidates; // Stores candidate emails as IDs
//        mapping(string => uint256) voteCount; // Candidate email → vote count
//    }
//
//    mapping(uint256 => mapping(string => mapping(string => Election))) public electionData;
//
//    event VoteCast(uint256 year, string electionType, string state, string candidateEmail, uint256 voteCount);
//
//    // Function to cast a vote
//    function castVote(
//        uint256 year,
//        string memory electionType,
//        string memory state,
//        string memory candidateEmail
//    ) public {
//        Election storage election = electionData[year][electionType][state];
//
//        // If candidate is voting for the first time, add to list
//        if (election.voteCount[candidateEmail] == 0) {
//            election.candidates.push(candidateEmail);
//        }
//
//        // Increment vote count
//        election.voteCount[candidateEmail]++;
//
//        emit VoteCast(year, electionType, state, candidateEmail, election.voteCount[candidateEmail]);
//    }
//
//    // Function to get all candidates and their vote counts
//    function getAllVotes(
//        uint256 year,
//        string memory electionType,
//        string memory state
//    ) public view returns (string[] memory, uint256[] memory) {
//        Election storage election = electionData[year][electionType][state];
//        uint256 candidateCount = election.candidates.length;
//
//        string[] memory emails = new string[](candidateCount);
//        uint256[] memory voteCounts = new uint256[](candidateCount);
//
//        for (uint256 i = 0; i < candidateCount; i++) {
//            string memory email = election.candidates[i];
//            emails[i] = email;
//            voteCounts[i] = election.voteCount[email];
//        }
//
//        return (emails, voteCounts);
//    }
//}


///////////////////////////



// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VoteChain {
    enum ApplicationStatus { NOT_STARTED, STARTED, STOPPED }
    enum ElectionStatus { NOT_STARTED, STARTED, STOPPED }

    struct Election {
        string[] candidates; // Stores candidate emails as IDs
        mapping(string => uint256) voteCount; // Candidate email → vote count
        ApplicationStatus partyApplicationStatus; // Party application status
        ApplicationStatus candidateApplicationStatus; // Candidate application status
        ElectionStatus electionStatus; // 🔹 New field to track if election is active

    }

    mapping(uint256 => mapping(string => mapping(string => Election))) public electionData;
    event VoteCast(uint256 year, string electionType, string state, string candidateEmail, uint256 voteCount);

    // Function to start the election --> Means Create election
    function startElection(uint256 year, string memory electionType, string memory state) public {
        Election storage election = electionData[year][electionType][state];
        election.electionStatus = ElectionStatus.STARTED;
    }

    // Function to start party applications
    function startPartyApplications(uint256 year, string memory electionType, string memory state) public {
        Election storage election = electionData[year][electionType][state];
        election.partyApplicationStatus = ApplicationStatus.STARTED;
    }

    // Function to stop party applications
    function stopPartyApplications(uint256 year, string memory electionType, string memory state) public {
        Election storage election = electionData[year][electionType][state];
        election.partyApplicationStatus = ApplicationStatus.STOPPED;
    }

    function getPartyApplicationStatus(uint256 year, string memory electionType, string memory state) public view returns (uint8) {
        Election storage election = electionData[year][electionType][state];
        return uint8(election.partyApplicationStatus);
    }

    // Function to start candidate applications
    function startCandidateApplications(uint256 year, string memory electionType, string memory state) public {
        Election storage election = electionData[year][electionType][state];
        election.candidateApplicationStatus = ApplicationStatus.STARTED;
    }

    // Function to stop candidate applications
    function stopCandidateApplications(uint256 year, string memory electionType, string memory state) public {
        Election storage election = electionData[year][electionType][state];
        election.candidateApplicationStatus = ApplicationStatus.STOPPED;
    }

    function getCandidateApplicationStatus(uint256 year, string memory electionType, string memory state) public view returns (uint8) {
        Election storage election = electionData[year][electionType][state];
        return uint8(election.candidateApplicationStatus);
    }

    // Function to cast a vote
    function castVote(
        uint256 year,
        string memory electionType,
        string memory state,
        string memory candidateEmail
    ) public {
        Election storage election = electionData[year][electionType][state];

        // If candidate is voting for the first time, add to list
        if (election.voteCount[candidateEmail] == 0) {
            election.candidates.push(candidateEmail);
        }

        // Increment vote count
        election.voteCount[candidateEmail]++;

        emit VoteCast(year, electionType, state, candidateEmail, election.voteCount[candidateEmail]);
    }

    // Function to get all candidates and their vote counts
    function getAllVotes(
        uint256 year,
        string memory electionType,
        string memory state
    ) public view returns (string[] memory, uint256[] memory) {
        Election storage election = electionData[year][electionType][state];
        uint256 candidateCount = election.candidates.length;

        string[] memory emails = new string[](candidateCount);
        uint256[] memory voteCounts = new uint256[](candidateCount);

        for (uint256 i = 0; i < candidateCount; i++) {
            string memory email = election.candidates[i];
            emails[i] = email;
            voteCounts[i] = election.voteCount[email];
        }

        return (emails, voteCounts);
    }

    // Function to stop the election
    function stopElection(uint256 year, string memory electionType, string memory state) public {
        Election storage election = electionData[year][electionType][state];
        election.electionStatus = ElectionStatus.STOPPED;
    }

    // Function to get election status
    function getElectionStatus(uint256 year, string memory electionType, string memory state) public view returns (uint8) {
        return uint8(electionData[year][electionType][state].electionStatus);
    }
}
