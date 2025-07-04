// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Delegator {
    using SafeERC20 for IERC20;
    event ConfirmedPayment(address indexed token, uint256 indexed amount, bytes32 paymentId);
    
    function doPayment(address _token, uint256 _amount, bytes32 _paymentId) public {
        IERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);
        emit ConfirmedPayment(_token, _amount, _paymentId);
    }
}