// SPDX-License-Identifier: MIT
// 1. Pragma
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant FUND_VALUE = 6 ether;
    function fundTheFundMe(address mostRecentlyDeployed) public {
        console.log("Funder is: %s", msg.sender);
        FundMe(payable(mostRecentlyDeployed)).fund{value: FUND_VALUE}();

        console.log("FundMe contract is funded with: %s", FUND_VALUE);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        vm.startBroadcast();
        fundTheFundMe(mostRecentlyDeployed);
        vm.stopBroadcast();
    }
}
