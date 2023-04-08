// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Overloading {
    function saySomething() public pure returns (string memory) {
        return ("Nothing");
    }

    function saySomething(
        string memory something
    ) public pure returns (string memory) {
        return (something);
    }

    // different selector, but if call f(50) in other functions will cause TypeError: No unique declaration found after argument-dependent lookup..
    function f(uint8 _in) public pure returns (uint8 out) {
        out = _in;
    }

    function f(uint256 _in) public pure returns (uint256 out) {
        out = _in;
    }
}
