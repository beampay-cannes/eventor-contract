// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {Eventor} from "../src/Eventor.sol";

contract DeployEventor is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy Eventor contract
        Eventor eventor = new Eventor();
        
        console.log("Eventor deployed at:", address(eventor));
        
        vm.stopBroadcast();
    }
} 