// SPDX-License-Identifier: NLPL
pragma solidity ^0.8.16;

import {ERC721} from "openzeppelin-contracts/token/ERC721/ERC721.sol";
import {Ownable} from "openzeppelin-contracts/access/Ownable.sol";
import "./Base64.sol";

/*
* An ERC721 contract which mints the provided metadata as a 1 of 1 NFT collection.
*
* The collection is owned by the token holder, which allows them to modify off-chain
* collection details on aggregation services like OpenSea.
*/
contract ArbitraryNFT is ERC721, Ownable {

    uint256 public constant tokenId = 0;

    string public tokenName;
    string public tokenDescription;
    string public tokenImage;

    constructor(string memory _collectionName, 
                string memory _collectionSymbol, 
                string memory _tokenName, 
                string memory _tokenDescription, 
                string memory _tokenImage, 
                address _recipient
                ) ERC721(_collectionName, _collectionSymbol) {
        tokenName = _tokenName;
        tokenDescription = _tokenDescription;
        tokenImage = _tokenImage;
        _mint(_recipient, tokenId);
        _transferOwnership(_recipient);
    }

    /*
    * Override the internal ERC721 token transfer function to also transfer ownership of this collection contract.
    */
    function _transfer(address _from, address _to, uint256 _tokenId) internal virtual override {
        super._transfer(_from, _to, _tokenId);
        _transferOwnership(_to);
    }

    /*
    * Override Ownable's public transferOwnership function to transfer both the token and this collection contract.
    * Note that this allows you to transfer ownership to the zero address, unlike standard Ownables.
    */
    function transferOwnership(address _newOwner) public virtual onlyOwner override {
        _transfer(_msgSender(), _newOwner, tokenId);
    }

    /*
    * In the context of this ERC721 NFT, you can only burn the token/contract, not renounce ownership.
    * This is because NFTs can't be transferred to the zero address, so neither should this contract.
    */
    function renounceOwnership() public virtual onlyOwner override {
        revert("ArbitraryNFT: you cannot renounce ownership");
    }

    /*
    * Generates the token metadata as a Base64 encoded json string from the tokenName, tokenDescription, and tokenImage.
    */
    function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
        require(_tokenId == tokenId, "ArbitraryNFT: invalid token ID");
        return string(abi.encodePacked('data:application/json;base64,', Base64.encode(bytes(abi.encodePacked(
            '{"name":"',
            tokenName,
            '", "description":"',
            tokenDescription,
            '", "image":"',
            tokenImage,
            '"}'
        )))));
    }

    /*
    * Burns the NFT (emitting a transfer event) and self destructs this collection contract.
    */
    function burn() external onlyOwner {
        _burn(tokenId);
        selfdestruct(payable(_msgSender()));
    }
}

/*
* A generator to create arbitrary 1 of 1 NFT collection contracts.  Simply provide:
*
* _collectionName - the name of the ERC721 collection
* _collectionSymbol - the short symbol for the collection
* _tokenName - the name of the ERC721 token itself
* _tokenDescription - a description for the token itself
* _tokenImage - A url or IPFS hash for the token image
* _recipient - the address to mint the NFT to
*/
contract ArbitraryNFTGenerator {

    function mint(string memory _collectionName, 
                  string memory _collectionSymbol, 
                  string memory _tokenName, 
                  string memory _tokenDescription, 
                  string memory _tokenImage, 
                  address _recipient
                  ) external {
        new ArbitraryNFT(_collectionName, _collectionSymbol, _tokenName, _tokenDescription, _tokenImage, _recipient);
    }
}