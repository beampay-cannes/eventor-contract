// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {EventorHarness} from "src/EventorHarness.sol";

contract Eventor is EventorHarness {
    modifier onlyEOA() {
        require(msg.sender == tx.origin, OnlyEOA());
        _;
    }

    constructor(IERC20 _USDC) EventorHarness(_USDC) {}

    function commit(address _to, uint256 _declaredAmount, string memory _paymentId) public override onlyEOA {
        super.commit(_to, _declaredAmount, _paymentId);
    }

    function reveal(address _to, uint256 _declaredAmount, string memory _paymentId) public override onlyEOA {
        super.reveal(_to, _declaredAmount, _paymentId);
    }
}
