// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {Ownable2Step} from "openzeppelin-contracts/contracts/access/Ownable2Step.sol";

/**
 * @title NFT with Limited Supply
 * @author Walter Cavinaw
 * @notice An limited-supply NFT which implements the royalty standard
 * @dev The NFT supply is limited to 20 tokens, with a sales royalty of 2.5%
 */
contract NFTWithLimitedSupply is ERC721, ERC2918, Ownable2Step {
    constructor() {}

    /**
     * @notice Minting function allows some addresses to get a discount.
     */
    function mint() external {
        bool isSpecialAddress = false;
        require(msg.value >= 1 ether || (isSpecialAddress && msg.value >= 0.5 ether), "Not enough ether sent.");
    }
}
