// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

contract RegisterLogin {
    mapping (address => string) private users;
    // uint256 usersCount;  // If required

    function register(string memory _username) public {
        require(bytes(_username).length != 0, "Username cannot be empty");
        require(bytes(users[msg.sender]).length == 0, "You are already registered !");
        users[msg.sender] = _username;
        // usersCount++;
    }

    function login() public view returns (string memory) {
        require(bytes(users[msg.sender]).length != 0, "User not registered.");
        return users[msg.sender];
    }

}
