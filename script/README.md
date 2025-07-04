# Deployment Scripts

## Deploy Eventor Contract

To deploy the Eventor contract, run:

```bash
forge script script/DeployEventor.s.sol --rpc-url <RPC_URL> --broadcast --verify
```

### Environment Variables

Make sure to set the following environment variables:

- `PRIVATE_KEY`: Your deployer private key
- `ETHERSCAN_API_KEY`: (Optional) For contract verification

### Example Commands

#### Deploy to Sepolia
```bash
forge script script/DeployEventor.s.sol --rpc-url https://sepolia.infura.io/v3/YOUR_PROJECT_ID --broadcast --verify
```

#### Deploy to Mainnet
```bash
forge script script/DeployEventor.s.sol --rpc-url https://mainnet.infura.io/v3/YOUR_PROJECT_ID --broadcast --verify
```

### Local Testing

To test deployment locally:

```bash
forge script script/DeployEventor.s.sol --fork-url <RPC_URL>
``` 