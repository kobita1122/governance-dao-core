// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SimpleGovernor is Ownable {
    enum ProposalState { Pending, Active, Succeeded, Defeated, Executed }

    struct Proposal {
        address target;
        uint256 value;
        bytes data;
        uint256 voteStart;
        uint256 voteEnd;
        uint256 forVotes;
        uint256 againstVotes;
        bool executed;
    }

    IERC20 public governanceToken;
    uint256 public constant VOTING_DELAY = 1; // Blocks
    uint256 public constant VOTING_PERIOD = 50400; // Approx 1 week of blocks
    uint256 public quorumRequirement;

    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    uint256 public proposalCount;

    constructor(address _token, uint256 _quorum) Ownable(msg.sender) {
        governanceToken = IERC20(_token);
        quorumRequirement = _quorum;
    }

    function propose(address target, uint256 value, bytes memory data) external returns (uint256) {
        require(governanceToken.balanceOf(msg.sender) > 0, "Must hold tokens to propose");
        
        uint256 proposalId = proposalCount++;
        Proposal storage p = proposals[proposalId];
        p.target = target;
        p.value = value;
        p.data = data;
        p.voteStart = block.number + VOTING_DELAY;
        p.voteEnd = block.number + VOTING_DELAY + VOTING_PERIOD;

        return proposalId;
    }

    function castVote(uint256 proposalId, bool support) external {
        Proposal storage p = proposals[proposalId];
        require(block.number >= p.voteStart && block.number <= p.voteEnd, "Voting not active");
        require(!hasVoted[proposalId][msg.sender], "Already voted");

        uint256 weight = governanceToken.balanceOf(msg.sender);
        if (support) {
            p.forVotes += weight;
        } else {
            p.againstVotes += weight;
        }

        hasVoted[proposalId][msg.sender] = true;
    }

    function execute(uint256 proposalId) external payable {
        Proposal storage p = proposals[proposalId];
        require(block.number > p.voteEnd, "Voting still active");
        require(!p.executed, "Already executed");
        require(p.forVotes > p.againstVotes, "Proposal did not pass");
        require(p.forVotes >= quorumRequirement, "Quorum not met");

        p.executed = true;
        (bool success, ) = p.target.call{value: p.value}(p.data);
        require(success, "Execution failed");
    }
}
