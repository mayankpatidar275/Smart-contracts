// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract User {
    enum UserRole { NormalUser, Admin }

    struct UserData {
        string username;
        bytes32 passwordHash;
        UserRole role;
    }

    mapping (address => UserData) private users;

    function addUser(address _userAddress, string memory _username, bytes32 _password) internal {
        users[_userAddress].username = _username;
        users[_userAddress].passwordHash = keccak256(abi.encodePacked(_password));
        users[_userAddress].role = UserRole.NormalUser;
    }

    function getUser(address _userAddress) internal view returns (UserData memory) {
        return users[_userAddress];
    }

    function updateUserUsername(address _userAddress, string memory _newUsername) internal {
        users[_userAddress].username = _newUsername;
    }

    function deleteUser(address _userAddress) internal {
        delete users[_userAddress];
    }

    function getUserRole(address _userAddress) internal view returns (UserRole) {
        return users[_userAddress].role;
    }

    function setUserRole(address _userAddress, UserRole _role) internal {
        users[_userAddress].role = _role;
    }
}
