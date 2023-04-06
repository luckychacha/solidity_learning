// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract StructTypes {
    struct Student {
        uint256 id;
        uint256 score;
    }
    bytes1 public test;
    string constant x5 = "hello world";
    address constant x6 = address(0);
    // string immutable x7 = "hello world";
    address immutable x8 = address(0);
    Student public student;

    function initStudent() external {
        student.id = 100;
        student.score = 200;
        Student storage _student = student;
        _student.id = 300;
        _student.score = 400;
    }

    function insertionSort(
        uint[] memory a
    ) public pure returns (uint[] memory) {
        // uint i;
        // for (i = 0; i < a.length; i++) {
        //     uint j = 0;
        //     while (j < i) {
        //         if (a[j] > a[i]) {
        //             uint tmp = a[j];
        //             a[j] = a[i];
        //             a[i] = tmp;
        //         }
        //         j += 1;
        //     }
        // }

        for (uint i = 1; i < a.length; i++) {
            uint j = i;
            uint tmp = a[i];
            while (j >= 0 && tmp < a[j - 1]) {
                a[j] = a[j - 1];
                j--;
            }
            a[j] = tmp;
        }
        return (a);
    }
}
