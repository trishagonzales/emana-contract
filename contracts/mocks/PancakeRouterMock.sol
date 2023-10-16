/**
 *Submitted for verification at BscScan.com on 2021-04-23
 */
 
// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.6.6;

contract PancakeRouterMock {
    function getAmountsIn(
        uint amountOut,
        address[] memory
    ) public pure virtual returns (uint[2] memory) {
        // return PancakeLibrary.getAmountsIn(factory, amountOut, path);
        uint[2] memory amounts = [(47 * 10 ** 14), amountOut];
        return amounts;
    }
}
