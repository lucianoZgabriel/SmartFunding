// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {SmartFunding} from "../../src/SmartFunding.sol";
import {DeploySmartFunding} from "../../script/DeploySmartFunding.s.sol";
import {FundSmartFunding, WithdrawFunds} from "../../script/Interactions.s.sol";

contract InteractionsTest is Test {
    SmartFunding public smartFunding;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeploySmartFunding deployer = new DeploySmartFunding();
        (smartFunding, ) = deployer.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testUserCanFundInteractionsSuccessfully() public {
        vm.prank(USER);
        FundSmartFunding fund = new FundSmartFunding();
        fund.fundSmartFundingContract(address(smartFunding));

        address funder = smartFunding.getFunder(0);
        assertEq(funder, msg.sender);
    }

    function testUserCanWithdrawInteractionsSuccessfully() public {
        vm.prank(USER);
        FundSmartFunding fund = new FundSmartFunding();
        fund.fundSmartFundingContract(address(smartFunding));

        WithdrawFunds withdraw = new WithdrawFunds();
        withdraw.withdrawFunds(address(smartFunding));

        assert(address(smartFunding).balance == 0);
    }
}
