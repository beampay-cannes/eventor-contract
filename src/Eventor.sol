// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

IERC20 constant USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

contract Eventor {
    bool transient alreadyEntered;
    bytes32 transient paymentId;
    address transient to;
    uint256 transient balanceBefore;
    event ConfirmedPayment(address indexed to, uint256 indexed amount, bytes32 paymentId);

    error InvalidAmount(uint256 expected, uint256 actual);

    function execute(
        address _to,
        bytes32 _paymentId
    ) external {
        // require(msg.sender == tx.origin, "Only EOA");
        if (alreadyEntered) {
            require(paymentId == _paymentId, "Invalid paymentId");
            require(to == _to, "Invalid to");
            uint256 amount = USDC.balanceOf(_to) - balanceBefore;
            require(amount > 0, "No funds received");
            // uint256 amountFromData = uint256(bytes32(msg.data[40:52]));
            // require(amount == amountFromData, InvalidAmount(amount, amountFromData));
            emit ConfirmedPayment(to, amount, paymentId);
        }
        alreadyEntered = true;
        paymentId = _paymentId;
        to = _to;
        balanceBefore = USDC.balanceOf(_to);
    }
}