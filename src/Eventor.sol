// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {EventorHarness} from "src/EventorHarness.sol";

IERC20 constant USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

contract Eventor is EventorHarness {
    modifier onlyEOA() {
        require(msg.sender == tx.origin, OnlyEOA());
        _;
    }

    function commit(
        address _to,
        uint256 _declaredAmount,
        bytes32 _paymentId
    ) public override onlyEOA {
        super.commit(_to, _declaredAmount, _paymentId);
    }

    function reveal(
        address _to,
        uint256 _declaredAmount,
        bytes32 _paymentId
    ) public override onlyEOA {
        super.reveal(_to, _declaredAmount, _paymentId);
    }
}