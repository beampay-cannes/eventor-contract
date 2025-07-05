# Delegator Contract System

A smart contract system for handling USDC payments with event verification using transient storage, designed for EIP-7702 batched transactions.

## Overview

This project consists of:

- **Eventor**: A contract that validates and emits payment events using transient storage
- **EventorHarness**: A test version of Eventor without EOA restrictions
- **Test Suite**: Comprehensive tests with mainnet forking

## Features

- ✅ **EIP-7702 Compatible**: Designed for EIP-7702 use cases with batched transactions
- ✅ **Transient Storage**: Uses Solidity's transient storage for gas-efficient state management
- ✅ **Multi-Chain Support**: Deployable on Ethereum, Zircuit, and Flow networks
- ✅ **Payment Validation**: Validates USDC transfers with commit-reveal pattern
- ✅ **Event Emission**: Emits confirmed payment events after validation
- ✅ **EOA Only**: Restricted to externally owned accounts for security

## Contracts

### Eventor

The main contract that handles payment validation and event emission using a commit-reveal pattern.

**Key Features:**
- Uses transient storage for temporary state between calls
- Validates USDC payment amounts and recipients
- Emits `ConfirmedPayment` events after successful validation
- Requires EOA callers only for security
- Implements commit-reveal pattern for payment validation

**Constructor:**
```solidity
constructor(IERC20 _USDC)
```

**Main Functions:**
- `commit(address _to, uint256 _declaredAmount, string memory _paymentId)` - Commits to a payment
- `reveal(address _to, uint256 _declaredAmount, string memory _paymentId)` - Reveals and validates the payment

### EventorHarness

A test version of Eventor without the EOA restriction, used for testing purposes.

## Supported Networks

| Network | USDC Address |
|---------|-------------|
| Ethereum | `0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48` |
| Zircuit | `0x3b952c8C9C44e8Fe201e2b26F6B2200203214cfF` |
| Flow | `0x7f27352D5F83Db87a5A3E00f4B07Cc2138D8ee52` |

## Installation

```bash
# Clone the repository
git clone <repository-url>
cd delegator-contract

# Install dependencies
forge install
```

## Usage

### Build

```bash
forge build
```

### Test

```bash
# Run all tests
forge test

# Run specific test with verbosity
forge test --match-test test_EventorDoubleCall -vvv

# Run EOA restriction test
forge test --match-test test_EventorOnlyEOA -vvv

# Run tests with mainnet fork
forge test --fork-url https://ethereum-rpc.publicnode.com
```

### Deploy

Set your environment variables:
```bash
export PRIVATE_KEY=your_private_key
export ETHERSCAN_KEY=your_etherscan_api_key
```

#### Deploy to Ethereum
```bash
forge script script/DeployEventor.s.sol --rpc-url https://eth.meowrpc.com --broadcast --verify --etherscan-api-key $ETHERSCAN_KEY
```

#### Deploy to Zircuit
```bash
forge script script/DeployEventor.s.sol --rpc-url https://mainnet.zircuit.com --broadcast --verify --verifier-url https://explorer.zircuit.com/api
```

#### Deploy to Flow
```bash
forge script script/DeployEventor.s.sol --rpc-url https://mainnet.evm.nodes.onflow.org --broadcast
```

### Format Code

```bash
forge fmt
```

### Gas Snapshots

```bash
forge snapshot
```

## How It Works

The system is designed for **EIP-7702** use cases where all operations are batched in a single transaction. This design enables the use of transient storage for secure payment validation:

1. **Commit Phase**: Call `commit()` to set up transient state with payment details
2. **USDC Transfer**: Transfer USDC tokens to the recipient between calls
3. **Reveal Phase**: Call `reveal()` to validate the payment and emit confirmation event

**Key Design Principle**: All three operations must happen within the same transaction for transient storage to persist between calls. This makes it ideal for EIP-7702 implementations where multiple calls can be batched together.

### EIP-7702 Integration

[EIP-7702](https://eips.ethereum.org/EIPS/eip-7702) allows EOAs to temporarily delegate their code execution to a smart contract. This enables:

- **Batched Transactions**: Multiple contract calls in a single transaction
- **Transient Storage Persistence**: State persists across calls within the same transaction
- **Gas Efficiency**: Reduced overhead compared to multiple separate transactions
- **Enhanced UX**: Users can perform complex operations atomically

### Payment Validation

The contract validates:
- Payment ID matches between commit and reveal
- Recipient address matches
- Declared amount matches actual transferred amount
- USDC balance increase equals declared amount

## Development

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- Node.js (for additional tooling)

### Project Structure

```
├── src/
│   ├── Eventor.sol          # Main payment validation contract
│   ├── EventorHarness.sol   # Test version without EOA restriction
│   └── IEventor.sol         # Interface definition
├── test/
│   └── Eventor.t.sol        # Test suite
├── script/
│   ├── DeployEventor.s.sol  # Deployment script
│   └── README.md            # Deployment instructions
└── lib/                     # Dependencies
```

### Running Tests

The test suite uses mainnet forking to test with real USDC transactions:

```bash
# Run with specific RPC
forge test --fork-url https://ethereum-rpc.publicnode.com

# Run with high verbosity for debugging
forge test -vvvv

# Test commit-reveal pattern
forge test --match-test test_EventorDoubleCall -vvv

# Test EOA restriction
forge test --match-test test_EventorOnlyEOA -vvv
```

## Security Considerations

- Contract only accepts calls from EOAs (`tx.origin == msg.sender`)
- Uses transient storage to prevent cross-transaction state pollution
- Validates payment amounts and recipients before event emission
- Requires exact parameter matching between calls
- **EIP-7702 Design**: All operations must be batched in one transaction, preventing state manipulation across separate transactions

## License

MIT

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## Resources

- [Foundry Documentation](https://book.getfoundry.sh/)
- [Solidity Transient Storage](https://soliditylang.org/blog/2024/01/26/transient-storage/)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/)
