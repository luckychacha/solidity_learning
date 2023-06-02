// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

// dependence
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol";

interface IERC20SafeTransfer {
    function safeTransfer(address to, uint256 amount) external returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
error NotContractOwner();
error SalaryPaymentUpkeepCannotBeFulfilled();
error CannotSendMoney();
error MustBeEqualLength();
error EmployeeAddressesDuplicated();
error NotEnoughMoneyProvided();
error Overflowed();

contract Payroll is
    ERC20,
    IERC20SafeTransfer,
    IERC165,
    AutomationCompatibleInterface,
    ReentrancyGuard,
    Ownable
{
    event Init(
        uint256 timestamp,
        uint256 oneYearPayment,
        uint256 employersMappingLength
    );
    event TerminatedPayment(
        uint256 timestamp,
        address account,
        uint256 unpaidSalary
    );
    event PayrollPayment(uint256 timestamp, address account, uint256 salary);
    event TerminateEmployee(
        uint256 timestamp,
        address account,
        uint256 terminationTime
    );
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    mapping(bytes4 => bool) private _supportedInterfaces;

    // 365/12
    uint256 private constant PAYMENT_INTERVAL = 30.42 days;
    uint256 private constant TERMINTATE_NOTICE_INTERVAL = 30 days;

    // uint256 private constant PAYMENT_INTERVAL = 1 minutes;
    // uint256 private constant TERMINTATE_NOTICE_INTERVAL = 55 seconds;

    uint256 public lastPaymentTimestamp;
    uint256 public employersMappingLength;
    IERC20 private _token;
    address[] public employeeAddressList;
    uint256[] public salaryAmountArray;
    uint public terminatedEmployeeCount;
    uint256 public nextTerminatedTimestamp;

    struct Employee {
        address account;
        uint256 salary;
        bool isTerminated;
        uint256 terminationTime;
        bool hasFinalRoundPayment;
    }

    mapping(uint256 => Employee) public employees;

    enum salaryPaymentStatus {
        OPEN,
        SENDING,
        CLOSED
    }
    salaryPaymentStatus public statusSalaryPayment;

    constructor(
        address[] memory _employeeAddressList,
        uint256[] memory _salaryAmountArray
    )
        ERC20("PayRoll Token", "PRT")
        checkIfListsHaveSameLength(_employeeAddressList, _salaryAmountArray)
    {
        // Add supported interface IDs
        _registerInterface(type(IERC20SafeTransfer).interfaceId);
        statusSalaryPayment = salaryPaymentStatus.OPEN;

        for (uint i = 0; i < _salaryAmountArray.length; i++) {
            employeeAddressesMustBeUnique(
                _employeeAddressList[i],
                _employeeAddressList
            ); // To check the uniqueness of the addresses
            employersMappingLength += 1;
            employees[i] = Employee(
                _employeeAddressList[i],
                _salaryAmountArray[i],
                false,
                0,
                false
            );
            employeeAddressList.push(_employeeAddressList[i]);
            salaryAmountArray.push(_salaryAmountArray[i]);
        }
        uint256 oneYearPayment = calculateOneYearPayment(_salaryAmountArray);
        _mint(address(this), oneYearPayment);
        _token = IERC20(address(this));
        terminatedEmployeeCount = 0;
        lastPaymentTimestamp = block.timestamp;
        emit Init(block.timestamp, oneYearPayment, employersMappingLength);
    }

    function safeTransfer(
        address to,
        uint256 amount
    ) external override returns (bool) {
        SafeERC20.safeTransfer(_token, to, amount);
        return true;
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 amount
    ) external override returns (bool) {
        SafeERC20.safeTransferFrom(_token, from, to, amount);
        return true;
    }

    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff, "Invalid interface ID");
        _supportedInterfaces[interfaceId] = true;
    }

    // auto dispense
    function performUpkeep(
        bytes calldata performData
    ) external override nonReentrant {
        (bool upKeepNeeded, ) = checkUpkeep("");
        if (!upKeepNeeded) {
            revert SalaryPaymentUpkeepCannotBeFulfilled();
        }

        statusSalaryPayment = salaryPaymentStatus.SENDING;
        bool performForTerminated = abi.decode(performData, (bool));
        if (performForTerminated) {
            if (terminatedEmployeeCount <= 0 || nextTerminatedTimestamp == 0) {
                return;
            }
            terminatedEmployeePayment();
        } else {
            payrollPayment();
        }
        statusSalaryPayment = salaryPaymentStatus.OPEN;
    }

    function terminatedEmployeePayment() private {
        uint256 minTimestamp = 0;
        uint256 timestamp = block.timestamp;

        for (uint i = 0; i < employersMappingLength; i++) {
            if (
                employees[i].account == address(0) || !employees[i].isTerminated
            ) {
                continue;
            }
            if (employees[i].terminationTime > timestamp) {
                if (minTimestamp > employees[i].terminationTime) {
                    minTimestamp = employees[i].terminationTime;
                }
                continue;
            }
            uint256 unpaidSeconds = employees[i].terminationTime -
                lastPaymentTimestamp;
            uint256 unpaidSalary = 0;
            if (unpaidSeconds > 0) {
                unpaidSalary = employees[i].salary.mul(unpaidSeconds).div(
                    PAYMENT_INTERVAL
                );
                address addressToGetPaid = employees[i].account;
                bool success = _token.transfer(addressToGetPaid, unpaidSalary);

                if (!success) {
                    revert CannotSendMoney();
                }
            }
            emit TerminatedPayment(
                block.timestamp,
                employees[i].account,
                unpaidSalary
            );

            employees[i].terminationTime = 0;
            terminatedEmployeeCount -= 1;
            delete employees[i];
            delete employeeAddressList[i];
            delete salaryAmountArray[i];
        }

        nextTerminatedTimestamp = minTimestamp;
    }

    function payrollPayment() private {
        for (uint i = 0; i < employersMappingLength; i++) {
            if (employees[i].account == address(0)) {
                continue;
            }
            if (
                employees[i].isTerminated && employees[i].hasFinalRoundPayment
            ) {
                continue;
            }

            address addressToGetPaid = employees[i].account;
            bool success = _token.transfer(
                addressToGetPaid,
                employees[i].salary
            );
            if (!success) {
                revert CannotSendMoney();
            }
            if (employees[i].isTerminated) {
                employees[i].hasFinalRoundPayment = true;
            }
            emit PayrollPayment(
                block.timestamp,
                employees[i].account,
                employees[i].salary
            );
        }
        lastPaymentTimestamp = block.timestamp;
    }

    receive() external payable {}

    // ======= View =======
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
        bool hasEnoughBalance = (balanceOf(address(this)) >=
            calculateEachTimePayment(salaryAmountArray));

        bool timestampDurationPass = (block.timestamp >=
            (lastPaymentTimestamp + PAYMENT_INTERVAL));
        bool hasEmployee = (employersMappingLength > 0);
        bool statusIsOpen = (statusSalaryPayment == salaryPaymentStatus.OPEN);

        bool performForTerminated = (terminatedEmployeeCount > 0 &&
            block.timestamp >= nextTerminatedTimestamp);
        bool performForPayroll = (
            (timestampDurationPass && hasEmployee && statusIsOpen)
        );

        upkeepNeeded = ((performForPayroll || performForTerminated) &&
            hasEnoughBalance);

        performData = abi.encode(performForTerminated);
        return (upkeepNeeded, performData);
    }

    function employeeAddressesMustBeUnique(
        address _employeeAddress,
        address[] memory _employeeAddressList
    ) private view {
        for (uint i = 0; i < employersMappingLength; i++) {
            if (_employeeAddress == _employeeAddressList[i]) {
                revert EmployeeAddressesDuplicated();
            }
        }
    }

    function calculateOneYearPayment(
        uint256[] memory _salaryAmountArray
    ) public view returns (uint256) {
        uint256 a = calculateEachTimePayment(_salaryAmountArray);
        (bool mulSucceed, uint256 oneYearPayment) = SafeMath.tryMul(a, 12);

        if (!mulSucceed) {
            revert Overflowed();
        }
        return oneYearPayment;
    }

    function calculateEachTimePayment(
        uint256[] memory _salaryAmountArray
    ) public view returns (uint256) {
        uint256 totalAmountRequiredEachPayment;

        for (uint256 i = 0; i < employersMappingLength; i++) {
            (bool addSucceed, uint addedValue) = SafeMath.tryAdd(
                totalAmountRequiredEachPayment,
                _salaryAmountArray[i]
            );
            if (!addSucceed) {
                revert Overflowed();
            }
            totalAmountRequiredEachPayment = addedValue;
        }

        return totalAmountRequiredEachPayment;
    }

    // ============ Ownable =============
    function terminate(
        address _terminatedAddress
    ) public MustBeOwnerOfContract {
        for (uint i = 0; i < employersMappingLength; i++) {
            if (employees[i].account == _terminatedAddress) {
                employees[i].isTerminated = true;

                uint256 terminationTime = block.timestamp +
                    TERMINTATE_NOTICE_INTERVAL;
                employees[i].terminationTime = terminationTime;
                if (terminationTime > lastPaymentTimestamp + PAYMENT_INTERVAL) {
                    employees[i].hasFinalRoundPayment = false;
                } else {
                    employees[i].hasFinalRoundPayment = true;
                }

                terminatedEmployeeCount += 1;
                if (nextTerminatedTimestamp == 0) {
                    nextTerminatedTimestamp = terminationTime;
                }
                emit TerminateEmployee(
                    block.timestamp,
                    employees[i].account,
                    terminationTime
                );

                break;
            }
        }
    }

    function mintOneYearPayment() public MustBeOwnerOfContract {
        uint256 oneYearPayment = calculateOneYearPayment(salaryAmountArray);
        _mint(address(this), oneYearPayment);
    }

    //  ======= modifiers =======
    modifier MustBeOwnerOfContract() {
        if (msg.sender != owner()) {
            revert NotContractOwner();
        }
        _;
    }

    modifier checkIfListsHaveSameLength(
        address[] memory _employeeAddressList,
        uint[] memory _salaryAmountArray
    ) {
        if (_employeeAddressList.length != _salaryAmountArray.length) {
            revert MustBeEqualLength();
        }
        _;
    }
}
