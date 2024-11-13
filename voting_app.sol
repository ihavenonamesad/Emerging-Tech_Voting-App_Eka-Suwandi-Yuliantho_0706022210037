// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VotingApplication {
    // Enum to define election phases
    enum ElectionStatus { NotStarted, Open, Closed }
    ElectionStatus public electionStatus;

    // Struct to store candidate information
    struct Candidate {
        string name;
        uint id;
        uint voteCount;
    }

    // Struct to store voter information
    struct Voter {
        bool isAuthorized; 
        bool hasVoted;
        uint votedCandidateId;
    }

    // State variables
    address public admin;
    mapping(uint => Candidate) public candidates;
    mapping(address => Voter) public voters;
    uint public candidateCount;

    // Events
    event CandidateAdded(uint candidateId, string name);
    event VoterAdded(address voter);
    event VoteCast(address voter, uint candidateId);
    event VotingOpened();
    event VotingClosed();

    // Modifiers
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier onlyVoter() {
        require(voters[msg.sender].isAuthorized, "Not registered as a voter");
        _;
    }

    modifier onlyDuringVoting() {
        require(electionStatus == ElectionStatus.Open, "Voting is not opened");
        _;
    }

    modifier onlyOnce() {
        require(!voters[msg.sender].hasVoted, "Voter has already cast their vote.");
        _;
    }

    // Constructor
    constructor() {
        admin = msg.sender;
        electionStatus = ElectionStatus.NotStarted;
    }

    // Add a new candidate (only by admin)
    function addCandidate(string memory _name) public onlyAdmin {
        candidates[candidateCount] = Candidate(_name, candidateCount, 0);
        emit CandidateAdded(candidateCount, _name);
        candidateCount++;
    }

    // Add a new voter (only by admin)
    function addVoter(address _voter) public onlyAdmin {
        voters[_voter].isAuthorized = true;
        require(voters[_voter].hasVoted == false, "Voter already added");
        emit VoterAdded(_voter);
    }

    // Open the voting process (only by admin)
    function openVoting() public onlyAdmin {
        require(electionStatus == ElectionStatus.NotStarted, "Election already started or closed");
        electionStatus = ElectionStatus.Open;
        emit VotingOpened();
    }

    // Close the voting process (only by admin)
    function closeVoting() public onlyAdmin {
        require(electionStatus == ElectionStatus.Open, "Election is not opened");
        electionStatus = ElectionStatus.Closed;
        emit VotingClosed();
    }

    // Vote for a candidate (only by registered voter, only once)
    function vote(uint _candidateId) public onlyVoter onlyDuringVoting onlyOnce {
        require(_candidateId >= 0 && _candidateId < candidateCount, "Invalid candidate ID");

        voters[msg.sender].hasVoted = true; // Mark the voter as having voted
        voters[msg.sender].votedCandidateId = _candidateId;
        candidates[_candidateId].voteCount += 1; // Increment the candidate's vote count

        emit VoteCast(msg.sender, _candidateId); // Emit event for vote casting 
    }

    // View function to get vote count of a specific candidate
    function getCandidateVotes(uint _candidateId) public view returns (uint) {
        require(_candidateId >= 0 && _candidateId < candidateCount, "Candidate does not exist");
        return candidates[_candidateId].voteCount;
    }

    // View function to get the current election status
    function getElectionStatus() public view returns (string memory) {
        if (electionStatus == ElectionStatus.NotStarted) {
            return "Not Started";
        } else if (electionStatus == ElectionStatus.Open) {
            return "Open";
        } else {
            return "Closed";
        }
    }
}
