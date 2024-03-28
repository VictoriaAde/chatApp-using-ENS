// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IENSRegistry.sol";

contract ChatApp {
    struct Message {
        string content;
        string sender;
        string recipient;
        uint256 timestamp;
    }

    struct UserMessages {
        string ensName;
        Message[] sentMessages;
        Message[] receivedMessages;
    }

    IENSRegistry internal ensRegistry;
    mapping(address => string) internal ensNames;
    // mapping(string => Message[]) internal messages;
    mapping(string => UserMessages) internal userMessages;

    event MessageSent(
        string sender,
        string recipient,
        string content,
        uint256 timestamp
    );

    constructor(address _ensRegistryAddress) {
        ensRegistry = IENSRegistry(_ensRegistryAddress);
    }

    function registerENSName(string memory ensName) external {
        // Assuming the user has already registered with the ENSRegistry contract
        (, , address registeredAddress) = ensRegistry.getUserInfo(ensName);

        require(
            registeredAddress == msg.sender,
            "Sender must be the registered user"
        );

        ensNames[msg.sender] = ensName; // Store the ENS name for the sender
    }

    function sendMessage(
        string memory recipientENSName,
        string memory content
    ) external {
        (string memory recipientName, , address recipientAddress) = ensRegistry
            .getUserInfo(recipientENSName);
        require(recipientAddress != address(0), "Recipient not found");

        string memory senderENSName = ensNames[msg.sender];
        require(
            bytes(senderENSName).length > 0,
            "Sender ENS name not registered"
        );

        Message memory newMessage = Message({
            content: content,
            sender: senderENSName,
            recipient: recipientName,
            timestamp: block.timestamp
        });

        // Update the sender's sentMessages
        userMessages[senderENSName].sentMessages.push(newMessage);

        // Update the recipient's receivedMessages
        userMessages[recipientENSName].receivedMessages.push(newMessage);

        emit MessageSent(
            newMessage.sender,
            newMessage.recipient,
            newMessage.content,
            newMessage.timestamp
        );
    }

    function getSentMessages() external view returns (Message[] memory) {
        string memory senderENSName = ensNames[msg.sender];
        require(
            bytes(senderENSName).length > 0,
            "Sender ENS name not registered"
        );
        return userMessages[senderENSName].sentMessages;
    }

    function getReceivedMessages() external view returns (Message[] memory) {
        string memory recipientENSName = ensNames[msg.sender];
        require(
            bytes(recipientENSName).length > 0,
            "Recipient ENS name not registered"
        );
        return userMessages[recipientENSName].receivedMessages;
    }
}

// ENSRegistry 0x81cd3ee7dF9Cf837BC9e577ff0AaB63829741638
// ChapApp 0x4C48217c3007EdD90c8Aa884660467F3AF4fA753
