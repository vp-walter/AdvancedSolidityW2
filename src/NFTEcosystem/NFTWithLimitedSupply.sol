// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import {Ownable2Step} from "openzeppelin-contracts/contracts/access/Ownable2Step.sol";
import {ERC2981} from "openzeppelin-contracts/contracts/token/common/ERC2981.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/structs/BitMaps.sol";

/**
 * @title NFT with Limited Supply
 * @author Walter Cavinaw
 * @notice An limited-supply NFT which implements the royalty standard
 * @dev The NFT supply is limited to 20 tokens, with a sales royalty of 2.5%
 */
contract NFTWithLimitedSupply is ERC721, ERC2981, Ownable2Step {
    using BitMaps for BitMaps.BitMap;

    uint256 private constant _MAX_SUPPLY = 20;
    uint96 private constant _ROYALTY_BASIS_POINTS = 250;
    uint96 private constant _REGULAR_PRICE = 1 ether;
    uint96 private constant _DISCOUNTED_PRICE = 0.5 ether;

    bytes32 private immutable _merkleRoot;

    uint256 private _totalSupply;
    BitMaps.BitMap private _discountCoupons;

    constructor(string memory name_, string memory symbol_, bytes32 merkleRoot_) ERC721(name_, symbol_) {
        _setDefaultRoyalty(msg.sender, _ROYALTY_BASIS_POINTS);
        _merkleRoot = merkleRoot_;
    }

    /**
     * @notice Minting function for regular addresses (without discount)
     */
    function mint(uint256 tokenId) external payable {
        require(msg.value == _REGULAR_PRICE, "Not enough ether sent.");
        _safeMint(msg.sender, tokenId);
    }

    /**
     * @notice Minting function for special addresses (with discount).
     * @dev each address can only mint once.
     */
    function discountedMint(uint256 tokenId, uint256 discountCoupon, bytes32[] calldata merkleProof) external payable {
        require(msg.value == _DISCOUNTED_PRICE, "Not enough ether sent.");
        // check if the coupon has already been used.
        require(!_discountCoupons.get(discountCoupon), "Coupon has already been used.");
        _discountCoupons.set(discountCoupon);
        // check that address is allowed to use this coupon;
        _verifyDiscountMembership(msg.sender, discountCoupon, merkleProof);
        // mint for a discount.
        _safeMint(msg.sender, tokenId);
    }

    /**
     * @notice Funds from NFT sale can be withdrawn by the owner
     */
    function withdraw(uint256 withdrawAmount) external payable onlyOwner {
        require(withdrawAmount < address(this).balance, "contract does not have enough funds");
        (bool success,) = msg.sender.call{value: withdrawAmount}("");
        require(success, "cannot withdraw funds");
    }

    /**
     * @notice hash member address and coupon number to check for existence in merkle tree
     */
    function _verifyDiscountMembership(address member, uint256 discountCoupon, bytes32[] calldata merkleProof)
        internal
        view
    {
        bytes32 node = keccak256(abi.encode(member, discountCoupon));
        if (!MerkleProof.verify(merkleProof, _merkleRoot, node)) {
            revert("No proof of valid membership");
        }
    }

    /**
     * @notice ensure that there are at most 20 tokens.
     */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize) internal override {
        require(_totalSupply < _MAX_SUPPLY, "token id not within limits");
        ++_totalSupply;
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC2981, ERC721) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
