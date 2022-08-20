// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import {DSTest} from "ds-test/test.sol";
import {Utilities} from "./utils/Utilities.sol";
import {console} from "./utils/Console.sol";
import {Vm} from "forge-std/Vm.sol";

import {ArbitraryNFT} from "../ArbitraryNFT.sol";
import {Base64} from "../Base64.sol";

contract ContractTest is DSTest, ArbitraryNFT {

    Vm internal immutable vm = Vm(HEVM_ADDRESS);

    Utilities internal utils = new Utilities();
    address payable[] internal users = utils.createUsers(2);

    address internal immutable alice = users[0];
    address internal immutable bob = users[1];

    constructor() ArbitraryNFT("TestCollection", "TSTC", "NFT #1", "A description", "https://i.imgur.com/FjvC1fc.jpeg", alice) {}

    function stringCompare(string memory str1, string memory str2) internal pure returns (bool) {
        return keccak256(abi.encodePacked(str1)) == keccak256(abi.encodePacked((str2)));
    }

    function setUp() public {
        vm.label(alice, "Alice");
        vm.label(bob, "Bob");
    }

    function testContractCreation() public {
        console.log("testing contract creation...");

        assertTrue(stringCompare(name(), "TestCollection"));
        assertTrue(stringCompare(symbol(), "TSTC"));

        assertTrue(stringCompare(tokenName, "NFT #1"));
        assertTrue(stringCompare(tokenDescription, "A description"));
        assertTrue(stringCompare(tokenImage, "https://i.imgur.com/FjvC1fc.jpeg"));
    }

    function testOwnership() public {
        console.log("testing ownership...");

        assertTrue(owner() == alice);
        assertTrue(ownerOf(tokenId) == alice);
        assertTrue(balanceOf(alice) == 1);
        assertTrue(balanceOf(bob) == 0);

        vm.prank(alice);

        // transfer ownership of the *token*
        this.safeTransferFrom(alice, bob, tokenId);

        assertTrue(owner() != alice);
        assertTrue(ownerOf(tokenId) != alice);

        assertTrue(owner() == bob);
        assertTrue(ownerOf(tokenId) == bob);

        assertTrue(balanceOf(alice) == 0);
        assertTrue(balanceOf(bob) == 1);

        vm.prank(bob);

        // transfer ownership of the *collection*
        this.transferOwnership(alice);

        assertTrue(owner() != bob);
        assertTrue(ownerOf(tokenId) != bob);

        assertTrue(owner() == alice);
        assertTrue(ownerOf(tokenId) == alice);

        assertTrue(balanceOf(alice) == 1);
        assertTrue(balanceOf(bob) == 0);
    }

    function testUri() public {
        console.log("testing token URI...");

        string memory expectedUri = string(abi.encodePacked('data:application/json;base64,', Base64.encode(bytes(abi.encodePacked(
            '{"name":"NFT #1", "description":"A description", "image":"https://i.imgur.com/FjvC1fc.jpeg"}'
        )))));

        string memory actualUri = tokenURI(tokenId);

        assertTrue(stringCompare(expectedUri, actualUri));
    }

    function testBurn() public {
        console.log("testing burn...");

        vm.prank(alice);
        this.burn();
        
        // TODO probably a better way to test this
        assertTrue(false);
    }
}
