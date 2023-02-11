// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/EventTicket.sol";

contract EventTicketTest is Test {
    EventTicket public eventTicket;

    address ownerAddress = address(0x1111);
    address revenueAddress = address(0x2222);
    address aliceAddress = address(0x3333);
    address bobAddress = address(0x4444);

    function setUp() public {
        vm.deal(ownerAddress, 10 ether);
        vm.deal(revenueAddress, 10 ether);
        vm.deal(aliceAddress, 10 ether);
        vm.deal(bobAddress, 10 ether);

        vm.prank(ownerAddress);
        eventTicket = new EventTicket(
            "852Web3 Event Ticket",
            "TIX",
            "https://852web3.io/static/nft/1.json",
            "https://852web3.io/static/nft/1.json",
            revenueAddress,
            1,
            1 ether
        );

        assertEq(eventTicket.owner(), ownerAddress);
        assertEq(eventTicket.revenueAddress(), revenueAddress);

        assertEq(eventTicket.name(), "852Web3 Event Ticket");
        assertEq(eventTicket.symbol(), "TIX");
        assertEq(eventTicket.contractURI(), "https://852web3.io/static/nft/1.json");
        assertEq(eventTicket.uri(1), "https://852web3.io/static/nft/1.json");
        assertEq(eventTicket.ticketPrice(1), 1 ether);
        assertEq(eventTicket.capacity(1), 1);
        assertEq(eventTicket.forSale(1), true);

    }

    // Should mint ticket
    function testMint() public {
        vm.prank(aliceAddress);
        eventTicket.mint{value: 1 ether}(1, aliceAddress);
        assertEq(eventTicket.balanceOf(aliceAddress, 1), 1);
        assertEq(revenueAddress.balance, 11 ether);
        assertEq(aliceAddress.balance, 9 ether);
        assertEq(eventTicket.totalSupply(1), 1);
    }

    // Should mint ticket and refund extra tokens
    function testMintRefund() public {
        vm.prank(aliceAddress);
        eventTicket.mint{value: 2 ether}(1, aliceAddress);
        assertEq(eventTicket.balanceOf(aliceAddress, 1), 1);
        assertEq(revenueAddress.balance, 11 ether);
        assertEq(aliceAddress.balance, 9 ether);
    }

    // Should not mint ticket if underpaid
    function testMintUnderpaid() public {
        vm.expectRevert(bytes("Not enough tokens sent"));
        vm.prank(aliceAddress);
        eventTicket.mint{value: 0.5 ether}(1, aliceAddress);
    }

    // Should not mint ticket if event is full
    function testMintFull() public {
        vm.prank(aliceAddress);
        eventTicket.mint{value: 1 ether}(1, aliceAddress);
        vm.expectRevert(bytes("Event is full"));
        vm.prank(bobAddress);
        eventTicket.mint{value: 1 ether}(1, bobAddress);
    }

    // Should not mint ticket if event is not for sale
    function testMintNotForSale() public {
        vm.prank(ownerAddress);
        eventTicket.setForSale(1, false);
        vm.expectRevert(bytes("Event is not for sale"));
        vm.prank(aliceAddress);
        eventTicket.mint{value: 1 ether}(1, aliceAddress);
    }

    // Should not mint ticket if already has a ticket
    function testMintAlreadyHasTicket() public {
        vm.prank(ownerAddress);
        eventTicket.setCapacity(1, 2);
        vm.prank(aliceAddress);
        eventTicket.mint{value: 1 ether}(1, aliceAddress);
        vm.expectRevert(bytes("Already has a ticket"));
        vm.prank(aliceAddress);
        eventTicket.mint{value: 1 ether}(1, aliceAddress);
    }

    // Should free mint
    function testFreeMint() public {
        vm.prank(ownerAddress);
        address[] memory addresses = new address[](2);
        addresses[0] = aliceAddress;
        addresses[1] = bobAddress;
        eventTicket.freeMint(1, addresses);
        assertEq(eventTicket.balanceOf(aliceAddress, 1), 1);
        assertEq(eventTicket.balanceOf(bobAddress, 1), 1);
    }

    // Should not free mint if not owner
    function testFreeMintNotOwner() public {
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        vm.prank(aliceAddress);
        address[] memory addresses = new address[](2);
        addresses[0] = aliceAddress;
        addresses[1] = bobAddress;
        eventTicket.freeMint(1, addresses);
    }

    // Should set for sale
    function testSetForSale() public {
        vm.prank(ownerAddress);
        eventTicket.setForSale(1, false);
        assertEq(eventTicket.forSale(1), false);
    }

    // Should not set for sale if not owner
    function testSetForSaleNotOwner() public {
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        vm.prank(aliceAddress);
        eventTicket.setForSale(1, false);
    }

    // Should set capacity
    function testSetCapacity() public {
        vm.prank(ownerAddress);
        eventTicket.setCapacity(1, 2);
        assertEq(eventTicket.capacity(1), 2);
    }

    // Should not set capacity if not owner
    function testSetCapacityNotOwner() public {
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        vm.prank(aliceAddress);
        eventTicket.setCapacity(1, 2);
    }

    // Should set ticket price
    function testSetTicketPrice() public {
        vm.prank(ownerAddress);
        eventTicket.setTicketPrice(1, 2 ether);
        assertEq(eventTicket.ticketPrice(1), 2 ether);
    }

    // Should not set ticket price if not owner
    function testSetTicketPriceNotOwner() public {
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        vm.prank(aliceAddress);
        eventTicket.setTicketPrice(1, 2 ether);
    }

    // Should set revenue address
    function testSetRevenueAddress() public {
        vm.prank(ownerAddress);
        eventTicket.setRevenueAddress(address(0x5555));
        assertEq(eventTicket.revenueAddress(), address(0x5555));
    }

    // Should not set revenue address if not owner
    function testSetRevenueAddressNotOwner() public {
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        vm.prank(aliceAddress);
        eventTicket.setRevenueAddress(address(0x5555));
    }

    // Should create event
    function testCreateEvent() public {
        vm.prank(ownerAddress);
        eventTicket.createEvent(2, 2 ether, 2, "Test Event 2");
        assertEq(eventTicket.ticketPrice(2), 2 ether);
        assertEq(eventTicket.capacity(2), 2);
        assertEq(eventTicket.forSale(2), true);
        assertEq(eventTicket.uri(2), "Test Event 2");
        vm.prank(aliceAddress);
        eventTicket.mint{value: 2 ether}(2, aliceAddress);
        assertEq(eventTicket.balanceOf(aliceAddress, 2), 1);
    }

    // Should not create event if not owner
    function testCreateEventNotOwner() public {
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        vm.prank(aliceAddress);
        eventTicket.createEvent(2, 2 ether, 2, "");
    }

    // Should not transfer token
    function testTransfer() public {
        vm.prank(aliceAddress);
        eventTicket.mint{value: 1 ether}(1, aliceAddress);
        assertEq(eventTicket.balanceOf(aliceAddress, 1), 1);
        vm.expectRevert(bytes("Tickets are not transferrable"));
        vm.prank(aliceAddress);
        eventTicket.safeTransferFrom(aliceAddress, bobAddress, 1, 1, "");
    }

    // Should pause
    function testPause() public {
        vm.prank(ownerAddress);
        eventTicket.pause();
        assertEq(eventTicket.paused(), true);
        vm.expectRevert(bytes("Pausable: paused"));
        vm.prank(aliceAddress);
        eventTicket.mint{value: 1 ether}(1, aliceAddress);
    }

    // Should not pause if not owner
    function testPauseNotOwner() public {
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        vm.prank(aliceAddress);
        eventTicket.pause();
    }

    // Should unpause
    function testUnpause() public {
        vm.prank(ownerAddress);
        eventTicket.pause();
        assertEq(eventTicket.paused(), true);
        vm.expectRevert(bytes("Pausable: paused"));
        vm.prank(aliceAddress);
        eventTicket.mint{value: 1 ether}(1, aliceAddress);
        vm.prank(ownerAddress);
        eventTicket.unpause();
        assertEq(eventTicket.paused(), false);
        vm.prank(aliceAddress);
        eventTicket.mint{value: 1 ether}(1, aliceAddress);
    }

    // Should not unpause if not owner
    function testUnpauseNotOwner() public {
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        vm.prank(aliceAddress);
        eventTicket.unpause();
    }

    // Should set contract URI
    function testSetContractURI() public {
        vm.prank(ownerAddress);
        eventTicket.setContractURI("testing");
        assertEq(eventTicket.contractURI(), "testing");
    }

    // Should not set contract URI if not owner
    function testSetContractURINotOwner() public {
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        vm.prank(aliceAddress);
        eventTicket.setContractURI("testing");
    }

    // Should set URI
    function testSetURI() public {
        vm.prank(ownerAddress);
        eventTicket.setURI(1, "testing");
        assertEq(eventTicket.uri(1), "testing");
    }

    // Should not set URI if not owner
    function testSetURINotOwner() public {
        vm.expectRevert(bytes("Ownable: caller is not the owner"));
        vm.prank(aliceAddress);
        eventTicket.setURI(1, "testing");
    }
}
