// SPDX-License-Identifier: MIT
// 1. Pragma
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe {
    uint256 constant FUND_VALUE = 0.01 ether;
    function fundTheFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).fund{value: FUND_VALUE}();
        vm.stopBroadcast();
        console.log("FundMe contract is funded with: %s", FUND_VALUE);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        fundTheFundMe(mostRecentlyDeployed);
    }
}
