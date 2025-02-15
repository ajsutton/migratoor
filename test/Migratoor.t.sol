// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Migratoor} from "../src/Migratoor.sol";

contract CounterTest is Test {
    Migratoor public counter;

    function setUp() public {
        counter = new Migratoor();
    }

    // TODO: Learn to write solidity tests....
}
