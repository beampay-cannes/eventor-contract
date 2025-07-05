// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IEventor} from "src/IEventor.sol";

IERC20 constant USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

// This contract is used to test the Eventor contract.
// It is not used in the production code.
contract EventorHarness is IEventor {
    bool transient alreadyEntered;
    bytes32 transient paymentId;
    address transient to;
    uint256 transient balanceBefore;
    uint256 transient declaredAmount;

    modifier onlyEntered() {
        require(alreadyEntered, NotEntered());
        _;
    }

    modifier onlyNotEntered() {
        require(!alreadyEntered, AlreadyEntered());
        _;
    }

    function commit(
        address _to,
        uint256 _declaredAmount,
        bytes32 _paymentId
    ) public onlyNotEntered virtual {
        alreadyEntered = true;
        paymentId = _paymentId;
        to = _to;
        balanceBefore = USDC.balanceOf(_to);
        declaredAmount = _declaredAmount;
    }

    function reveal(
        address _to,
        uint256 _declaredAmount,
        bytes32 _paymentId
    ) public onlyEntered virtual {
        require(paymentId == _paymentId, InvalidPaymentId());
        require(to == _to, InvalidTo());

        uint256 amount = USDC.balanceOf(_to) - balanceBefore;
        require(amount > 0, NoFundsReceived());
        require(amount == declaredAmount, InvalidDeclaredAmount(declaredAmount, amount));   
        require(declaredAmount == _declaredAmount, InvalidDeclaredAmount(declaredAmount, _declaredAmount));
        
        emit ConfirmedPayment(to, amount, paymentId);
    }
}