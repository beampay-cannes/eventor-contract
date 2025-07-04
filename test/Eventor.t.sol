// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {Eventor} from "../src/Eventor.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

IERC20 constant USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

// Helper contract to execute all operations in one transaction
contract PaymentExecutor {
    function executePayment(
        address eventor,
        address recipient,
        uint256 usdcAmount,
        bytes32 paymentId
    ) external {
        // First call to execute - sets up transient state
        Eventor(eventor).execute(recipient, paymentId);
        
        // Transfer USDC between the calls
        IERC20(USDC).transfer(recipient, usdcAmount);
        
        // Second call to execute - validates and emits event
        Eventor(eventor).execute(recipient, paymentId);
    }
}

contract EventorTest is Test {
    Eventor public eventor;
    PaymentExecutor public paymentExecutor;
    
    address public constant USDC_HOLDER = 0x87555C010f5137141ca13b42855d90a108887005;
    address public constant RECIPIENT = address(0x123);
    uint256 public constant PAYMENT_AMOUNT = 1e6; // 1 USDC (6 decimals)
    
    // Helper function to create paymentId with USDC amount in first 16 bytes
    function createPaymentId(uint256 usdcAmount) internal pure returns (bytes32) {
        // Encode USDC amount in first 16 bytes, rest can be random/hash
        bytes16 amountBytes = bytes16(uint128(usdcAmount));
        bytes16 randomBytes = bytes16(keccak256("test_payment"));
        return bytes32(abi.encodePacked(amountBytes, randomBytes));
    }

    function setUp() public {
        // Fork mainnet at a recent block
        vm.createSelectFork("https://ethereum-rpc.publicnode.com");
        
        // Deploy contracts
        eventor = new Eventor();
        paymentExecutor = new PaymentExecutor();
        
        // Give recipient some initial ETH for the balance check
        vm.deal(RECIPIENT, 1 ether);
    }

    function test_EventorDoubleCall() public {
        // Use the USDC holder as the caller (must be EOA)
        vm.startPrank(USDC_HOLDER, USDC_HOLDER); // tx.origin = USDC_HOLDER
        
        // Check initial balances
        uint256 initialUsdcBalance = USDC.balanceOf(USDC_HOLDER);
        require(initialUsdcBalance >= PAYMENT_AMOUNT, "USDC holder doesn't have enough USDC");
        
        // Create paymentId with USDC amount in first 16 bytes
        bytes32 paymentId = createPaymentId(PAYMENT_AMOUNT);
        
        // Transfer USDC to the PaymentExecutor so it can make the transfers
        USDC.transfer(address(paymentExecutor), PAYMENT_AMOUNT);
        
        // Expect the ConfirmedPayment event (amount will be 0 since no ETH transferred)
        vm.expectEmit(true, true, false, true);
        emit Eventor.ConfirmedPayment(RECIPIENT, PAYMENT_AMOUNT, paymentId);
        
        // Execute the payment (all operations in one transaction)
        paymentExecutor.executePayment(
            address(eventor),
            RECIPIENT,
            PAYMENT_AMOUNT,
            paymentId
        );
        
        // Verify USDC was transferred
        assertEq(USDC.balanceOf(RECIPIENT), PAYMENT_AMOUNT, "Recipient should receive USDC");
        assertEq(USDC.balanceOf(USDC_HOLDER), initialUsdcBalance - PAYMENT_AMOUNT, "Sender should have less USDC");
        
        // Verify paymentId contains correct USDC amount in first 16 bytes
        uint128 extractedAmount = uint128(bytes16(paymentId));
        assertEq(extractedAmount, PAYMENT_AMOUNT, "PaymentId should contain USDC amount in first 16 bytes");
        
        vm.stopPrank();
    }
} 