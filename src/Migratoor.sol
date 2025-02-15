// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./libraries/rlp/RLPReader.sol";
import {IDisputeGameFactory, IDisputeGame, GameStatus} from "./Interfaces.sol";

error InvalidOutput();
error InvalidHeaderRLP();
error InvalidGameStatus();
error TimestampMismatch();

contract Migratoor {

    /// @notice The index of the block number in the RLP-encoded block header.
    uint256 internal constant HEADER_TIMESTAMP_INDEX = 11;
    uint8 internal constant SUPER_VERSION = uint8(1);

    IDisputeGameFactory[] public gameFactories;
    uint256[] public chainIDs;

    constructor(IDisputeGameFactory[] memory _gameFactories, uint256[] memory _chainIDs) {
        gameFactories = _gameFactories;
        chainIDs = _chainIDs;
    }

    function chainsLen() external view returns (uint256) {
        return gameFactories.length;
    }

    function migrate(uint256[] calldata _gameIdxs, OutputRootProof[] calldata _outputs, bytes[] calldata _headerRLP) external view returns (bytes memory super_, bytes32 superRoot_) {
        uint256 chainCount = gameFactories.length;
        uint256 expectedTimestamp = 0;
        bytes memory chainData;
        for (uint256 i = 0; i < chainCount; i++) {
            (, , IDisputeGame game) = gameFactories[i].gameAtIndex(_gameIdxs[i]);
            // TODO: Check the game is a valid, finalized game - respected game type, not blacklisted etc
            if (game.status() != GameStatus.DEFENDER_WINS) {
                revert InvalidGameStatus();
            }

            bytes32 outputRoot = game.rootClaim();
            if (hashOutputRootProof(_outputs[i]) != outputRoot) {
                revert InvalidOutput();
            }
            if (keccak256(_headerRLP[i]) != _outputs[i].latestBlockhash) {
                revert InvalidHeaderRLP();
            }

            // Decode the header RLP to find the number of the block. In the consensus encoding, the timestamp
            // is the 12th element in the list that represents the block header.
            RLPReader.RLPItem[] memory headerContents = RLPReader.readList(RLPReader.toRLPItem(_headerRLP[i]));
            bytes memory rawTimestamp = RLPReader.readBytes(headerContents[HEADER_TIMESTAMP_INDEX]);

            // Sanity check the block number string length.
            if (rawTimestamp.length > 32) revert InvalidHeaderRLP();

            // Convert the raw, left-aligned timestamp to a uint256 by aligning it as a big-endian
            // number in the low-order bytes of a 32-byte word.
            //
            // SAFETY: The length of `rawTimestamp` is checked above to ensure it is at most 32 bytes.
            uint256 tstamp;
            assembly {
                tstamp := shr(shl(0x03, sub(0x20, mload(rawTimestamp))), mload(add(rawTimestamp, 0x20)))
            }
            if (i != 0 && tstamp != expectedTimestamp) {
                revert TimestampMismatch();
            }
            expectedTimestamp = tstamp;

            chainData = abi.encodePacked(chainData, chainIDs[i], outputRoot);
        }
        bytes memory superBytes =  abi.encodePacked(SUPER_VERSION, uint64(expectedTimestamp), chainData);
        bytes32 superRoot = keccak256(superBytes);
        // TODO: call AnchorStateRegistry.updateAnchorState(expectedTimestamp, superRoot);
        // Or just put this method on AnchorStateRegistry and it can update itself.
        return (superBytes, superRoot);
    }


    /// @notice Hashes the various elements of an output root proof into an output root hash which
    ///         can be used to check if the proof is valid.
    /// @param _outputRootProof Output root proof which should hash to an output root.
    /// @return Hashed output root proof.
    function hashOutputRootProof(OutputRootProof memory _outputRootProof) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                _outputRootProof.version,
                _outputRootProof.stateRoot,
                _outputRootProof.messagePasserStorageRoot,
                _outputRootProof.latestBlockhash
            )
        );
    }
}

/// @notice Struct representing the elements that are hashed together to generate an output root
///         which itself represents a snapshot of the L2 state.
/// @custom:field version                  Version of the output root.
/// @custom:field stateRoot                Root of the state trie at the block of this output.
/// @custom:field messagePasserStorageRoot Root of the message passer storage trie.
/// @custom:field latestBlockhash          Hash of the block this output was generated from.
struct OutputRootProof {
    bytes32 version;
    bytes32 stateRoot;
    bytes32 messagePasserStorageRoot;
    bytes32 latestBlockhash;
}
