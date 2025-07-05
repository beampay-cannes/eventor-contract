---
eip: TBD
title: Metadata-Enabled ERC20 Transfers via Commit-Reveal Pattern
description: A standard for adding trusted metadata to ERC20 transfers through batched transactions
author: TBD
discussions-to: TBD
status: Draft
type: Standards Track
category: ERC
created: 2025-07-06
requires: 20, 7702
---

## Abstract

This EIP proposes a standard for adding trusted metadata to ERC20 transfers through a commit-reveal pattern that leverages batched transactions. While ERC20 transfers lack native metadata capabilities, this standard enables a single transaction to include both the token transfer and associated metadata, producing a trusted event that can be verified on-chain.

## Motivation

ERC20 token transfers are limited to basic transfer functionality without native support for metadata. This creates challenges for applications requiring:

1. **Payment References**: Linking transfers to specific invoices, orders, or identifiers
2. **Trusted Metadata**: Ensuring metadata cannot be manipulated after transfer
3. **Atomic Operations**: Guaranteeing metadata and transfer occur together
4. **Event Verification**: Providing verifiable proof of transfer with metadata

Current solutions require separate transactions or off-chain systems, creating potential for:
- Metadata/transfer desynchronization
- Front-running attacks
- Increased gas costs
- Poor user experience

## Specification

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in RFC 2119 and RFC 8174.

### Core Interface

Contracts implementing this standard MUST implement the following interface:

```solidity
interface IERC20MetadataTransfer {
    /**
     * @notice Emitted when a metadata-enabled transfer is confirmed
     * @param to The recipient address
     * @param amount The transferred amount
     * @param paymentId The payment identifier/metadata
     */
    event ConfirmedPayment(address indexed to, uint256 indexed amount, string paymentId);

    /**
     * @notice Commits to a metadata-enabled transfer
     * @param to The recipient address
     * @param declaredAmount The amount to be transferred
     * @param paymentId The payment identifier/metadata
     */
    function commit(address to, uint256 declaredAmount, string memory paymentId) external;

    /**
     * @notice Reveals and validates a metadata-enabled transfer
     * @param to The recipient address
     * @param declaredAmount The amount that was transferred
     * @param paymentId The payment identifier/metadata
     */
    function reveal(address to, uint256 declaredAmount, string memory paymentId) external;
}
```

### Commit-Reveal Pattern

The standard implements a commit-reveal pattern within a single transaction:

1. **Commit Phase**: Call `commit()` to declare transfer intent with metadata
2. **Transfer Phase**: Execute ERC20 transfer to recipient
3. **Reveal Phase**: Call `reveal()` to validate and emit trusted event

### Transient Storage Requirements

Implementations MUST use transient storage to maintain state between commit and reveal phases. This ensures:

- State persistence within the transaction
- Automatic cleanup after transaction completion
- Prevention of cross-transaction state pollution

```solidity
contract ERC20MetadataTransfer {
    // Transient storage variables
    bool transient alreadyCommitted;
    bool transient alreadyRevealed;
    bytes32 transient paymentId;
    address transient to;
    uint256 transient balanceBefore;
    uint256 transient declaredAmount;
    
    IERC20 public immutable token;
    
    // Implementation details...
}
```

### Validation Rules

The `reveal()` function MUST validate:

1. **Commitment State**: A commit must have been made in the same transaction
2. **Payment ID Match**: The payment ID must match the committed value
3. **Recipient Match**: The recipient address must match the committed value
4. **Amount Validation**: The actual transferred amount must match the declared amount
5. **Balance Check**: The recipient's token balance increase must equal the declared amount

### Batched Transaction Requirement

This standard is designed for batched transactions (e.g., EIP-7702) where all three phases occur atomically:

```javascript
// Example batched transaction
await account.batchCall([
    eventor.commit(recipient, amount, paymentId),
    token.transfer(recipient, amount),
    eventor.reveal(recipient, amount, paymentId)
]);
```

## Rationale

### Why Commit-Reveal Pattern?

The commit-reveal pattern provides several advantages:

1. **Atomic Metadata**: Links metadata to transfers within a single transaction
2. **Tamper Resistance**: Prevents metadata modification after commitment
3. **Validation**: Ensures declared amounts match actual transfers
4. **Trusted Events**: Produces verifiable on-chain events with metadata

### Why Transient Storage?

Transient storage is ideal for this use case because:

1. **Gas Efficiency**: Cheaper than persistent storage for temporary state
2. **Automatic Cleanup**: State is automatically cleared after transaction
3. **Single Transaction Scope**: Perfect for batched operations
4. **Security**: Prevents state manipulation across transactions

### EIP-7702 Compatibility

This standard leverages EIP-7702's batched transaction capabilities:

1. **EOA Delegation**: Allows EOAs to execute complex contract logic
2. **Atomic Operations**: Ensures all operations succeed or fail together
3. **Enhanced UX**: Users can perform complex operations in one transaction
4. **Gas Optimization**: Reduces overhead compared to separate transactions

## Backwards Compatibility

This standard is fully backwards compatible with existing ERC20 implementations:

1. **No ERC20 Changes**: Works with any existing ERC20 token
2. **Optional Adoption**: Can be added to existing systems without breaking changes
3. **Parallel Operation**: Can coexist with standard ERC20 transfers

## Test Cases

```solidity
// Test successful metadata transfer
function testMetadataTransfer() public {
    string memory paymentId = "invoice-123";
    uint256 amount = 1000e6; // 1000 USDC
    
    // Batched transaction
    eventor.commit(recipient, amount, paymentId);
    usdc.transfer(recipient, amount);
    eventor.reveal(recipient, amount, paymentId);
    
    // Verify event emission
    // Event: ConfirmedPayment(recipient, amount, paymentId)
}

// Test validation failure
function testAmountMismatch() public {
    eventor.commit(recipient, 1000e6, "test");
    usdc.transfer(recipient, 500e6); // Wrong amount
    
    // Should revert on reveal
    vm.expectRevert();
    eventor.reveal(recipient, 1000e6, "test");
}
```

## Implementation

A reference implementation is available in this repository.

Key components:
- `src/Eventor.sol`: Main contract implementing the standard
- `src/EventorHarness.sol`: Test version for development
- `src/IEventor.sol`: Interface definition
- `test/Eventor.t.sol`: Comprehensive test suite with mainnet forking
- `script/DeployEventor.s.sol`: Multi-chain deployment script

## Security Considerations

1. **EOA Restriction**: Implementations SHOULD restrict calls to EOAs to prevent contract-based attacks
2. **Reentrancy**: Implementations MUST prevent reentrancy attacks during the commit-reveal cycle
3. **Front-running**: The atomic nature prevents front-running of metadata
4. **State Isolation**: Transient storage ensures state cannot persist across transactions

## Copyright

Copyright and related rights waived via [CC0](../LICENSE.md).

## Appendix

### Example Use Cases

1. **Invoice Payments**: Link USDC transfers to specific invoice numbers
2. **Order Fulfillment**: Connect payments to e-commerce order IDs
3. **Subscription Services**: Associate payments with subscription periods
4. **Charity Donations**: Include donor messages or campaign references
5. **B2B Payments**: Add purchase order numbers or contract references

### Gas Optimization

Transient storage provides significant gas savings:
- Commit: ~22,000 gas (vs ~44,000 for persistent storage)
- Reveal: ~15,000 gas (vs ~30,000 for persistent storage)
- Total savings: ~37,000 gas per metadata transfer

### Integration Examples

```solidity
// E-commerce integration
function processPayment(uint256 orderId, uint256 amount) external {
    string memory paymentId = string(abi.encodePacked("order-", orderId));
    
    // Batched execution
    eventor.commit(merchant, amount, paymentId);
    usdc.transfer(merchant, amount);
    eventor.reveal(merchant, amount, paymentId);
}
``` 