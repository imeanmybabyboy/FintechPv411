// SPDX-License-Identifier: UNLICENSED
import "hardhat/console.sol";

pragma solidity ^0.8.28;

contract Initial {
    function greet() public pure returns(string memory) {
        return "Hello, world";
    }
}