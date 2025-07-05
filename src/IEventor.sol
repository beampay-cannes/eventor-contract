// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

interface IEventor {
    event ConfirmedPayment(address indexed to, uint256 indexed amount, bytes32 paymentId);

    error InvalidAmount(uint256 expected, uint256 actual);
    error NotEntered();
    error AlreadyEntered();
    error OnlyEOA();
    error InvalidPaymentId();
    error InvalidTo();
    error NoFundsReceived();
    error InvalidDeclaredAmount(uint256 expected, uint256 actual);

    function commit(
        address _to,
        uint256 _declaredAmount,
        bytes32 _paymentId
    ) external;

    function reveal(
        address _to,
        uint256 _declaredAmount,
        bytes32 _paymentId
    ) external;
}