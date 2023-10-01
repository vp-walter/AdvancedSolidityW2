// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {ERC721Enumerable} from "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {Ownable2Step} from "openzeppelin-contracts/contracts/access/Ownable2Step.sol";

/**
 * @title Limited Enumerable Collection
 * @author Walter Cavinaw
 * @notice An NFT Collection with enumeration and limited supply of 20
 */
contract EnumerableCollection is ERC721Enumerable, Ownable2Step {
    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}

    /**
     * @notice allows to mint tokenID with payment
     */
    function mint(uint256 tokenId) external payable {
        require(msg.value == 1 ether, "Need to pay 1 ether");
        _mint(msg.sender, tokenId);
    }

    /**
     * @notice ensure that token id range is within 1 - 20.
     */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize) internal override {
        require(tokenId <= 20, "token id not within limits");
        require(tokenId >= 1, "token id not within limits");
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }
}
