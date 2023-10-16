// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./Pausable.sol";
import "./Interfaces.sol";
import "hardhat/console.sol";

contract Emana is IEmana, Initializable, Pausable {
    mapping(address => uint) internal _balances;
    mapping(address => mapping(address => uint)) internal _allowances;

    uint public totalSupply;
    string public constant name = "Emana Token";
    string public constant symbol = "EMANA";
    uint8 public constant decimals = 18;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        console.log("Owner in Emana: %s", owner());
        __Ownable_init();
        console.log("Owner in Emana after set: %s", owner());
        __Pausable_init();
        console.log("Owner in Emana after pausable: %s", owner());

        _mint(owner(), 10000000000 * 10 ** decimals); // ten billion
    }

    function getOwner() public view returns (address) {
        console.log("Owner in getOwner: %s", owner());
        console.log("Balance in getOwner: %s", balanceOf(owner()));
        return owner();
    }

    function balanceOf(address account) public view virtual returns (uint) {
        return _balances[account];
    }

    function transfer(address to, uint amount) public virtual returns (bool) {
        address owner = msg.sender;
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(
        address owner,
        address spender
    ) public view virtual returns (uint) {
        return _allowances[owner][spender];
    }

    function approve(
        address spender,
        uint amount
    ) public virtual returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint amount
    ) public virtual returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(
        address spender,
        uint addedValue
    ) public virtual returns (bool) {
        address owner = msg.sender;
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint subtractedValue
    ) public virtual returns (bool) {
        address owner = msg.sender;
        uint currentAllowance = allowance(owner, spender);

        if (currentAllowance < subtractedValue) {
            revert ERC20FailedDecreaseAllowance(
                spender,
                currentAllowance,
                subtractedValue
            );
        }

        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function mint(uint amount) public virtual onlyOwner returns (bool) {
        _mint(owner(), amount);
        return true;
    }

    function burn(uint amount) public virtual onlyOwner returns (bool) {
        _burn(owner(), amount);
        return true;
    }

    function governanceTransferFrom(
        address from,
        address to,
        uint amount
    ) public virtual onlyGovernors returns (bool) {
        _transfer(from, to, amount);
        return true;
    }

    function governanceTransfer(
        address to,
        uint amount
    ) public virtual onlyGovernors returns (bool) {
        _transfer(owner(), to, amount);
        return true;
    }

    function _transfer(
        address from,
        address to,
        uint amount
    ) internal virtual whenNotPaused {
        if (from == address(0)) revert ERC20InvalidSender(from);
        if (to == address(0)) revert ERC20InvalidReceiver(to);

        uint fromBalance = _balances[from];
        if (fromBalance < amount) {
            revert ERC20InsufficientBalance(from, fromBalance, amount);
        }

        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);
    }

    function _mint(
        address account,
        uint amount
    ) internal virtual whenNotPaused {
        if (account == address(0)) revert ERC20InvalidReceiver(account);

        totalSupply += amount;
        unchecked {
            _balances[account] += amount;
        }

        emit Transfer(address(0), account, amount);
    }

    function _burn(
        address account,
        uint amount
    ) internal virtual whenNotPaused {
        if (account == address(0)) revert ERC20InvalidSender(account);

        uint accountBalance = _balances[account];
        if (accountBalance < amount)
            revert ERC20InsufficientBalanceForBurn(
                account,
                accountBalance,
                amount
            );

        unchecked {
            _balances[account] = accountBalance - amount;
            totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint amount
    ) internal virtual whenNotPaused {
        if (owner == address(0)) revert ERC20InvalidApprover(owner);
        if (spender == address(0)) revert ERC20InvalidSpender(spender);

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _spendAllowance(
        address owner,
        address spender,
        uint amount
    ) internal virtual whenNotPaused {
        uint currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint).max) {
            if (currentAllowance < amount) {
                revert ERC20InsufficientAllowance(
                    spender,
                    currentAllowance,
                    amount
                );
            }

            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    uint[40] private __gap;
}
