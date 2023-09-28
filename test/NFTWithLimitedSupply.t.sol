// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";
import {NFTWithLimitedSupply} from "../src/NFTWithLimitedSupply.sol";

contract NFTWithLimitedSupplyTest is Test {
    NFTWithLimitedSupply public token;
    address internal _bob;
    address internal _alice;

    uint256 internal immutable ALICE_INIT_BALANCE = 10_000;
    uint256 internal immutable BOB_INIT_BALANCE = 5_000;

    function setUp() public {
        _alice = address(1);
        vm.label(_alice, "Alice");
        _bob = address(2);
        vm.label(_bob, "Bob");
        token = new NFTWithLimitedSupply("God Mode Token", "USD");
        token.mint(_alice, ALICE_INIT_BALANCE);
        token.mint(_bob, BOB_INIT_BALANCE);
    }
}
