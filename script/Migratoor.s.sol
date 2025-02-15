// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {CommonBase} from "../lib/forge-std/src/Base.sol";
import {Script} from "../lib/forge-std/src/Script.sol";
import {StdChains} from "../lib/forge-std/src/StdChains.sol";
import {StdCheatsSafe} from "../lib/forge-std/src/StdCheats.sol";
import {StdUtils} from "../lib/forge-std/src/StdUtils.sol";
import {IDisputeGameFactory} from "../src/Interfaces.sol";
import {Migratoor} from "../src/Migratoor.sol";

contract MigratoorScript is Script {
    Migratoor public migratoor;

    function setUp() public {}

    function run() public {
        IDisputeGameFactory[] memory factories = new IDisputeGameFactory[](2);
        uint256[] memory chainIDs = new uint256[](2);
        // unichain-sepolia
        factories[0] = IDisputeGameFactory(0xeff73e5aa3B9AEC32c659Aa3E00444d20a84394b);
        chainIDs[0] = 1301;
        // op-sepolia
        factories[1] = IDisputeGameFactory(0x05F9613aDB30026FFd634f38e5C4dFd30a197Fa1);
        chainIDs[1] = 11155420;

        vm.startBroadcast();
        migratoor = new Migratoor(factories, chainIDs);
        vm.stopBroadcast();
    }
}
