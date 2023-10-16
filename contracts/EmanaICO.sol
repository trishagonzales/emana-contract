// SPDX-License-Identifier: GPL-3.0
// pragma solidity >=0.7.3 <0.8.21;
pragma solidity 0.8.19;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./Pausable.sol";
import "./Emana.sol";
import "./Interfaces.sol";
import "hardhat/console.sol";

contract EmanaICO is Initializable, Pausable {
    IEmana internal emana;
    IBEP20 internal busd;
    IBEP20 internal usdt;
    IBEP20 internal dai;

    uint public totalRaised;

    address public liquidity;
    address public project;
    address public operation_1;
    address public operation_2;

    struct Refer_Info {
        address referredBy;
    }
    mapping(address => Refer_Info) internal _referrals;

    uint minPurchaseInUsd;
    uint emanaPerUsd;

    uint8 internal constant liquidity_share = 50;
    uint8 internal constant project_share = 30;
    uint8 internal constant operation_share = 5;
    uint8 internal constant refer1_share = 5;
    uint8 internal constant refer2_share = 3;
    uint8 internal constant refer3_share = 2;
    uint8 internal constant SHARE_DIVIDER = 100;

    error MinimumPurchaseNotMet(address from, uint sent, uint needed);
    error TransferPaymentFailed(address from, uint sent);
    event Purchased(address indexed account, uint amount);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address emana_addr,
        address busd_addr,
        address usdt_addr,
        address dai_addr,
        address liquidity_addr,
        address project_addr,
        address operation1_addr,
        address operation2_addr,
        uint _minPurchaseInUsd,
        uint _emanaPerUsd
    ) public initializer {
        __Ownable_init();
        __Pausable_init();

        emana = IEmana(emana_addr);
        busd = IBEP20(busd_addr);
        usdt = IBEP20(usdt_addr);
        dai = IBEP20(dai_addr);

        liquidity = liquidity_addr;
        project = project_addr;
        operation_1 = operation1_addr;
        operation_2 = operation2_addr;

        minPurchaseInUsd = _minPurchaseInUsd;
        emanaPerUsd = _emanaPerUsd;
    }

    function getReferral(address account) public view returns (address) {
        return _referrals[account].referredBy;
    }

    function purchaseUsingBusd(
        uint busdAmount,
        address referrer
    ) public virtual returns (bool) {
        uint minPurchase = _minPurchaseInStableCoin();

        if (busdAmount < minPurchase)
            revert MinimumPurchaseNotMet(msg.sender, busdAmount, minPurchase);
        _distributeBEP20(busd, busdAmount);

        uint emanaAmount = _getEquivalentEmana(busd, busdAmount);

        console.log("minPurchase: %s", minPurchase);
        console.log("busdAmount: %s", busdAmount);
        console.log("minPurchaseInUsd: %s", minPurchaseInUsd);
        console.log("emanaPerUsd: %s", emanaPerUsd);
        console.log("emanaAmount: %s", emanaAmount);

        _distributeEmana(emanaAmount);
        _distributeReferReward(busd, busdAmount, emanaAmount, referrer);

        _transferEmanaToBuyer(emanaAmount);
        return true;
    }

    function purchaseUsingUsdt(
        uint usdtAmount,
        address referrer
    ) public virtual returns (bool) {
        uint minPurchase = _minPurchaseInStableCoin();

        if (usdtAmount < minPurchase)
            revert MinimumPurchaseNotMet(msg.sender, usdtAmount, minPurchase);
        _distributeBEP20(usdt, usdtAmount);

        uint emanaAmount = _getEquivalentEmana(usdt, usdtAmount);
        _distributeEmana(emanaAmount);
        _distributeReferReward(usdt, usdtAmount, emanaAmount, referrer);

        _transferEmanaToBuyer(emanaAmount);
        return true;
    }

    function purchaseUsingDai(
        uint daiAmount,
        address referrer
    ) public virtual returns (bool) {
        uint minPurchase = _minPurchaseInStableCoin();

        if (daiAmount < minPurchase)
            revert MinimumPurchaseNotMet(msg.sender, daiAmount, minPurchase);
        _distributeBEP20(dai, daiAmount);

        uint emanaAmount = _getEquivalentEmana(dai, daiAmount);
        _distributeEmana(emanaAmount);
        _distributeReferReward(dai, daiAmount, emanaAmount, referrer);

        _transferEmanaToBuyer(emanaAmount);
        return true;
    }

    function _minPurchaseInStableCoin() internal view virtual returns (uint) {
        return minPurchaseInUsd * 1 ether;
    }

    function _distributeBEP20(IBEP20 token, uint amount) internal virtual {
        bool success = token.transferFrom(msg.sender, address(this), amount);
        if (!success) revert TransferPaymentFailed(msg.sender, amount);

        _transferBEP20(token, liquidity, amount, liquidity_share);
        _transferBEP20(token, project, amount, project_share);
        _distributeBEP20ToOperation(token, amount);
    }

    function _distributeBEP20ToOperation(
        IBEP20 token,
        uint amount
    ) internal virtual {
        _transferBEP20(token, operation_1, amount, operation_share);
        _transferBEP20(token, operation_2, amount, operation_share);
    }

    function _distributeEmana(uint amount) internal virtual {
        _transferEmana(liquidity, amount, liquidity_share);
        _distributeEmanaToOperation(amount);
    }

    function _distributeEmanaToOperation(uint amount) internal virtual {
        _transferEmana(operation_1, amount, operation_share);
        _transferEmana(operation_2, amount, operation_share);
    }

    function _transferEmanaToBuyer(uint amount) internal virtual {
        emana.governanceTransfer(msg.sender, amount);
        emit Purchased(msg.sender, amount);
    }

    function _transferBEP20(
        IBEP20 token,
        address to,
        uint amount,
        uint8 share
    ) internal virtual {
        bool success = token.transfer(to, _getShare(amount, share));
        if (!success) revert TransferPaymentFailed(msg.sender, amount);
    }

    function _transferEmana(
        address to,
        uint amount,
        uint8 share
    ) internal virtual {
        console.log("_transferEmana to: %s", to);
        console.log("_transferEmana amount: %s", amount);
        console.log("_transferEmana share: %s", share);

        require(
            emana.governanceTransfer(to, _getShare(amount, share)),
            "EmanaICO: Transfer Emana failed"
        );
    }

    function _getShare(
        uint amount,
        uint8 share
    ) internal pure virtual returns (uint) {
        return (amount * share) / SHARE_DIVIDER;
    }

    function _getEquivalentEmana(
        IBEP20 token,
        uint amount
    ) internal view virtual returns (uint) {
        return ((amount / (10 ** token.decimals())) * emanaPerUsd);
    }

    function _distributeReferReward(
        IBEP20 token,
        uint paymentAmount,
        uint emanaAmount,
        address referrer
    ) internal virtual {
        address referredBy = _referrals[msg.sender].referredBy;
        address level1 = referredBy == address(0) ? referrer : referredBy;

        bool theresNoReferral = level1 == address(0);
        if (theresNoReferral) {
            _distributeBEP20ToOperation(token, paymentAmount);
            _distributeEmanaToOperation(emanaAmount);
        } else {
            address level2 = _referrals[level1].referredBy;
            address level3 = _referrals[level2].referredBy;

            _setNewReferral(level1);
            _transferBEP20(token, level1, paymentAmount, refer1_share);
            _transferEmana(level1, emanaAmount, refer1_share);

            if (level2 != address(0)) {
                _transferBEP20(token, level2, paymentAmount, refer2_share);
                _transferEmana(level2, emanaAmount, refer2_share);
            }
            if (level3 != address(0)) {
                _transferBEP20(token, level3, paymentAmount, refer3_share);
                _transferEmana(level3, emanaAmount, refer3_share);
            }
        }
    }

    function _setNewReferral(address referrer) internal virtual {
        _referrals[msg.sender].referredBy = referrer;
    }

    function tweakSettings(
        uint _minPurchaseInUsd,
        uint _emanaPerUsd
    ) public virtual onlyOwner {
        minPurchaseInUsd = _minPurchaseInUsd;
        emanaPerUsd = _emanaPerUsd;
    }

    receive() external payable {}

    fallback() external payable {}

    uint256[40] private __gap;
}
