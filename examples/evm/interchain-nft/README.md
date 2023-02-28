# Call Contract Example

This example demonstrates how to build a self-registering NFT Chain

### Prerequisite

Make sure you've already followed the following steps:

-   [Setup environment variables](/README.md#set-environment-variables)
-   [Run the local chains](/README.md#running-the-local-chains)

### Deployment

To deploy the contract, use the following command:

```bash
npm run deploy evm/interchain-nft [local|testnet]
```

### Execution

To execute the example, use the following command:

```bash
npm run execute evm/interchain-nft [local|testnet] ${srcChain} ${destChain} ${message}
```

### Parameters

-   `srcChain`: The blockchain network from which the message will be relayed. Acceptable values include "Moonbeam", "Avalanche", "Fantom", "Ethereum", and "Polygon". Default value is Avalanche.
-   `destChain`: The blockchain network to which the message will be relayed. Acceptable values include "Moonbeam", "Avalanche", "Fantom", "Ethereum", and "Polygon". Default value is Fantom.
-   `message`: The message to be relayed between the chains. Default value is "Hello World".

## Example

This example deploys the contract on a local network and relays a message "Hello World" from Moonbeam to Avalanche.

```bash
npm run deploy evm/interchain-nft local
npm run execute evm/interchain-nft local "Fantom" "Avalanche" "Hello World"
```

The output will be:

```
--- Initially ---
value at Avalanche is
--- After ---
value at Avalanche is Hello World
```
