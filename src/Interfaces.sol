pragma solidity ^0.8.25;

interface IDisputeGame {
    event Resolved(GameStatus indexed status);

    function status() external view returns (GameStatus);

    function rootClaim() external pure returns (bytes32 rootClaim_);

    function l2BlockNumber() external pure returns (uint256 l2BlockNumber_);
}

interface IDisputeGameFactory {
    function gameAtIndex(uint256 _index)
        external
        view
        returns (uint32 gameType_, uint64 timestamp_, IDisputeGame proxy_);
}

/// @notice The current status of the dispute game.
enum GameStatus {
    // The game is currently in progress, and has not been resolved.
    IN_PROGRESS,
    // The game has concluded, and the `rootClaim` was challenged successfully.
    CHALLENGER_WINS,
    // The game has concluded, and the `rootClaim` could not be contested.
    DEFENDER_WINS
}
