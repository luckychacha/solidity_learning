// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

// dependence
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol";

// local
import "./UsdEthPairConverter.sol";

interface IERC20SafeTransfer {
    function safeTransfer(address to, uint256 amount) external returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
error MustBeContractOwner();
error SalaryPaymentUpkeepCannotBeFulfilled();
error CannotSendMoney();

contract Payroll is
    UsdEthPairConverter,
    IERC20SafeTransfer,
    IERC165,
    AutomationCompatibleInterface,
    ReentrancyGuard,
    Ownable
{
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    mapping(bytes4 => bool) private _supportedInterfaces;

    // 365/12
    uint256 private constant PAYMENT_INTERVAL = 30.42 days;

    uint256 public lastPaymentTimestamp;
    uint public employersMappingLength;
    IERC20 private _token;

    struct Employee {
        address account;
        uint256 salary;
        bool isTerminated;
        uint256 terminationTime;
        bool hasFinalPayment;
    }

    mapping(uint => Employee) public employees;

    enum salaryPaymentStatus {
        OPEN,
        SENDING,
        CLOSED
    }
    salaryPaymentStatus public statusSalaryPayment;

    modifier MustBeOwnerOfContract() {
        if (msg.sender == owner()) {
            revert MustBeContractOwner();
        }
        _;
    }

    constructor(address tokenAddress) {
        _token = IERC20(tokenAddress);

        // Add supported interface IDs
        _registerInterface(type(IERC20SafeTransfer).interfaceId);
        statusSalaryPayment = salaryPaymentStatus.OPEN;
    }

    function safeTransfer(
        address to,
        uint256 amount
    ) external override returns (bool) {
        _token.safeTransfer(to, amount);
        return true;
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 amount
    ) external override returns (bool) {
        _token.safeTransferFrom(from, to, amount);
        return true;
    }

    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff, "Invalid interface ID");
        _supportedInterfaces[interfaceId] = true;
    }

    // implement IERC165
    // Implementers can declare support of contract interfaces.
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    // external or public
    function checkUpkeep(
        bytes memory /* checkData */
    )
        public
        view
        override
        returns (
            // external
            bool upkeepNeeded,
            bytes memory performData
        )
    {
        uint256 currentTimestamp = block.timestamp;
        uint256 nextPaymentTimestamp = lastPaymentTimestamp + PAYMENT_INTERVAL;
        // uint256 requiredTokenAmount = getTotalTokenAmount();

        if (currentTimestamp <= nextPaymentTimestamp) {
            return (false, "");
        }

        if (employersMappingLength <= 0) {
            return (false, "");
        }
        if (statusSalaryPayment != salaryPaymentStatus.OPEN) {
            return (false, "");
        }
        // if (token.balanceOf(address(this)) < requiredTokenAmount) {
        //     return (false, "");
        // }

        return (true, "");
    }

    function performUpkeep(
        bytes calldata /* performData */
    ) external override nonReentrant {
        (bool upKeepNeeded, ) = checkUpkeep("");
        if (!upKeepNeeded) {
            revert SalaryPaymentUpkeepCannotBeFulfilled();
        }
        statusSalaryPayment = salaryPaymentStatus.SENDING;

        for (uint i = 0; i < employersMappingLength; i++) {
            uint salaryInEth = employees[i].salary *
                getAnUsdPriceInTermsOfEther();
            address addressToGetPaid = employees[i].account;

            (bool success, ) = addressToGetPaid.call{value: salaryInEth}("");
            if (!success) {
                revert CannotSendMoney();
            }
        }
        statusSalaryPayment = salaryPaymentStatus.OPEN;
        lastPaymentTimestamp = block.timestamp;
    }
}
