// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract GrandPa {
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
