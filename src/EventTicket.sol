// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "openzeppelin-contracts/contracts/token/ERC1155/extensions/ERC1155URIStorage.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/security/Pausable.sol";
import "openzeppelin-contracts/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract EventTicket is ERC1155, Ownable, Pausable, ERC1155Supply {
    string public name;
    string public symbol;
    string public contractURI;
    string public baseURI;

    mapping(uint => uint) public ticketPrice;
    mapping(uint => bool) public forSale;
    mapping(uint => uint) public capacity;
    address public immutable revenueAddress;

    /**
     * @dev Create the smart contract with first event
     * @param _revenueAddress Address to send revenue to
     * @param _capacity Capacity of the event
     * @param _ticketPrice Price of the ticket
     */
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _contractURI,
        string memory _baseURI,
        address _revenueAddress,
        uint _capacity,
        uint _ticketPrice
    ) ERC1155("") {
        name = _name;
        symbol = _symbol;
        contractURI = _contractURI;
        baseURI = _baseURI;

        revenueAddress = _revenueAddress;
        ticketPrice[1] = _ticketPrice;
        capacity[1] = _capacity;
        forSale[1] = true;
    }

    /**
     * @dev Buy a ticket
     * @param _eventId Event ID
     * @param _address Address to send the ticket to
     */
    function mint(uint _eventId, address _address) public payable {
        require(forSale[_eventId], "Event is not for sale");
        require(totalSupply(_eventId) < capacity[_eventId], "Event is full");
        require(msg.value >= ticketPrice[_eventId], "Not enough tokens sent");
        require(balanceOf(_address, _eventId) == 0, "Already has a ticket");

        _mint(_address, _eventId, 1, "");
        // Send revenue to revenueAddress
        (bool success, ) = payable(revenueAddress).call{
            value: ticketPrice[_eventId]
        }("");
        require(success, "Failed to send revenue");

        // Refund excess ether
        if (msg.value > ticketPrice[_eventId]) {
            (success, ) = payable(msg.sender).call{
                value: msg.value - ticketPrice[_eventId]
            }("");
            require(success, "Failed to refund");
        }
    }

    /**
     * @dev Free mint tickets to a list of addresses by the owner
     * @param _eventId Event ID
     * @param _addresses Addresses to send the tickets to
     */
    function freeMint(
        uint _eventId,
        address[] memory _addresses
    ) public onlyOwner {
        // !: does not check for capacity or if the event is for sale
        for (uint i = 0; i < _addresses.length; i++) {
            _mint(_addresses[i], _eventId, 1, "");
        }
    }

    /**
     * @dev Set the price of a ticket
     * @param _eventId Event ID
     * @param _price Price of the ticket
     */
    function setTicketPrice(uint _eventId, uint _price) public onlyOwner {
        ticketPrice[_eventId] = _price;
    }

    /**
     * @dev Set the capacity of an event
     * @param _eventId Event ID
     * @param _capacity Capacity of the event
     */
    function setCapacity(uint _eventId, uint _capacity) public onlyOwner {
        capacity[_eventId] = _capacity;
    }

    /**
     * @dev Set the event to be for sale
     * @param _eventId Event ID
     * @param _forSale Whether the event is for sale
     */
    function setForSale(uint _eventId, bool _forSale) public onlyOwner {
        forSale[_eventId] = _forSale;
    }

    /**
     * @dev Create a new event
     * @param _capacity Capacity of the event
     * @param _ticketPrice Price of the ticket
     * @param _eventId Event ID
     */
    function createEvent(
        uint _capacity,
        uint _ticketPrice,
        uint _eventId
    ) public onlyOwner {
        ticketPrice[_eventId] = _ticketPrice;
        capacity[_eventId] = _capacity;
        forSale[_eventId] = true;
    }

    /**
     * @dev Get the URI of a token
     */
    function uri(
        uint256 _tokenid
    ) public view override returns (string memory) {
        return
            string(
                abi.encodePacked(baseURI, Strings.toString(_tokenid), ".json")
            );
    }

    /**
     * @dev Set the base URI
     */
    function setBaseURI(string memory _baseURI) public onlyOwner {
        baseURI = _baseURI;
    }

    /**
     * @dev Set the contract URI
     */
    function setContractURI(string memory _contractURI) public onlyOwner {
        contractURI = _contractURI;
    }

    /**
     * @dev Pause the contract
     */
    function pause() public onlyOwner {
        _pause();
    }

    /**
     * @dev Unpause the contract
     */
    function unpause() public onlyOwner {
        _unpause();
    }

    /**
     * @dev Tickets are not transferrable except during minting
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155, ERC1155Supply) whenNotPaused {
        require(
            from == address(0) || to == address(0),
            "Tickets are not transferrable"
        );
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}
