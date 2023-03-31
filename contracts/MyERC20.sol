// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract MyERC20 is ERC20, Ownable {
    uint8 private _reentrantLock;
    using SafeMath for uint256;

    // fee can be transferred into this address.
    address public feeAddress;

    // fee ratio is multiply by 1000;
    // such as Rule: Take 1 token if transaction amount is 1000 token. feeRatio is 1.
    // such as Rule: Take 10 token if transaction amount is 1000 token. feeRatio is 10.
    uint public feeRatio;

    // burn ratio is multiply by 1000;
    // such as Rule: Burn 1 token if transaction amount is 1000. burnRatio is 1.
    // such as Rule: Burn 10 fee if transaction amount is 1000. burnRatio is 10.
    uint public burnRatio;

    constructor() ERC20("My ERC20 Token", "MET") {}

    function mint(address _account, uint256 _amount) public onlyOwner {
        _mint(_account, _amount);
    }

    function setTradeRule(
        address addr,
        uint _feeRatio,
        uint _burnRatio
    ) public onlyOwner {
        feeAddress = addr;
        feeRatio = _feeRatio;
        burnRatio = _burnRatio;
    }

    modifier ReentryLock() {
        require(_reentrantLock == 0, "Reentranct call!");
        _reentrantLock = 1;
        _;
        _reentrantLock = 0;
    }

    function burn(uint256 _amount) public ReentryLock {
        require(balanceOf(msg.sender) >= _amount);
        _burn(msg.sender, _amount);
    }

    function transfer(
        address _to,
        uint256 _amount
    ) public virtual override ReentryLock returns (bool) {
        require(
            balanceOf(msg.sender) >= _amount,
            "transfer amount is exceeds user's balance"
        );

        require(feeAddress != address(0), "feeAddress is not set.");

        // require(feeRatio > 0, "feeRatio not set.");

        uint fee = _amount.mul(feeRatio).div(1000);
        uint burnAmount = _amount.mul(burnRatio).div(1000);
        uint realAmount = _amount.sub(fee).sub(burnAmount);
        _transfer(msg.sender, _to, realAmount);
        _transfer(msg.sender, feeAddress, fee);
        if (burnAmount > 0) {
            _burn(msg.sender, burnAmount);
        }

        return true;
    }
}
