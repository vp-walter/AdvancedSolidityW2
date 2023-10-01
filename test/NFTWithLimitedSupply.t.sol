// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";
import {NFTWithLimitedSupply} from "../src/NFTEcosystem/NFTWithLimitedSupply.sol";
import {Merkle} from "murky/src/Merkle.sol";

contract NFTWithLimitedSupplyTest is Test {
    NFTWithLimitedSupply public nftIssuer;
    address internal _bob;
    address internal _alice;
    Merkle internal _allowList;
    bytes32[] internal _data;
    bytes32 internal _root;

    function setUp() public {
        _alice = address(1);
        vm.label(_alice, "Alice");
        _bob = address(2);
        vm.label(_bob, "Bob");
        vm.deal(_alice, 100 ether);
        vm.deal(_bob, 100 ether);
        _allowList = new Merkle();
        _data = new bytes32[](2);
        _data[0] = keccak256(abi.encode(_alice, uint256(1)));
        _data[1] = keccak256(abi.encode(_bob, uint256(2)));
        _root = _allowList.getRoot(_data);
        nftIssuer = new NFTWithLimitedSupply("Limited Supply Token", "LMT", _root);
    }

    function testTokenLimit() public {
        for (uint256 i = 0; i < 20; i++) {
            vm.prank(_bob);
            nftIssuer.mint{value: 1 ether}(i);
        }
        uint256 bobsBalance = nftIssuer.balanceOf(_bob);
        assertEq(bobsBalance, 20);
    }

    function testRoyaltyInfo() public {
        vm.prank(_bob);
        nftIssuer.mint{value: 1 ether}(15);
        (address receiver, uint256 royaltyAmount) = nftIssuer.royaltyInfo(15, 10_000);
        assertEq(royaltyAmount, 250);
        assertEq(receiver, address(this));
    }

    function testSpecialAddressGetsDiscount() public {
        bytes32[] memory proof = _allowList.getProof(_data, 0);
        vm.prank(_alice);
        nftIssuer.discountedMint{value: 0.5 ether}(17, 1, proof);
        assertEq(nftIssuer.balanceOf(_alice), 1);
    }

    function testSpecialAddressDiscoutAndBlocked() public {
        bytes32[] memory proof = _allowList.getProof(_data, 1);
        vm.prank(_bob);
        nftIssuer.discountedMint{value: 0.5 ether}(17, 2, proof);
        assertEq(nftIssuer.balanceOf(_bob), 1);

        bytes32[] memory _aliceProof = _allowList.getProof(_data, 0);
        vm.prank(_bob);
        vm.expectRevert();
        nftIssuer.discountedMint{value: 0.5 ether}(5, 3, _aliceProof);
    }

    function testCanDepositNFTAndReceiveStake() public {}

    function testCanDepositAndRedeem() public {}

    function testCanDepositOnlyOnceInADay() public {}

    function testCannotRedeemSomeoneElsesDeposit() public {}
}
