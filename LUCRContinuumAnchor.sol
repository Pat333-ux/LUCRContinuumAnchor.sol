// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LUCRContinuumAnchor {
    address public governance;

    struct ContinuumPoint {
        uint256 blockNum;
        uint256 timestamp;
        bytes32 priorIntegrity;
        bytes32 priorAudit;
        bytes32 priorPulse;
        bytes32 priorOracle;
        bytes32 continuumHash;
    }

    mapping(uint256 => ContinuumPoint) public continuum;

    event ContinuumAnchored(
        uint256 indexed blockNum,
        bytes32 continuumHash,
        uint256 timestamp
    );

    modifier onlyGovernance() {
        require(msg.sender == governance, "Not governance");
        _;
    }

    constructor() {
        governance = msg.sender;
    }

    function anchor(
        bytes32 integrityHash,
        bytes32 auditHash,
        bytes32 pulseHash,
        bytes32 oracleDigest
    ) external onlyGovernance returns (bytes32) {
        bytes32 finalHash = keccak256(
            abi.encodePacked(
                integrityHash,
                auditHash,
                pulseHash,
                oracleDigest,
                block.number,
                block.timestamp
            )
        );

        continuum[block.number] = ContinuumPoint({
            blockNum: block.number,
            timestamp: block.timestamp,
            priorIntegrity: integrityHash,
            priorAudit: auditHash,
            priorPulse: pulseHash,
            priorOracle: oracleDigest,
            continuumHash: finalHash
        });

        emit ContinuumAnchored(block.number, finalHash, block.timestamp);
        return finalHash;
    }
}
