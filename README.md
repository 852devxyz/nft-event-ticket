0. Install Foundry:
```
curl -L https://foundry.paradigm.xyz | bash;
foundryup
```

1. Test contract:
```
forge install
forge build
forge test --gas-report
```

2. Deploy contract:
```
forge create --rpc-url RPC-API-ENDPOINT-HERE \
--constructor-args ... \
--private-key YOUR_PRIVATE_KEY \
src/EventTicket.sol:EventTicket 
```