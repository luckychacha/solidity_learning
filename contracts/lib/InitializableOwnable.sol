// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract InitializableOwnable {
    address public _OWNER_;
    address public _NEW_ONWER_;
    bool internal _INTIALIZED_;

    // Events

    event OnwershipTransferPrepared(
        address indexed previousOwner,
        address indexed newOwner
    );

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
}
