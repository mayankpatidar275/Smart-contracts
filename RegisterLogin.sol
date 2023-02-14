// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./User.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract RegisterLogin is User, Ownable {
    enum UserStatus { NotRegistered, Registered }
    enum Action { AdminAction }

    using SafeMath for uint256;

    mapping (address => UserStatus) private userStatuses;

    // modifier onlyOwner() override {
    //     require(msg.sender == owner(), "Caller is not the owner");
    //     _;
    // }

    function register(string memory _username, bytes32 _password) external {
        require(bytes(_username).length != 0, "Username must not be empty.");
        require(userStatuses[msg.sender] == UserStatus.NotRegistered, "User is already registered");

        addUser(msg.sender, _username, _password);
        userStatuses[msg.sender] = UserStatus.Registered;
    }

    function login(bytes32 _password) public view returns (string memory) {
        require(userStatuses[msg.sender] == UserStatus.Registered, "User is not registered");
        require(keccak256(abi.encodePacked(_password)) == getUser(msg.sender).passwordHash, "Incorrect password");
        return getUser(msg.sender).username;
    }

    function updateUsername(string memory _newUsername) external {
        require(userStatuses[msg.sender] == UserStatus.Registered, "User is not registered");
        require(bytes(_newUsername).length != 0, "Username must not be empty");

        updateUserUsername(msg.sender, _newUsername);
    }

    function logout() external {
        require(userStatuses[msg.sender] == UserStatus.Registered, "User is not registered");

        deleteUser(msg.sender);
        userStatuses[msg.sender] = UserStatus.NotRegistered;
    }

    function performAction(Action _action) view public onlyOwner {
        require(userStatuses[msg.sender] == UserStatus.Registered, "User is not registered");
        require(_action == Action.AdminAction, "Unsupported action");

        if (_action == Action.AdminAction && getUserRole(msg.sender) != UserRole.Admin) {
            revert("Unauthorized access");
        }
    }

    function transferContractOwnership(address newOwner) public onlyOwner {
        transferOwnership(newOwner);
    }

}
