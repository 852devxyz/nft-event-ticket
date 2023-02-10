// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/EventTicket.sol";

contract EventTicketTest is Test {
    EventTicket public eventTicket;

    function setUp() public {
        eventTicket = new EventTicket();
        // eventTicket.setNumber(0);
    }

    // function testIncrement() public {
    //     eventTicket.increment();
    //     assertEq(eventTicket.number(), 1);
    // }

    // function testSetNumber(uint256 x) public {
    //     eventTicket.setNumber(x);
    //     assertEq(eventTicket.number(), x);
    // }
}
