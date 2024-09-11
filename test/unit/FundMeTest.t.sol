//SPDX-License-Identifier: MIT 

pragma solidity ^0.8.18;

import {Test, console} from  "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test{
    FundMe fundMe;
    

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;


    function setUp() external {
        ///us - fundmete4st - fundme 
       // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306); 
       DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER,STARTING_BALANCE);
    }

    //function testMinimumDollorIsFive() public {
    //    assertEq(fundMe.MINIMUM_USD(), 5e18);
        
   // }
   //unit: testing specific part of code .
   //Integration : testing how our code works with other part of our code .
   //Forked : testing our code on a simulated real enviroment .
   //staging: testing our code in a real enviroment that is not prod . 

    function testOwnerIsMsgSender() public view {
       // assertEq(fundMe.i_owner(), msg.sender);


    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public{
        vm.expectRevert(); // <- The next line after this one should revert! If not test fails. 
        fundMe.fund(); // <- We send 0 value . 
    }

     function testFundUpdatesFundedDataStructure() public{
        vm.prank(USER);
        
        //fundMe.fund{value: 10e18}
        
        
        fundMe.fund{value: SEND_VALUE} ();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public{
        vm.startPrank(USER);
        fundMe.fund{value: SEND_VALUE}();
        vm.stopPrank();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        fundMe.withdraw();

    }
        modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
       // assert(address(fundMe).balance > 0);
        _;

    }

    function testWithDrawWithASingleFunder() public funded{
        //arrange
        //Act
        //test 
        uint256 startingOwnerBalance= fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;


       // uint256 gasStart = gasleft(); //100
        ///vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());//c: 200 
        fundMe.withdraw();
        vm.stopPrank();// should have spent gas?

        //uint256 gasEnd = gasleft();//800 
        //uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        //console.log(gasUsed);

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }

    function testWithdrawFromMultipleFunders() public funded{
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for(uint160 i = startingFunderIndex; i< numberOfFunders; i++){
            //vm.prank new address
            //vm.deal new address
            //ADDRESS(0)
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
            //fund the fundMe
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    }

    function testWithdrawFromMultipleFundersCheaper() public funded{
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for(uint160 i = startingFunderIndex; i< numberOfFunders; i++){
            //vm.prank new address
            //vm.deal new address
            //ADDRESS(0)
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
            //fund the fundMe
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    }

    

        //function getOwner() private view returns (address) {
       // return i_owner;

    //}
}
