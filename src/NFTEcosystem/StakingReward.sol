// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {Ownable2Step} from "openzeppelin-contracts/contracts/access/Ownable2Step.sol";

/**
 * @title Staking Reward Token
 * @author Walter Cavinaw
 * @notice An ERC20 token that is issues in return for staking NFTs
 */
contract StakingReward is ERC20, Ownable2Step {
    mapping(address => bool) private _operators;

    modifier onlyOperators() {
        require(_operators[msg.sender] || msg.sender == owner(), "Only operators can mint and burn");
        _;
    }

    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {}

    /**
     * @notice Only reward operators can mint new coins (in exchange for the receiver staking NFTs)
     * @param to_ address of wallet receiving tokens.
     * @param amount_ amount of tokens to receive.
     */
    function mint(address to_, uint256 amount_) external payable onlyOperators {
        _mint(to_, amount_);
    }

    /**
     * @notice Only reward operators can burn (in exchange for returning staked NFTs)
     * @param from_ address of wallet receiving tokens.
     * @param amount_ amount of tokens to return.
     */
    function burn(address from_, uint256 amount_) external payable onlyOperators {
        _burn(from_, amount_);
    }

    /**
     * @notice The owner of the staking service can set new reward operators
     * @param operator_ wallet that can act as operator.
     * @param set_ whether to activate or deactivate that wallet as an operator.
     */
    function setOperator(address operator_, bool set_) external onlyOwner {
        _operators[operator_] = set_;
    }
}
