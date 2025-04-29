// Starting with the Smart Contract for "Vote Chain" Voting System

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Election {
    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    struct Voter {
        bool hasVoted;
        uint votedCandidateId;
    }

    address public admin;
    string public electionName;
    mapping(uint => Candidate) public candidates;
    mapping(address => Voter) public voters;
    uint public totalCandidates;
    uint public totalVotes;

    event ElectionCreated(string electionName, address admin);
    event CandidateAdded(uint id, string name);
    event VoteCasted(address voter, uint candidateId);

    constructor(string memory _electionName) {
        admin = msg.sender;
        electionName = _electionName;
        totalCandidates = 0;
        totalVotes = 0;
        emit ElectionCreated(_electionName, admin);
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    function addCandidate(string memory _name) public onlyAdmin {
        totalCandidates++;
        candidates[totalCandidates] = Candidate(totalCandidates, _name, 0);
        emit CandidateAdded(totalCandidates, _name);
    }

    function vote(uint _candidateId) public {
        require(!voters[msg.sender].hasVoted, "You have already voted");
        require(_candidateId > 0 && _candidateId <= totalCandidates, "Invalid candidate ID");

        voters[msg.sender] = Voter(true, _candidateId);
        candidates[_candidateId].voteCount++;
        totalVotes++;

        emit VoteCasted(msg.sender, _candidateId);
    }

    function getCandidate(uint _id) public view returns (uint, string memory, uint) {
        require(_id > 0 && _id <= totalCandidates, "Invalid candidate ID");
        Candidate memory candidate = candidates[_id];
        return (candidate.id, candidate.name, candidate.voteCount);
    }

    function getResults() public view returns (string[] memory, uint[] memory) {
        string[] memory candidateNames = new string[](totalCandidates);
        uint[] memory voteCounts = new uint[](totalCandidates);

        for (uint i = 1; i <= totalCandidates; i++) {
            candidateNames[i - 1] = candidates[i].name;
            voteCounts[i - 1] = candidates[i].voteCount;
        }
        return (candidateNames, voteCounts);
    }

    function endElection() public onlyAdmin {
        selfdestruct(payable(admin));
    }
}