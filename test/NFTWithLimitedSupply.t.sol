// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";
import {NFTWithLimitedSupply} from "../src/NFTEcosystem/NFTWithLimitedSupply.sol";
import {StakingReward} from "../src/NFTEcosystem/StakingReward.sol";
import {NFTCollateralBank} from "../src/NFTEcosystem/NFTCollateralBank.sol";
import {Merkle} from "murky/src/Merkle.sol";

contract NFTWithLimitedSupplyTest is Test {
    NFTWithLimitedSupply public nftIssuer;
    StakingReward public stakingRewards;
    NFTCollateralBank public bank;
    address internal _bob;
    address internal _alice;
    Merkle internal _allowList;
    bytes32[] internal _data;
    bytes32 internal _root;

    function setUp() public {
        // setup addresses.
        _alice = address(1);
        vm.label(_alice, "Alice");
        _bob = address(2);
        vm.label(_bob, "Bob");
        vm.deal(_alice, 100 ether);
        vm.deal(_bob, 100 ether);
        // setup allow list for discounted minting.
        _allowList = new Merkle();
        _data = new bytes32[](2);
        _data[0] = keccak256(abi.encode(_alice, uint256(1)));
        _data[1] = keccak256(abi.encode(_bob, uint256(2)));
        _root = _allowList.getRoot(_data);
        // create NFT issuer
        nftIssuer = new NFTWithLimitedSupply("Limited Supply Token", "LMT", _root);
        // create staking rewards
        stakingRewards = new StakingReward("Staking Reward", "RWRD");
        // create NFT Collateral Bank
        bank = new NFTCollateralBank(address(stakingRewards), address(nftIssuer));
        // add the bank as an operator to staking rewards.abi
        stakingRewards.setOperator(address(bank), true);

        vm.warp(2 days);
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

    function testCanDepositNFTAndReceiveStake() public {
        uint256 tokenId = 15;
        vm.startPrank(_bob);
        nftIssuer.mint{value: 1 ether}(tokenId);
        nftIssuer.setApprovalForAll(address(bank), true);
        bank.deposit(tokenId);
        uint256 bobsRewardBalance = stakingRewards.balanceOf(_bob);
        uint256 bobsNFTBalance = nftIssuer.balanceOf(_bob);
        vm.stopPrank();

        assertEq(bobsRewardBalance, 10 * 10 ** 18);
        assertEq(bobsNFTBalance, 0);
    }

    function testCanDepositAndRedeem() public {
        uint256 tokenId = 15;
        vm.startPrank(_bob);
        nftIssuer.mint{value: 1 ether}(tokenId);
        nftIssuer.setApprovalForAll(address(bank), true);
        bank.deposit(tokenId);
        uint256 bobsRewardBalance = stakingRewards.balanceOf(_bob);
        assertEq(bobsRewardBalance, 10 * 10 ** 18);
        stakingRewards.approve(address(bank), 10 * 10 ** 18);
        bank.redeem(tokenId);
        bobsRewardBalance = stakingRewards.balanceOf(_bob);
        assertEq(bobsRewardBalance, 0);
        uint256 bobsNFTBalance = nftIssuer.balanceOf(_bob);
        assertEq(bobsNFTBalance, 1);
        vm.stopPrank();
    }

    function testCanDepositOnlyOnceInADay() public {
        uint256 firstToken = 15;
        vm.startPrank(_bob);
        nftIssuer.mint{value: 1 ether}(firstToken);
        // try to deposit first token.
        nftIssuer.setApprovalForAll(address(bank), true);
        bank.deposit(firstToken);
        bank.redeem(firstToken);
        vm.expectRevert();
        bank.deposit(firstToken);
        vm.warp(block.timestamp + 25 hours);
        bank.deposit(firstToken);

        uint256 bobsNFTBalance = nftIssuer.balanceOf(_bob);
        vm.stopPrank();

        assertEq(bobsNFTBalance, 0);
    }

    function testCannotDepositAnothersNFT() public {
        uint256 firstToken = 15;
        vm.prank(_bob);
        nftIssuer.mint{value: 1 ether}(firstToken);

        vm.startPrank(_alice);
        nftIssuer.setApprovalForAll(address(bank), true);
        vm.expectRevert();
        bank.deposit(firstToken);
        vm.stopPrank();
    }
}
