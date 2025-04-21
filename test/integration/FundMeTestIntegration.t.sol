// SPDX-License-Identifier: MIT
// 1. Pragma
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe} from "../../script/Interactions.s.sol";

contract FundMeTestIntegration is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint constant SEND_VALUE = 6e18;
    uint constant STARTING_BALANCE = 10e18;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        //vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundTheFundMe = new FundFundMe();

        vm.deal(USER, STARTING_BALANCE);
        console.log("funds are >> %s", USER.balance);
        vm.startPrank(USER);
        fundTheFundMe.fundTheFundMe(address(fundMe));
        vm.stopPrank();

        address firstFunder = fundMe.getFunder(0);
        assertEq(firstFunder, USER);
    }
}
