// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {
    struct Candidate {
        string name;
        uint voteCount;
    }

    mapping(address => bool) public voters;
    Candidate[] public candidates;

    function addCandidate(string memory _name) public {
        candidates.push(Candidate(_name, 0));
    }

    function vote(uint _candidateIndex) public {
        require(!voters[msg.sender], "Already voted.");
        require(_candidateIndex < candidates.length, "Invalid candidate index.");

        voters[msg.sender] = true;
        candidates[_candidateIndex].voteCount += 1;
    }

    function getCandidates() public view returns (Candidate[] memory) {
        return candidates;
    }

    function getVoteCount(uint _candidateIndex) public view returns (uint) {
        require(_candidateIndex < candidates.length, "Invalid candidate index.");
        return candidates[_candidateIndex].voteCount;
    }

    function hasVoted(address _voter) public view returns (bool) {
        return voters[_voter];
    }
}
