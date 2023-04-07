// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract GrandPa {
    uint public grandpaAge;

    constructor(uint _age) {
        grandpaAge = _age;
    }

    event Log(string msg);

    function hip() public virtual {
        emit Log("Yeye");
    }

    function hop() public virtual {
        emit Log("Yeye");
    }

    function yeye() public virtual {
        emit Log("Yeye");
    }
}

contract Father is GrandPa {
    uint public fatherAge;

    constructor(uint _age) GrandPa(_age + 20) {
        fatherAge = _age;
    }

    function hip() public virtual override {
        emit Log("Father");
    }

    function hop() public virtual override {
        emit Log("Father");
    }

    function father() public virtual {
        emit Log("Father");
    }
}

contract Son is GrandPa, Father {
    uint public sonAge;

    constructor(uint _age) Father(_age + 20) {
        sonAge = _age;
    }

    function hip() public virtual override(GrandPa, Father) {
        emit Log("Son");
    }

    function hop() public virtual override(GrandPa, Father) {
        emit Log("Son");
    }

    function son() public virtual {
        emit Log("Son");
    }
}

contract Base1 {
    modifier extractDivideBy2Or3(uint _a) virtual {
        require(_a % 2 == 0 && _a % 3 == 0);
        _;
    }
}

contract Identifier is Base1 {
    modifier extractDivideBy2Or3(uint _a) override {
        _;
        require(_a % 2 == 0 && _a % 3 == 0);
    }

    function getDividedBy2And3(
        uint _dividend
    ) public pure extractDivideBy2Or3(_dividend) returns (uint, uint) {
        return getExactDividedBy2And3WithoutModifier(_dividend);
    }

    function getExactDividedBy2And3WithoutModifier(
        uint _dividend
    ) public pure returns (uint, uint) {
        uint div1 = _dividend % 2;
        uint div2 = _dividend % 3;
        return (div1, div2);
    }
}
