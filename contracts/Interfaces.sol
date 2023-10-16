// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

interface IBEP20 {
    function totalSupply() external view returns (uint);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(
        address _owner,
        address spender
    ) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

interface IEmana is IBEP20 {
    function mint(uint amount) external returns (bool);

    function burn(uint amount) external returns (bool);

    function governanceTransferFrom(
        address from,
        address to,
        uint amount
    ) external returns (bool);

    function governanceTransfer(
        address to,
        uint amount
    ) external returns (bool);

    error ERC20InvalidSender(address sender);
    error ERC20InvalidReceiver(address receiver);
    error ERC20InsufficientBalance(address sender, uint balance, uint needed);

    error ERC20InvalidSpender(address spender);
    error ERC20InvalidApprover(address approver);
    error ERC20InsufficientAllowance(
        address spender,
        uint allowance,
        uint needed
    );
    error ERC20FailedDecreaseAllowance(
        address spender,
        uint currentAllowance,
        uint requestedDecrease
    );
    error ERC20InsufficientBalanceForBurn(
        address account,
        uint balance,
        uint needed
    );
}

interface IPancakeRouter {
    function WETH() external pure returns (address);

    function getAmountsIn(
        uint256 amountOut,
        address[] calldata path
    ) external view returns (uint256[] memory amounts);
}
