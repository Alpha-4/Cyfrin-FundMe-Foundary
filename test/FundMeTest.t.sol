// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint constant SEND_VALUE = 6e18;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerFundMe() public view {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFundedDatastructure() public fundedByUSER {
        uint256 ethSend = 6e18;
        uint256 amount = fundMe.getAddressToAmountFunded(USER);
        assertEq(amount, ethSend);
    }

    function testAddFunderToZeroIndex() public fundedByUSER {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier fundedByUSER() {
        uint256 ethSend = 6e18;
        vm.deal(USER, 10e18);
        vm.prank(USER);
        fundMe.fund{value: ethSend}();
        _;
    }

    modifier fundedByOwner() {
        address owner = fundMe.getOwner();
        uint256 ethSend = 6e18;
        vm.deal(owner, 10e18);
        vm.prank(owner);
        fundMe.fund{value: ethSend}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public fundedByUSER {
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithOwner() public fundedByOwner {
        //Arrange
        address owner = fundMe.getOwner();
        uint256 ownerBalance = owner.balance;
        uint256 ownerFundContractBalance = fundMe.getAddressToAmountFunded(
            owner
        );

        //Act
        vm.prank(owner);
        fundMe.withdraw();

        //Assert
        assertEq(
            fundMe.getOwner().balance,
            ownerBalance + ownerFundContractBalance
        );
        assertEq(fundMe.getAddressToAmountFunded(owner), 0);
    }

    function testWithdrawFromMultipleFunders() public {
        //Arrange
        uint160 noOfFunders = 10;
        uint160 startingFunderIndex = 1;
        address owner = fundMe.getOwner();
        uint256 initialOwnerBalance = owner.balance;

        //Act
        for (uint160 i = startingFunderIndex; i <= noOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }

        vm.startPrank(owner);
        fundMe.withdraw();
        vm.stopPrank();

        //Assert
        assertEq(owner.balance, initialOwnerBalance + 10 * SEND_VALUE);
    }

    function testWithdrawWithASingleFunder() public fundedByUSER {
        //Arrange
        address owner = fundMe.getOwner();

        //Act
        //Assert
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }
}
