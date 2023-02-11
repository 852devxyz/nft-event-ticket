# NFT Ticket Contract

0. Install Foundry:
```
curl -L https://foundry.paradigm.xyz | bash;
foundryup
```

1. Test contract:
```
forge install
forge build
forge test -vvvv --gas-report
```

2. Deploy contract:
```
forge create --rpc-url RPC-API-ENDPOINT-HERE \
--constructor-args ... \
--private-key YOUR_PRIVATE_KEY \
src/EventTicket.sol:EventTicket 
```

* Token standard: ERC1155
* Inheritances: ERC1155, Ownable, Pausable, ERC1155Supply
* Each token ID represents one IRL event

| State Variable   | Data Type               | Usage                                     |
| ---------------- | ----------------------- | ----------------------------------------- |
| `ticketPrice`    | `mapping(uint => uint)` | Maps tokenId to price                     |
| `forSale`        | `mapping(uint => bool)` | Maps whether tokenId is for sale          |
| `revenueAddress` | `address`               | The address where ticket fees are sent to |
| `capacity`       | `mapping(uint => uint)` | Maximum supply of each tokenId            |


#### Custom/Override functions:

| Function                        | Description                                                                     | Declaration        |
| ------------------------------- | ------------------------------------------------------------------------------- | ------------------ |
| `mint(uint, address)`           | Mint a token of based on id to recipient address, send fee to `revenueAddress`  | `public payable`   |
| `freeMint(uint, address[])`     | Mint an event ticket to a list of specific addresses (e.g. for guest, giveaway) | `public onlyOwner` |
| `setRevenueAddress(address)`    | Set the revenue address to a new address                                        | `public OnlyOwner` |
| `setForSale(uint, bool)`        | Toggle the forSale mapping for a tokenId                                        | `public OnlyOwner` |
| `setTicketPrice(uint, uint)`    | Set the ticket price for the given token id                                     | `public OnlyOwner` |
| `setCapacity(uint, uint)`       | Set the event capacity for the given token id                                   | `public OnlyOwner` |
| `createEvent(uint, uint, uint)` | Create an event by calling `setForSale`, `setTicketPrice`, `setCapacity`        | `public OnlyOwner` |

**Override all the transfer related functions to make it soulbound**
**Also need to expose some internal functions for pausing, etc., use OpenZeppelinContractsWizard for easy setup.**

#### Example Usage for each event:
1. Create a new event by supplying token id, ticket price, and capacity
2. Unpause minting (default should be paused)
3. Users mint tickets at ticket price until capacity is full or until we pause
4. Owner can also mint tickets to guests or for giveways

#### Test cases:
1. Should create event (only owner)
2. Should mint ticket
3. Should not mint ticket if msg.value != price
4. Should not mint ticket if event is at capacity
5. should not mint ticket if id is not for sale
6. Should pause/unpause minting (only owner)
7. Should mint for free to list of addresses (only owner)
8. Should not transfer tokens