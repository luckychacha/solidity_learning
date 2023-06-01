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
    event Logger(address a, uint256 oneYearPayment);
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    mapping(bytes4 => bool) private _supportedInterfaces;

    // 365/12
    uint256 private constant PAYMENT_INTERVAL = 40 seconds;
    // uint256 private constant PAYMENT_INTERVAL = 30.42 days;

    uint256 private constant TERMINTATE_NOTICE_INTERVAL = 30 days;

    uint256 public lastPaymentTimestamp;
    uint256 public employersMappingLength;
    IERC20 private _token;
    address[] public employeeAddressList;
    uint256[] public salaryAmountArray;
    uint terminatedEmployeeCount;

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
        approve(address(this), oneYearPayment);
        _token = IERC20(address(this));
        terminatedEmployeeCount = 0;
        lastPaymentTimestamp = block.timestamp;
    }

    // terminate
    function terminate(
        address _terminatedAddress
    ) public MustBeOwnerOfContract {
        for (uint i = 0; i < employersMappingLength; i++) {
            if (employees[i].account == _terminatedAddress) {
                employees[i].isTerminated = true;

                uint256 terminationTime = block.timestamp +
                    TERMINTATE_NOTICE_INTERVAL;
                employees[i].terminationTime = terminationTime;
                if (terminationTime > block.timestamp + PAYMENT_INTERVAL) {
                    employees[i].hasFinalRoundPayment = false;
                } else {
                    employees[i].hasFinalRoundPayment = true;
                }

                terminatedEmployeeCount += 1;
            }
        }
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

        bool performForTerminated = terminatedEmployeeCount > 0;
        bool performForPayroll = (
            (timestampDurationPass && hasEmployee && statusIsOpen)
        );

        upkeepNeeded = ((performForPayroll || performForTerminated) &&
            hasEnoughBalance);

        performData = abi.encode(performForTerminated);
        return (upkeepNeeded, performData);
    }

    function performUpkeep(
        bytes calldata performData
    ) external override nonReentrant {
        (bool upKeepNeeded, ) = checkUpkeep("");
        if (!upKeepNeeded) {
            revert SalaryPaymentUpkeepCannotBeFulfilled();
        }

        statusSalaryPayment = salaryPaymentStatus.SENDING;
        bool performForTerminated = abi.decode(performData, (bool));

        for (uint i = 0; i < employersMappingLength; i++) {
            // performForTerminated
            if (performForTerminated && terminatedEmployeeCount > 0) {
                if (!employees[i].isTerminated) {
                    continue;
                }
                uint256 unpaidSeconds = employees[i].terminationTime -
                    lastPaymentTimestamp;

                if (unpaidSeconds > 0) {
                    uint unpaidSalary = employees[i]
                        .salary
                        .mul(unpaidSeconds)
                        .div(PAYMENT_INTERVAL);
                    address addressToGetPaid = employees[i].account;
                    bool success = _token.transfer(
                        addressToGetPaid,
                        unpaidSalary
                    );

                    if (!success) {
                        revert CannotSendMoney();
                    }
                }
                employees[i].terminationTime = 0;
                employees[i].isTerminated = true;
                terminatedEmployeeCount -= 1;
                delete employees[i];
                delete employeeAddressList[i];
                delete salaryAmountArray[i];
            } else {
                // performForPayroll
                if (
                    employees[i].isTerminated &&
                    employees[i].hasFinalRoundPayment
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
                lastPaymentTimestamp = block.timestamp;
            }
        }
        statusSalaryPayment = salaryPaymentStatus.OPEN;
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

    receive() external payable {}

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

    //  ======= modifiers =======
    modifier MustBeOwnerOfContract() {
        if (msg.sender == owner()) {
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
