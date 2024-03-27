// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IENSRegistry {
    function registerUser(string memory ensName, string memory image) external;

    function getUserInfo(
        string memory ensName
    ) external view returns (string memory, string memory, address);
}
