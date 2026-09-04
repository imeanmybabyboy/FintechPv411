// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "hardhat/console.sol";

contract Voter {
    int[] private votes;
    address public owner; // для відкритих полів автоматично створюються геттери
    string[] public candidates; // але для масивів ці геттери приймають індекс, для повернення всього масиву потрібен явний геттер

    struct VoterData {
        bool isVoted;
        bool isAllowed;
    }
    mapping(address => VoterData) voters;
    
    //mapping(address => bool) isVoted; // mapping - "словник" ключ-значення, який неявно має всі можливі ключі - на запит неіснуючого ключа видається об'єкт заповнений значеннями за замовчуванням
    event Voted(uint);
    bytes4 constant InvalidID = 0xffffffff; // ERC-165 invalid id
    bytes4 constant ERC165ID = 0x01ffc9a7;  // ERC-165 valid id

    constructor(string[] memory _candidates) {
        owner = msg.sender;
        for (uint i = 0; i < _candidates.length; i++) {
            candidates.push( _candidates[i] );
            votes.push(0);
        }
        voters[owner] = VoterData({ isVoted: false, isAllowed: true});
    } 

    function vote(uint i) external {
        require(i < candidates.length, "Index out of range");
        require(voters[msg.sender].isAllowed, "Address is not allowed");
        require(!voters[msg.sender].isVoted, "Address has already voted");
        voters[msg.sender].isVoted = true;
        votes[i]++;
        emit Voted(i);
    }

    function allow(address _address) external {
        require(msg.sender == owner, "Only owner allowed to call this method");
        voters[_address].isAllowed = true;
        console.log(_address, "allowed");
    }

    function getVotes() public view returns(int[] memory) {
        require(msg.sender == owner, "Only owner allowed to call this method");
        return votes;
    }

    function getCandidates() public view returns(string[] memory) {
        return candidates;
    }
    
    fallback() external payable {
        console.log("Unknown selector from %s", msg.sender);
        if (msg.data.length >= 4) {
            bytes4 selectorHash = bytes4( msg.data[:4] );
            console.log("Selector hash starts with:");
            console.logBytes4(selectorHash);
        }
        else {
            console.log("No data about selector");
        }
    }

    receive() external payable {}

    // За стандартами ERC-20
    function decimals() public pure returns (uint8) {
        return 0;
    }

    function symbol() public pure returns (string memory) {
        return "___";
    }

    function balanceOf(address _owner) public pure returns (uint256 balance) {
        if (_owner != address(0)) {
            return 0;
        }
    }

    // За стандартами ERC-165 0x01ffc9a7
    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        if(interfaceId[0] != ERC165ID[0]) return false;
        if(interfaceId[1] != ERC165ID[1]) return false;
        if(interfaceId[2] != ERC165ID[2]) return false;
        if(interfaceId[3] != ERC165ID[3]) return false;
        return true;
    }
}

/*
Голосування:
- існує перелік пропозицій (кандидатів) за яких можна віддавати голос
- один учасник може голосувати лише один раз
- анонімність - не зберігається інформація про вибір, але іде накопичення
- перегляд результатів доступний тільки власнику контракту
*/