// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {IERC721Receiver} from "openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
import {Ownable2Step} from "openzeppelin-contracts/contracts/access/Ownable2Step.sol";
import {NFTWithLimitedSupply} from "./NFTWithLimitedSupply.sol";
import {StakingReward} from "./StakingReward.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title NFT Collateral Bank
 * @author Walter Cavinaw
 * @notice A bank which provides demand deposits in exchange for NFT collateral
 * @dev Can deposit NFTs in exchange for StakingReward tokens and receive NFT by returning them.
 */
contract NFTCollateralBank is IERC721Receiver, Ownable2Step {
    using SafeERC20 for StakingReward;

    StakingReward private immutable _stakingReward;
    NFTWithLimitedSupply private immutable _nftProvider;

    uint256 private constant _NFT_COLLATERAL_VALUE = 10;

    mapping(uint256 => address) private _tokenDepositLedger;
    mapping(uint256 => uint256) private _lastDeposit;

    constructor(address stakingReward_, address nftProvider_) {
        _stakingReward = StakingReward(stakingReward_);
        _nftProvider = NFTWithLimitedSupply(nftProvider_);
    }

    /**
     * @notice users can deposit an NFT and receive StakingRewards.
     * @param tokenId the token which they want to deposit for StakingRewards.
     */
    function deposit(uint256 tokenId) external {
        require((_lastDeposit[tokenId] + 1 days < block.timestamp), "Too soon to deposit again");
        _lastDeposit[tokenId] = block.timestamp;

        _tokenDepositLedger[tokenId] = msg.sender;
        _nftProvider.safeTransferFrom(msg.sender, address(this), tokenId);

        _stakingReward.mint(msg.sender, _NFT_COLLATERAL_VALUE * (10 ** _stakingReward.decimals()));
    }

    /**
     * @notice users can request to redeem their NFT by giving up StakingRewards.
     * @param tokenId the token which they want to redeem for StakingRewards.
     */
    function redeem(uint256 tokenId) external {
        require(msg.sender == _tokenDepositLedger[tokenId], "This tokenId does not belong to you");
        _nftProvider.safeTransferFrom(address(this), msg.sender, tokenId);
        _stakingReward.burn(msg.sender, _NFT_COLLATERAL_VALUE * (10 ** _stakingReward.decimals()));
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external
        pure
        returns (bytes4 selector)
    {
        selector = IERC721Receiver.onERC721Received.selector;
    }

    function onERC721Received(address operator, address from, uint256 tokenId)
        external
        pure
        returns (bytes4 selector)
    {
        selector = IERC721Receiver.onERC721Received.selector;
    }
}
