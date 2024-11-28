// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {SmartFunding} from "../src/SmartFunding.sol";
import {console} from "forge-std/console.sol";

contract FundSmartFunding is Script {
    uint256 constant SEND_VALUE = 0.1 ether;

    function fundSmartFundingContract(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        SmartFunding(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded contract with %s", SEND_VALUE);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "SmartFunding",
            block.chainid
        );
        vm.startBroadcast();
        fundSmartFundingContract(mostRecentlyDeployed);
        vm.stopBroadcast();
    }
}

contract WithdrawFunds is Script {
    function withdrawFunds(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        SmartFunding(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "SmartFunding",
            block.chainid
        );
        withdrawFunds(mostRecentlyDeployed);
    }
}
