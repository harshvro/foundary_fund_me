// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {fundMe} from "src/fundMe.sol";
import {PriceConvert} from "src/PriceConvertor.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    fundMe fundme;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_VALUE = 10 ether;

    // PriceConvert priceconvert;

    function setUp() external {
        DeployFundMe deployfundme = new DeployFundMe();
        fundme = deployfundme.run();
        vm.deal(USER, STARTING_VALUE);
    }

    function testDemoOfMinUsd() public {
        assertEq(fundme.minUSd(), 5e18);
    }

    function testOwner() public {
        // console.log(fundme.owner());
        // console.log(address(this));
        assertEq(fundme.getOwner(), msg.sender);
    }

    function testGetVersion() public {
        uint256 temp = fundme.getVersion();
        // console.log("error is  = ");
        // console.log(temp);
        assertEq(temp, 4);
    }

    function testfundFailedNotEnoughEthidontknow() public {
        vm.expectRevert();
        fundme.fund();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); //the next tx will be send by the user
        fundme.fund{value: SEND_VALUE}();
        //create a fake user who gonna send the transaction
        uint256 amountFunded = fundme.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddFundersToArray() public {
        vm.prank(USER);
        fundme.fund{value: SEND_VALUE}();
        address theFundersAddress = fundme.getFunders(0);
        assertEq(theFundersAddress, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundme.fund{value: SEND_VALUE}();
        _;
    }

    //only the owner can use the withdraw function
    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundme.withDraw();
    }

    function testWithdrawWithTheSingleFunder() public funded {
        uint256 initialOwnerBalance = fundme.getOwner().balance;
        uint256 initialFundMeBalance = address(fundme).balance;

        vm.prank(fundme.getOwner());
        fundme.withDraw();

        uint256 endingOwnerBalance = fundme.getOwner().balance;
        uint256 endingfundeMebalance = address(fundme).balance;

        assertEq(endingfundeMebalance, 0);
        assertEq(
            initialFundMeBalance + initialOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawWithMoreThan10Funders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingIndex = 1;
        for (uint160 i = startingIndex; i <= numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE);
            fundme.fund{value: SEND_VALUE}();
        }

        uint256 startingFundsOfTheOwners = fundme.getOwner().balance;
        uint256 startingFundMeFunds = address(fundme).balance;

        vm.startPrank(fundme.getOwner());
        fundme.withDraw();
        vm.stopPrank();

        assertEq(address(fundme).balance, 0);
        assertEq(
            startingFundMeFunds + startingFundsOfTheOwners,
            fundme.getOwner().balance
        );
    }
}
