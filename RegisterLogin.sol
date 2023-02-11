// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract RegisterLogin {
    enum UserStatus { NotRegistered, Registered }
    enum UserRole { NormalUser, Admin }
    
    mapping (address => UserStatus) private userStatus;
    mapping (address => string) private users;
    mapping (address => UserRole) private userRoles;

    function register(string memory _username) public {
        require(bytes(_username).length != 0, "Username cannot be empty");
        require(userStatus[msg.sender] == UserStatus.NotRegistered, "You are already registered !");
        users[msg.sender] = _username;
        userStatus[msg.sender] = UserStatus.Registered;
        userRoles[msg.sender] = UserRole.NormalUser;
    }

    function login() public view returns (string memory) {
        require(userStatus[msg.sender] == UserStatus.Registered, "User not registered.");
        return users[msg.sender];
    }

    function updateUsername(string memory _newUsername) public {
        require(userStatus[msg.sender] == UserStatus.Registered, "User not registered.");
        require(bytes(_newUsername).length != 0, "Username cannot be empty");
        users[msg.sender] = _newUsername;
    }

    function logout() public {
        require(userStatus[msg.sender] == UserStatus.Registered, "User not registered.");
        delete users[msg.sender];
        userStatus[msg.sender] = UserStatus.NotRegistered;
    }

    function performAction(string memory _action) view public {
        require(userStatus[msg.sender] == UserStatus.Registered, "User not registered.");
        require(keccak256(abi.encodePacked("adminAction")) == keccak256(abi.encodePacked(_action)), "Action not supported.");
        if (keccak256(abi.encodePacked("adminAction")) == keccak256(abi.encodePacked(_action)) && userRoles[msg.sender] != UserRole.Admin) {
            revert("Unauthorized access.");
        }
        // Perform action here
    }
}
