// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {SmartFunding} from "../../src/SmartFunding.sol";
import {DeploySmartFunding} from "../../script/DeploySmartFunding.s.sol";

contract SmartFundingTest is Test {
    SmartFunding public smartFunding;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        DeploySmartFunding deployer = new DeploySmartFunding();
        (smartFunding, ) = deployer.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public view {
        assertEq(smartFunding.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        address owner = smartFunding.getOwner();
        assertEq(owner, msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        if (block.chainid == 11155111) {
            assertEq(smartFunding.getVersion(), 4);
        } else if (block.chainid == 1) {
            assertEq(smartFunding.getVersion(), 6);
        }
    }

    function testFundFailsWithoutEnoughEth() public {
        vm.expectRevert();
        smartFunding.fund();
    }

    function testFundUpdatesFundedDataStructures() public {
        vm.prank(USER);
        smartFunding.fund{value: SEND_VALUE}();
        uint256 amountFunded = smartFunding.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        smartFunding.fund{value: SEND_VALUE}();
        address funder = smartFunding.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        smartFunding.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        smartFunding.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        uint256 startingOwnerBalance = smartFunding.getOwner().balance;
        uint256 startingFundingContractBalance = address(smartFunding).balance;

        vm.prank(smartFunding.getOwner());
        smartFunding.withdraw();

        uint256 endingOwnerBalance = smartFunding.getOwner().balance;
        uint256 endingFundingContractBalance = address(smartFunding).balance;
        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundingContractBalance
        );
        assertEq(endingFundingContractBalance, 0);
    }

    function testWithdrawFromMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        for (uint160 i = 1; i < numberOfFunders; i++) {
            hoax(address(i), 1 ether);
            smartFunding.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = smartFunding.getOwner().balance;
        uint256 startingFundingContractBalance = address(smartFunding).balance;

        vm.prank(smartFunding.getOwner());
        smartFunding.withdraw();

        uint256 endingOwnerBalance = smartFunding.getOwner().balance;
        uint256 endingFundingContractBalance = address(smartFunding).balance;

        assertEq(
            endingOwnerBalance,
            startingOwnerBalance + startingFundingContractBalance
        );
        assertEq(endingFundingContractBalance, 0);
    }
}
