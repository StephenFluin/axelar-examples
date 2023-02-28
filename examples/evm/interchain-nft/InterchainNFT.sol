// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import { AxelarExecutable } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol';
import { IAxelarGateway } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol';
import { IAxelarGasService } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol';
import { IERC20 } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IERC20.sol';
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Counters.sol';

contract InterchainNFT is AxelarExecutable, ERC721, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    string public value;
    string public remoteChain;
    string public remoteAddress;
    IAxelarGasService public immutable gasService;

    string public status;

    mapping(uint256 => string) private _tokenURIs;

    constructor(address gateway_, address gasReceiver_) AxelarExecutable(gateway_) ERC721('MyToken', 'MTK') {
        gasService = IAxelarGasService(gasReceiver_);
        safeMint(msg.sender);
    }

    function safeMint(address to) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _tokenURIs[tokenId] = 'https://fluin.io/assets/speakers/0.json';
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), 'ERC721Metadata: URI query for nonexistent token');
        return _tokenURIs[tokenId];
    }

    function send(bytes memory payload) internal {
        if (msg.value > 0) {
            gasService.payNativeGasForContractCall{ value: msg.value }(address(this), remoteChain, remoteAddress, payload, msg.sender);
        }
        gateway.callContract(remoteChain, remoteAddress, payload);
    }

    function connectNFTs(string calldata destinationChain, string calldata destinationAddress) external payable {
        // Method 0, connect
        remoteChain = destinationChain;
        remoteAddress = destinationAddress;
        bytes memory payload = abi.encode(1);
        send(payload);
    }

    function update(string calldata newURI, uint token) external payable {
        _tokenURIs[token] = newURI;
        if (bytes(remoteChain).length <= 0 || bytes(remoteAddress).length <= 0) {
            // This NFT isn't connected, so it won't be transferred everywhere
            return;
        }
        bytes memory payload = abi.encode(2, newURI, token);
        send(payload);
    }

    // Handles calls created by setAndSend. Updates this contract's value
    function _execute(string calldata sourceChain_, string calldata sourceAddress_, bytes calldata payload_) internal override {
        status = 'executing';
        uint method;
        (method) = abi.decode(payload_, (uint8));
        // Connect
        if (method == 1) {
            remoteChain = sourceChain_;
            remoteAddress = sourceAddress_;

            // Update
        } else if (method == 2) {
            uint tokenId;
            string memory newURI;

            (, newURI, tokenId) = abi.decode(payload_, (uint8, string, uint));
            _tokenURIs[tokenId] = newURI;
        }
    }
}
