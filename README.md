# Governance DAO Core

A professional framework for decentralized autonomous organizations. This system allows community members to govern a treasury or modify protocol parameters via a transparent voting process.

### Governance Workflow
1. **Proposal:** An eligible token holder submits a proposal (target address, value, and data).
2. **Voting Period:** Stakeholders cast "For", "Against", or "Abstain" votes.
3. **Quorum & Success:** If the quorum is met and the majority votes "For", the proposal succeeds.
4. **Execution:** The successful proposal is queued and executed.



### Key Components
* **Proposal Power:** Determined by `IERC20` token balances.
* **Quorum:** Minimum number of votes required for a proposal to be valid.
* **Execution Guard:** Ensures only passed proposals can trigger state changes.
