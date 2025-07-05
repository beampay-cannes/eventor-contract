// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IEventor} from "src/IEventor.sol";

// This contract is used to test the Eventor contract as it doesn't have onlyEOA modifier.
contract EventorHarness is IEventor {
    bool transient alreadyCommitted;
    bool transient alreadyRevealed;
    bytes32 transient paymentId;
    address transient to;
    uint256 transient balanceBefore;
    uint256 transient declaredAmount;

    IERC20 public immutable USDC;

    constructor(IERC20 _USDC) {
        USDC = _USDC;
    }

    modifier onlyCommitted() {
        require(alreadyCommitted, NotEntered());
        _;
    }

    modifier onlyNotCommitted() {
        require(!alreadyCommitted, AlreadyCommitted());
        _;
    }

    modifier onlyNotRevealed() {
        require(!alreadyRevealed, AlreadyRevealed());
        _;
    }

    function commit(address _to, uint256 _declaredAmount, string memory _paymentId)
        public
        virtual
        onlyNotCommitted
        onlyNotRevealed
    {
        alreadyCommitted = true;
        paymentId = keccak256(abi.encodePacked(_paymentId));
        to = _to;
        balanceBefore = USDC.balanceOf(_to);
        declaredAmount = _declaredAmount;
    }

    function reveal(address _to, uint256 _declaredAmount, string memory _paymentId)
        public
        virtual
        onlyCommitted
        onlyNotRevealed
    {
        require(paymentId == keccak256(abi.encodePacked(_paymentId)), InvalidPaymentId());
        require(to == _to, InvalidTo());

        uint256 amount = USDC.balanceOf(_to) - balanceBefore;
        require(amount > 0, NoFundsReceived());
        require(amount == declaredAmount, InvalidDeclaredAmount(declaredAmount, amount));
        require(declaredAmount == _declaredAmount, InvalidDeclaredAmount(declaredAmount, _declaredAmount));

        alreadyRevealed = true;

        emit ConfirmedPayment(to, amount, _paymentId);
    }
}
