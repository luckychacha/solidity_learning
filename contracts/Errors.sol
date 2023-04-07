// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

error TransferNotOwner(address sender);

contract Errors {
    mapping(uint => address) tokenIdOwnerMapper;

    function transferIsOwner(uint tokenId, address newOwner) public {
        // way 1: use error.
        // Gas used: min.
        if (tokenIdOwnerMapper[tokenId] != msg.sender) {
            revert TransferNotOwner(msg.sender);
        }

        // way 2: use require
        // Gas used: max.
        require(
            tokenIdOwnerMapper[tokenId] == msg.sender,
            "Transfer Not Owner"
        );

        // way 3: use assert
        // Gas used: medium.
        assert(tokenIdOwnerMapper[tokenId] == msg.sender);

        tokenIdOwnerMapper[tokenId] = newOwner;
    }
}
