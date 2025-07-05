// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

// Deployment command:
// forge script script/DeployEventor.s.sol --rpc-url https://eth.meowrpc.com --broadcast --verify --etherscan-api-key $ETHERSCAN_KEY

import {Script, console} from "forge-std/Script.sol";
import {Eventor} from "../src/Eventor.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

IERC20 constant USDC_ETH = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
IERC20 constant USDC_ZIRCUIT = IERC20(0x3b952c8C9C44e8Fe201e2b26F6B2200203214cfF);
IERC20 constant USDC_FLOW = IERC20(0x7f27352D5F83Db87a5A3E00f4B07Cc2138D8ee52);

contract DeployEventor is Script {
    // run:
    // forge script script/DeployEventor.s.sol --rpc-url https://mainnet.zircuit.com --broadcast --verify --verifier-url https://explorer.zircuit.com/api
    // forge script script/DeployEventor.s.sol --rpc-url https://mainnet.evm.nodes.onflow.org --broadcast
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        // Deploy Eventor contract
        Eventor eventor = new Eventor(USDC_FLOW);

        console.log("Eventor deployed at:", address(eventor));

        vm.stopBroadcast();
    }
}
