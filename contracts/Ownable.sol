// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "hardhat/console.sol";

abstract contract Ownable is Initializable {
    address internal _owner;
    mapping(address => bool) internal _isGovernor;

    error UnauthorizedAccount(address account);
    error InvalidAddress(address account);

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    function __Ownable_init() internal onlyInitializing {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        _revertIfNotOwner();
        _;
    }

    modifier onlyGovernors() {
        _revertIfNotGovernor();
        _;
    }

    function _revertIfNotOwner() internal view virtual {
        if (msg.sender != _owner) revert UnauthorizedAccount(msg.sender);
    }

    function _revertIfNotGovernor() internal view virtual {
        if (msg.sender != _owner && _isGovernor[msg.sender] == false) {
            console.log("Sender in Ownable: %s", msg.sender);
            console.log("isGovernor in Ownable: %s", _isGovernor[msg.sender]);
            revert UnauthorizedAccount(msg.sender);
        }
    }

    function grantGovernance(address governor) public virtual onlyOwner {
        _isGovernor[governor] = true;
    }

    function revokeGovernance(address governor) public virtual onlyOwner {
        _isGovernor[governor] = false;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) revert InvalidAddress(newOwner);

        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function isGovernor(address addr) public view virtual returns (bool) {
        return _isGovernor[addr];
    }
}
