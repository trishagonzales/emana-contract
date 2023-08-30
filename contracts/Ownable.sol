// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

abstract contract Ownable is Initializable {
    address private _owner;
    mapping(address => bool) private _isGovernor;

    error Ownable_UnauthorizedAccount(address account);
    error Ownable_InvalidAddress(address account);

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

    // Guards

    function _revertIfNotOwner() internal view {
        if (_owner != msg.sender) {
            revert Ownable_UnauthorizedAccount(msg.sender);
        }
    }

    function _revertIfNotGovernor() internal view {
        if (_owner != msg.sender || !_isGovernor[msg.sender]) {
            revert Ownable_UnauthorizedAccount(msg.sender);
        }
    }

    // Public functions

    function grantGovernance(address governor) external onlyOwner {
        _isGovernor[governor] = true;
    }

    function revokeGovernance(address governor) external onlyOwner {
        _isGovernor[governor] = false;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner == address(0)) {
            revert Ownable_InvalidAddress(address(0));
        }

        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    uint256[49] private __gap;
}
