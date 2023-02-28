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

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));


async function execute(chains, wallet, options) {
    const args = options.args || [];
    const { source, destination, calculateBridgeFee } = options;
    const message = args[2] || `Hello ${destination.name} from ${source.name}, it is ${new Date().toLocaleTimeString()}.`;

    async function logValue() {
        console.log('Source chain is:',source.name);
        console.log(`URL of token 0  is "${await source.contract.tokenURI(0)}"`);
        console.log(`status/method  are "${await source.contract.status()}" "${await source.contract.method()}"`);
        console.log(`NFT connection to ${await source.contract.remoteChain()} ${await source.contract.remoteAddress()} `)
        console.log('Destination chain:',destination.name);
        console.log(`URL of token 0 is "${await destination.contract.tokenURI(0)}"`);
        console.log(`status/method are "${await destination.contract.status()}" "${await destination.contract.method()}"`);
        console.log(`NFT connection to ${await destination.contract.remoteChain()} ${await destination.contract.remoteAddress()} `)
   
    }

    console.log('--- Initially ---');
    await logValue();


    console.log('---Unconnected NFT Changezzz---');
    const fee = await calculateBridgeFee(source, destination);
    let tx = await source.contract.update('https://new.example.com/nft.json',0);
    console.log('tx is',typeof tx);
    console.log('that was the tx!');
    await tx.wait();

    await logValue();



    console.log('---Connnected NFT---')
    const tx2 = await source.contract.connectNFTs(destination.name, destination.contract.address, {
        value: fee
    });
    await tx2.wait();
    await logValue();

    let method;
    do {
        await sleep(1000);
        method = await destination.contract.method();
        // console.log('method is',method,typeof method);
        // await logValue();
    }
        while (method <= 0);

    console.log('--- After Connection ---');
    await logValue();

    console.log('--- After final Update --');
    let tx3 = await source.contract.update('https://new2.example.com/nft.json',0, {
        value: fee,
    });
    await tx3.wait();
    do {
        await sleep(1000);
        method = await destination.contract.method();
        // console.log('method is',method,typeof method);
        // await logValue();
    }
        while (method <= 1);

    await logValue();

    
}

module.exports = {
    deploy,
    execute,
};
