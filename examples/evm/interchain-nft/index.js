'use strict';

const {
    utils: { deployContract },
} = require('@axelar-network/axelar-local-dev');

const InterchainNFT = rootRequire('./artifacts/examples/evm/interchain-nft/InterchainNFT.sol/InterchainNFT.json');

async function deploy(chain, wallet) {
    console.log(`Deploying InterchainNFT for ${chain.name}.`);
    chain.contract = await deployContract(wallet, InterchainNFT, [chain.gateway, chain.gasService]);
    chain.wallet = wallet;
    console.log(`Deployed InterchainNFT for ${chain.name} at ${chain.contract.address}.`);
}

async function execute(chains, wallet, options) {
    const args = options.args || [];
    const { source, destination, calculateBridgeFee } = options;
    const message = args[2] || `Hello ${destination.name} from ${source.name}, it is ${new Date().toLocaleTimeString()}.`;

    async function logValue() {
        console.log('Source chain is:', source.name);
        console.log(` URL of token 0 is "${await source.contract.tokenURI(0)}"`);
        console.log(` NFT connection to ${await source.contract.remoteChain()} ${await source.contract.remoteAddress()} `)
        console.log('Destination chain:', destination.name);
        console.log(` URL of token 0 is "${await destination.contract.tokenURI(0)}"`);
        console.log(` NFT connection to ${await destination.contract.remoteChain()} ${await destination.contract.remoteAddress()} `);
        console.log('-');
    }

    console.log('--- Initially ---');
    await logValue();

    const fee = await calculateBridgeFee(source, destination);

    const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
    const tx = await source.contract.connectNFTs(destination.name, destination.contract.address, {
        value: fee
    });
    await tx.wait();

    console.log('Remote connection created successfully!');

    const newURI = 'https://fluin.io/assets/speakers/4.json';
    let tx2 = await source.contract.update(newURI, 0, {
        value: fee,
    });
    await tx2.wait();
    while (await destination.contract.tokenURI(0) !== newURI) {
        await sleep(1000);
    }

    console.log('Shared NFT Updates successful!');

    await logValue();
}

module.exports = {
    deploy,
    execute,
};
