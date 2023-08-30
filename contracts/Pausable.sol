// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./Ownable.sol";

abstract contract Pausable is Initializable, Ownable {
    bool private _paused;

    event Paused(address account);
    event Unpaused(address account);

    error UnpausedStateRequired();
    error PausedStateRequired();

    function __Pausable_init() internal onlyInitializing {
        __Ownable_init();

        _paused = false;
    }

    modifier whenNotPaused() {
        if (isPaused()) revert UnpausedStateRequired();
        _;
    }

    modifier whenPaused() {
        if (!isPaused()) revert PausedStateRequired();
        _;
    }

    function pause() public onlyOwner whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() public onlyOwner whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }

    function isPaused() public view returns (bool) {
        return _paused;
    }

    uint256[4] private __gap;
}
