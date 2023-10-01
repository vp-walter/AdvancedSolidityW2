// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {IERC721Enumerable} from "openzeppelin-contracts/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

/**
 * @title Special NFT Token Counter
 * @author Walter Cavinaw
 * @notice An contract to count the number of special NFTs owned by an address
 * @dev Contract has a function to return the number of prime-numbered tokens owned.
 */
contract SpecialTokenChecker {
    IERC721Enumerable private immutable _targetCollection;

    constructor(address targetCollection_) {
        _targetCollection = IERC721Enumerable(targetCollection_);
    }

    /**
     * @notice returns the number of prime tokens owned by an address
     * @dev uses the ERC721 Enumerable to iterate over owned tokens and find primes
     * @param owner_ the addres of the owner to check
     */
    function quantityOfPrimesOwned(address owner_) external payable returns (uint256 quantity) {
        uint256 balanceOfOwner = _targetCollection.balanceOf(owner_);
        uint256 idx;
        uint256 tokenId;
        uint256 numPrimes;
        bool isPrime;
        while ((idx + 1) <= balanceOfOwner) {
            tokenId = _targetCollection.tokenOfOwnerByIndex(owner_, idx);
            isPrime = _isNumberPrime(tokenId);
            // increment number of prime tokenIDs in unchecked.
            if (isPrime) {
                unchecked {
                    ++numPrimes;
                }
            }
            unchecked {
                ++idx;
            }
        }
        // assign that number to quantity and exit.
        quantity = numPrimes;
    }

    /**
     * @notice checks for priming by iterating over range 2 -> sqrt(n);
     */
    function _isNumberPrime(uint256 tokenId) internal pure returns (bool isPrime) {
        uint256 factor = 2;
        uint256 upperBoundFactor = sqrt(tokenId) + 1;
        bool isPrimeCandidate = true;
        while (factor < upperBoundFactor && isPrimeCandidate) {
            if (tokenId % factor == 0) {
                isPrimeCandidate = false;
            }
            unchecked {
                ++factor;
            }
        }
        isPrime = isPrimeCandidate;
    }

    /// @notice Calculates the square root of x, rounding down. (copied from: https://ethereum.stackexchange.com/questions/2910/can-i-square-root-in-solidity)
    /// @dev Uses the Babylonian method https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method.
    /// @param x The uint256 number for which to calculate the square root.
    /// @return result The result as an uint256.
    function sqrt(uint256 x) internal pure returns (uint256 result) {
        if (x == 0) {
            return 0;
        }

        // Calculate the square root of the perfect square of a power of two that is the closest to x.
        uint256 xAux = uint256(x);
        result = 1;
        if (xAux >= 0x100000000000000000000000000000000) {
            xAux >>= 128;
            result <<= 64;
        }
        if (xAux >= 0x10000000000000000) {
            xAux >>= 64;
            result <<= 32;
        }
        if (xAux >= 0x100000000) {
            xAux >>= 32;
            result <<= 16;
        }
        if (xAux >= 0x10000) {
            xAux >>= 16;
            result <<= 8;
        }
        if (xAux >= 0x100) {
            xAux >>= 8;
            result <<= 4;
        }
        if (xAux >= 0x10) {
            xAux >>= 4;
            result <<= 2;
        }
        if (xAux >= 0x8) {
            result <<= 1;
        }

        // The operations can never overflow because the result is max 2^127 when it enters this block.
        unchecked {
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1;
            result = (result + x / result) >> 1; // Seven iterations should be enough
            uint256 roundedDownResult = x / result;
            return result >= roundedDownResult ? roundedDownResult : result;
        }
    }
}
