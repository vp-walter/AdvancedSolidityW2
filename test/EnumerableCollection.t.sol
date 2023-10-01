pragma solidity 0.8.19;

import {Test} from "forge-std/Test.sol";
import {EnumerableCollection} from "../src/EnumerableCollection/EnumerableCollection.sol";
import {SpecialTokenChecker} from "../src/EnumerableCollection/SpecialTokenChecker.sol";

contract EnumerableCollectionTest is Test {
    EnumerableCollection public nftIssuer;
    SpecialTokenChecker public primeCalculator;
    address internal _bob;
    address internal _alice;

    function setUp() public {
        _alice = address(1);
        vm.label(_alice, "Alice");
        _bob = address(2);
        vm.label(_bob, "Bob");
        nftIssuer = new EnumerableCollection("Enumerable Token", "LST");
        vm.deal(_alice, 10 ether);
        vm.deal(_bob, 10 ether);
        primeCalculator = new SpecialTokenChecker(address(nftIssuer));
    }

    function testCorrectName() public {
        string memory nftName = nftIssuer.name();
        assertEq(nftName, "Enumerable Token");
    }

    function testMintingIsCorrect() public {
        // mint three tokens for bob
        vm.prank(_bob);
        nftIssuer.mint{value: 1 ether}(10);

        vm.prank(_bob);
        nftIssuer.mint{value: 1 ether}(11);

        vm.prank(_bob);
        nftIssuer.mint{value: 1 ether}(12);

        vm.prank(_bob);
        nftIssuer.mint{value: 1 ether}(13);
        // check that the balance is 4

        uint256 bobsBalance = nftIssuer.balanceOf(_bob);
        assertEq(bobsBalance, 4);
    }

    function testPrimeCalculation() public {
        // mint three tokens for bob
        vm.prank(_bob);
        nftIssuer.mint{value: 1 ether}(10);

        vm.prank(_bob);
        nftIssuer.mint{value: 1 ether}(11);

        vm.prank(_bob);
        nftIssuer.mint{value: 1 ether}(12);

        vm.prank(_bob);
        nftIssuer.mint{value: 1 ether}(13);
        // check that the balance is 4

        uint256 bobsBalance = nftIssuer.balanceOf(_bob);
        assertEq(bobsBalance, 4);

        uint256 numPrimes = primeCalculator.quantityOfPrimesOwned(_bob);
        assertEq(numPrimes, 2);
    }

    function testForAllPrimes() public {
        // mint three tokens for bob
        vm.prank(_bob);
        nftIssuer.mint{value: 1 ether}(1);

        vm.prank(_bob);
        nftIssuer.mint{value: 1 ether}(3);

        vm.prank(_bob);
        nftIssuer.mint{value: 1 ether}(7);

        vm.prank(_bob);
        nftIssuer.mint{value: 1 ether}(17);
        // check that the balance is 4

        uint256 bobsBalance = nftIssuer.balanceOf(_bob);
        assertEq(bobsBalance, 4);

        uint256 numPrimes = primeCalculator.quantityOfPrimesOwned(_bob);
        assertEq(numPrimes, 4);
    }

    function testForNumber2() public {
        // mint three tokens for bob
        vm.prank(_bob);
        nftIssuer.mint{value: 1 ether}(2);

        uint256 numPrimes = primeCalculator.quantityOfPrimesOwned(_bob);
        assertEq(numPrimes, 1);
    }

    function testForNoPrimes() public {
        // mint three tokens for bob
        vm.prank(_bob);
        nftIssuer.mint{value: 1 ether}(4);

        vm.prank(_bob);
        nftIssuer.mint{value: 1 ether}(9);

        vm.prank(_bob);
        nftIssuer.mint{value: 1 ether}(15);

        uint256 numPrimes = primeCalculator.quantityOfPrimesOwned(_bob);
        assertEq(numPrimes, 0);
    }
}
