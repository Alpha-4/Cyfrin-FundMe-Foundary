// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        // not a part of on-chain transaction
        HelperConfig config = new HelperConfig();
        address networkConfig = config.activeNetworkConfig();

        // part of on-chain transaction
        vm.startBroadcast();
        FundMe fundMe = new FundMe(networkConfig);
        vm.stopBroadcast();
        // transaction block ends here

        return fundMe;
    }
}
