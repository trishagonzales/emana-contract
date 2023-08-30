// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.19;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./Pausable.sol";
import "./Emana.sol";

contract EmanaICO is Initializable, Pausable {
    IBEP20 public busd;
    IEmana public emana;

    address public liquidity;
    address public project;
    address public operation_1;
    address public operation_2;

    mapping(address => Refer_Info) private referrals;
    struct Refer_Info {
        address referredBy;
    }

    Settings public settings;

    struct Settings {
        uint256 minimumPurchaseInWei;
        uint256 emanaAmountPerUsd;
    }

    Percentage public percent;

    struct Percentage {
        uint8 liquidity;
        uint8 project;
        uint8 operation;
        uint8 referLevel_1;
        uint8 referLevel_2;
        uint8 referLevel_3;
    }

    uint8 constant PERCENT_DIVIDER = 100;

    error MinimumPurchaseNotReached(address account, uint256 value);

    event Purchase(address indexed account, uint256 amount);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    // Setup

    function initialize(
        address emana_address,
        address liquidity_address,
        address project_address,
        address operation_1_address,
        address operation_2_address,
        uint32 minimumPurchaseInUsd,
        uint32 _emanaAmountPerUsd,
        uint8 liquidity_percent,
        uint8 project_percent,
        uint8 operation_percent,
        uint8 referLevel_1_percent,
        uint8 referLevel_2_percent,
        uint8 referLevel_3_percent
    ) public initializer {
        emana = IEmana(emana_address);

        liquidity = liquidity_address;
        project = project_address;
        operation_1 = operation_1_address;
        operation_2 = operation_2_address;

        settings = Settings({
            minimumPurchaseInWei: minimumPurchaseInUsd * 1 ether,
            emanaAmountPerUsd: _emanaAmountPerUsd
        });

        percent = Percentage({
            liquidity: liquidity_percent,
            project: project_percent,
            operation: operation_percent,
            referLevel_1: referLevel_1_percent,
            referLevel_2: referLevel_2_percent,
            referLevel_3: referLevel_3_percent
        });
    }

    // function purchaseUsingBnb() external payable {
    //     address buyer = msg.sender;
    //     uint256 amount = msg.value;
    // }

    function purchaseUsingBusd(uint256 amount, address referrer) external {
        Settings memory _settings = settings;

        if (amount < _settings.minimumPurchaseInWei) {
            revert MinimumPurchaseNotReached(msg.sender, amount);
        }

        uint256 totalEmana = (amount / 1e18) * _settings.emanaAmountPerUsd;
        Percentage memory _percent = percent;

        busd.transferFrom(msg.sender, address(this), amount);
        busd.transfer(liquidity, _computeShare(amount, _percent.liquidity));
        busd.transfer(project, _computeShare(amount, _percent.project));
        busd.transfer(operation_1, _computeShare(amount, _percent.operation));
        busd.transfer(operation_2, _computeShare(amount, _percent.operation));

        emana.governanceTransfer(
            liquidity,
            _computeShare(totalEmana, _percent.liquidity)
        );
        emana.governanceTransfer(
            operation_1,
            _computeShare(totalEmana, _percent.operation)
        );
        emana.governanceTransfer(
            operation_2,
            _computeShare(totalEmana, _percent.operation)
        );

        if (referrer == address(0)) {
            busd.transfer(
                operation_1,
                _computeShare(amount, _percent.operation)
            );
            busd.transfer(
                operation_2,
                _computeShare(amount, _percent.operation)
            );
            emana.governanceTransfer(
                operation_1,
                _computeShare(totalEmana, _percent.operation)
            );
            emana.governanceTransfer(
                operation_2,
                _computeShare(totalEmana, _percent.operation)
            );
        } else {
            referrals[msg.sender].referredBy = referrer;

            address level1 = referrer;
            address level2 = referrals[level1].referredBy;
            address level3 = referrals[level2].referredBy;

            busd.transfer(level1, _computeShare(amount, _percent.referLevel_1));
            emana.governanceTransfer(
                level1,
                _computeShare(totalEmana, _percent.referLevel_1)
            );

            if (level2 != address(0)) {
                busd.transfer(
                    level2,
                    _computeShare(amount, _percent.referLevel_2)
                );
                emana.governanceTransfer(
                    level2,
                    _computeShare(totalEmana, _percent.referLevel_2)
                );
            }

            if (level3 != address(0)) {
                busd.transfer(
                    level3,
                    _computeShare(amount, _percent.referLevel_3)
                );
                emana.governanceTransfer(
                    level3,
                    _computeShare(totalEmana, _percent.referLevel_3)
                );
            }
        }

        emana.governanceTransfer(msg.sender, totalEmana);
        emit Purchase(msg.sender, totalEmana);
    }

    function _computeShare(
        uint amount,
        uint8 _percent
    ) private pure returns (uint) {
        return (amount * _percent) / PERCENT_DIVIDER;
    }

    function tweakSettings(
        Settings calldata _settings
    ) external onlyOwner returns (bool) {
        settings = _settings;
        return true;
    }
}

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address _owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

interface IEmana {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function pause() external;

    function unpause() external;

    function mint(uint256 amount) external;

    function burn(uint256 amount) external;

    function governanceTransferFrom(
        address from,
        address to,
        uint256 amount
    ) external;

    function governanceTransfer(address to, uint256 amount) external;
}
