// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

interface IEventor {
    event ConfirmedPayment(address indexed to, uint256 indexed amount, string paymentId);

    error InvalidAmount(uint256 expected, uint256 actual); // 0x9bbd3413
    error NotEntered(); // 0x87d3924c
    error AlreadyCommitted();
    error AlreadyRevealed();
    error OnlyEOA(); // 0x68c6baf3
    error InvalidPaymentId(); // 7ff86a8f
    error InvalidTo(); // 0xae72df77
    error NoFundsReceived(); // 0x0abcd1e6
    error InvalidDeclaredAmount(uint256 expected, uint256 actual); // 0xb15893f4

    function commit(address _to, uint256 _declaredAmount, string memory _paymentId) external;

    function reveal(address _to, uint256 _declaredAmount, string memory _paymentId) external;
}
