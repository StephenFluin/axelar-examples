// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import { AxelarExecutable } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol';
import { IAxelarGateway } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol';
import { IAxelarGasService } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol';
import { IERC20 } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IERC20.sol';
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import { StringToAddress, AddressToString } from '@axelar-network/axelar-gmp-sdk-solidity/contracts/utils/AddressString.sol';


contract InterchainNFT is AxelarExecutable, ERC721, Ownable {
    using Counters for Counters.Counter;
    using StringToAddress for string;

    Counters.Counter public tokenIdCounter;

    string public status;
    uint8 public method;
    string public remoteChain;
    string public remoteAddress;

    mapping(uint256 => string) private _tokenURIs;

    IAxelarGasService public immutable gasService;

   constructor(address gateway_, address gasReceiver_) AxelarExecutable(gateway_) ERC721("InterchainNFT", "INFT") {
        gasService = IAxelarGasService(gasReceiver_);
        safeMint(msg.sender);
    }

    function safeMint(address to) public onlyOwner {
        uint256 tokenId = tokenIdCounter.current();
        tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _tokenURIs[tokenId] = "https://example.org/nft.json";
    }

    function tokenURI(uint256 tokenId)
        public view virtual override returns (string memory)
    {
        require(_exists(tokenId),"ERC721Metadata: URI query for nonexistent token");
        return _tokenURIs[tokenId];
    }

    function connectNFTs(
        string calldata destinationChain,
        string calldata destinationAddress
    ) external payable {
        // Method 0, connect
        remoteChain = destinationChain;
        remoteAddress = destinationAddress;
        bytes memory payload = abi.encode(1);
        if (msg.value > 0) {
            status = string(abi.encodePacked('paid: ',Strings.toString(msg.value)));
            gasService.payNativeGasForContractCall{ value: msg.value }(
                address(this),
                destinationChain,
                destinationAddress,
                payload,
                msg.sender
            );
        }
        gateway.callContract(remoteChain, remoteAddress, payload);
    }

    // Call this function to update the value of this contract along with its sibling
    function update(
         string calldata newURI, uint token
    ) external payable {
        _tokenURIs[token] = newURI;
        if( bytes(remoteChain).length <= 0 && bytes(remoteAddress).length <= 0) {
            // This NFT isn't connected, so it won't be transferred everywhere
            return; 
        }
        bytes memory payload = abi.encode(2, newURI, token);
        if (msg.value > 0) {
            gasService.payNativeGasForContractCall{ value: msg.value }(
                address(this),
                remoteChain,
                remoteAddress,
                payload,
                msg.sender
            );
        }
        gateway.callContract(remoteChain, remoteAddress, payload);
    }

    // Handles all types of incoming calls
    function _execute(
        string calldata sourceChain_,
        string calldata sourceAddress_,
        bytes calldata payload_
    ) internal override {
        status = "received";
        (method) = abi.decode(payload_, (uint8));
        // Connect
        // Received when a new NFT wants to pair with us
        if(method == 1) {
            status = "execution - connect recieved";
            remoteChain = sourceChain_;
            remoteAddress = sourceAddress_;

            
        // Update
        } else if (method == 2) {
            uint tokenId;
            string memory newURI;
            status = "execution - update recieved";

            (method, newURI, tokenId) = abi.decode(payload_, (uint8, string, uint));
            _tokenURIs[tokenId] = newURI;
        } 
        
    }
}
