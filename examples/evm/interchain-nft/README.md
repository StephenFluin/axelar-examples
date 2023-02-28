# Call Contract Example

This example demonstrates how to build an NFT that when updated, updates remote counterparts

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

## Example

This example deploys the contract on a local network and connects two NFTs and propagates an update between them

```bash
npm run deploy evm/interchain-nft local
npm run execute evm/interchain-nft local 
```

The output will be:

```
--- Initially ---
Source chain is: Avalanche
URL of token 0 is "https://fluin.io/assets/speakers/0.json"
NFT connection to   
Destination chain: Fantom
URL of token 0 is "https://fluin.io/assets/speakers/0.json"
NFT connection to   
Source chain is: Avalanche
URL of token 0 is "https://fluin.io/assets/speakers/0.json"
NFT connection to Fantom 0xB1D096C2C9A23aeA9e8B00a84df77065D3c2e47C 
Destination chain: Fantom
URL of token 0 is "https://fluin.io/assets/speakers/0.json"
NFT connection to   
Remote connection created successfully!
Shared NFT Updates successful!
Source chain is: Avalanche
URL of token 0 is "https://fluin.io/assets/speakers/4.json"
NFT connection to Fantom 0xB1D096C2C9A23aeA9e8B00a84df77065D3c2e47C 
Destination chain: Fantom
URL of token 0 is "https://fluin.io/assets/speakers/4.json"
NFT connection to Avalanche 0x46d5a602A224c78Fbf1EDE6aB48c33fCdcD11097 
```
