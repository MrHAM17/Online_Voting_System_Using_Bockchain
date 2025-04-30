
// //  **************** Version 1 of Smart Contract  ******************************************************************************************************************


//// Starting with the Smart Contract for "Vote Chain" Voting System
//
//// SPDX-License-Identifier: MIT
//pragma solidity ^0.8.0;
//
//contract Election {
//    struct Candidate {
//        uint id;
//        string name;
//        uint voteCount;
//    }
//
//    struct Voter {
//        bool hasVoted;
//        uint votedCandidateId;
//    }
//
//    address public admin;
//    string public electionName;
//    mapping(uint => Candidate) public candidates;
//    mapping(address => Voter) public voters;
//    uint public totalCandidates;
//    uint public totalVotes;
//
//    event ElectionCreated(string electionName, address admin);
//    event CandidateAdded(uint id, string name);
//    event VoteCasted(address voter, uint candidateId);
//
//    constructor(string memory _electionName) {
//        admin = msg.sender;
//        electionName = _electionName;
//        totalCandidates = 0;
//        totalVotes = 0;
//        emit ElectionCreated(_electionName, admin);
//    }
//
//    modifier onlyAdmin() {
//        require(msg.sender == admin, "Only admin can perform this action");
//        _;
//    }
//
//    function addCandidate(string memory _name) public onlyAdmin {
//        totalCandidates++;
//        candidates[totalCandidates] = Candidate(totalCandidates, _name, 0);
//        emit CandidateAdded(totalCandidates, _name);
//    }
//
//    function vote(uint _candidateId) public {
//        require(!voters[msg.sender].hasVoted, "You have already voted");
//        require(_candidateId > 0 && _candidateId <= totalCandidates, "Invalid candidate ID");
//
//        voters[msg.sender] = Voter(true, _candidateId);
//        candidates[_candidateId].voteCount++;
//        totalVotes++;
//
//        emit VoteCasted(msg.sender, _candidateId);
//    }
//
//    function getCandidate(uint _id) public view returns (uint, string memory, uint) {
//        require(_id > 0 && _id <= totalCandidates, "Invalid candidate ID");
//        Candidate memory candidate = candidates[_id];
//        return (candidate.id, candidate.name, candidate.voteCount);
//    }
//
//    function getResults() public view returns (string[] memory, uint[] memory) {
//        string[] memory candidateNames = new string[](totalCandidates);
//        uint[] memory voteCounts = new uint[](totalCandidates);
//
//        for (uint i = 1; i <= totalCandidates; i++) {
//            candidateNames[i - 1] = candidates[i].name;
//            voteCounts[i - 1] = candidates[i].voteCount;
//        }
//        return (candidateNames, voteCounts);
//    }
//
//    function endElection() public onlyAdmin {
//        selfdestruct(payable(admin));
//    }
//}




// //  **************** Version 2 of Smart Contract  ******************************************************************************************************************




// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VoteChainElection {
    struct Candidate {
        uint id;
        string name;
        string party;
        uint voteCount;
    }

    struct Election {
        uint id;
        string name;
        string electionType; // Lok Sabha, Vidhan Sabha, etc.
        string state;
        uint startDate;
        uint endDate;
        bool isActive;
        mapping(uint => Candidate) candidates;
        uint totalCandidates;
        uint totalVotes;
    }

    address public admin;
    uint public totalElections;
    mapping(uint => Election) public elections;

    event ElectionCreated(uint id, string name, string electionType, string state);
    event CandidateAdded(uint electionId, uint candidateId, string name);
    event VoteCasted(uint electionId, uint candidateId, address voter);

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    function createElection(
        string memory _name,
        string memory _electionType,
        string memory _state,
        uint _startDate,
        uint _endDate
    ) public onlyAdmin {
        totalElections++;
        Election storage newElection = elections[totalElections];
        newElection.id = totalElections;
        newElection.name = _name;
        newElection.electionType = _electionType;
        newElection.state = _state;
        newElection.startDate = _startDate;
        newElection.endDate = _endDate;
        newElection.isActive = true;

        emit ElectionCreated(totalElections, _name, _electionType, _state);
    }

    function addCandidate(uint _electionId, string memory _name, string memory _party) public onlyAdmin {
        Election storage election = elections[_electionId];
        election.totalCandidates++;
        election.candidates[election.totalCandidates] = Candidate(election.totalCandidates, _name, _party, 0);
        emit CandidateAdded(_electionId, election.totalCandidates, _name);
    }

    function vote(uint _electionId, uint _candidateId) public {
        Election storage election = elections[_electionId];
        require(election.isActive, "Election is not active");
        election.candidates[_candidateId].voteCount++;
        election.totalVotes++;
        emit VoteCasted(_electionId, _candidateId, msg.sender);
    }

    function endElection(uint _electionId) public onlyAdmin {
        elections[_electionId].isActive = false;
    }

    function getElectionDetails(uint _electionId)
    public
    view
    returns (
        string memory name,
        string memory electionType,
        string memory state,
        uint startDate,
        uint endDate,
        uint totalCandidates,
        uint totalVotes,
        bool isActive
    )
    {
        Election storage election = elections[_electionId];
        return (
            election.name,
            election.electionType,
            election.state,
            election.startDate,
            election.endDate,
            election.totalCandidates,
            election.totalVotes,
            election.isActive
        );
    }
}
