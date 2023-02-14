// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract RegisterLogin {
    enum UserStatus { NotRegistered, Registered }
    enum UserRole { NormalUser, Admin }
    enum Action { AdminAction }

    using SafeMath for uint256;

    struct User {
        string username;
        bytes32 passwordHash;
        UserRole role;
    }

    mapping (address => User) private users;
    mapping (address => UserStatus) private userStatuses;

    function register(string memory _username, bytes32 _password) external {
        require(bytes(_username).length != 0, "Username must not be empty.");
        require(userStatuses[msg.sender] == UserStatus.NotRegistered, "User is already registered");

        users[msg.sender].username = _username;
        users[msg.sender].passwordHash = keccak256(abi.encodePacked(_password));
        users[msg.sender].role = UserRole.NormalUser;
        userStatuses[msg.sender] = UserStatus.Registered;
    }

    function login(bytes32 _password) public view returns (string memory) {
        require(userStatuses[msg.sender] == UserStatus.Registered, "User is not registered");
        require(keccak256(abi.encodePacked(_password)) == users[msg.sender].passwordHash, "Incorrect password");
        return users[msg.sender].username;
    }

    function updateUsername(string memory _newUsername) external {
        require(userStatuses[msg.sender] == UserStatus.Registered, "User is not registered");
        require(bytes(_newUsername).length != 0, "Username must not be empty");

        users[msg.sender].username = _newUsername;
    }

    function logout() external {
        require(userStatuses[msg.sender] == UserStatus.Registered, "User is not registered");

        delete users[msg.sender];
        userStatuses[msg.sender] = UserStatus.NotRegistered;
    }

    function performAction(Action _action) view public {
        require(userStatuses[msg.sender] == UserStatus.Registered, "User is not registered");
        require(_action == Action.AdminAction, "Unsupported action");

        if (_action == Action.AdminAction && users[msg.sender].role != UserRole.Admin) {
            revert("Unauthorized access");
        }
    }
}
