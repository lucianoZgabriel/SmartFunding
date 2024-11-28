// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Script} from "forge-std/Script.sol";
import {SmartFunding} from "../src/SmartFunding.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeploySmartFunding is Script {
    function run() external returns (SmartFunding, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        address priceFeed = helperConfig.activeNetworkConfig();
        vm.startBroadcast();
        SmartFunding smartFunding = new SmartFunding(priceFeed);
        vm.stopBroadcast();
        return (smartFunding, helperConfig);
    }
}
