// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/NFT.sol";
import "../src/NFTMarketplace.sol";

contract NFTMarketplaceTest is Test {
    NFTMarketplace public marketplace;
    uint256 gasCost = 1e8;

    
    receive() external payable {}

    function setUp() public {
        marketplace = new NFTMarketplace("MarketplaceToken", "MKT", "Token");
        vm.deal(address(1), 4 ether);   
    }

    function testSingleMintAndUnsold() public {
        uint256 id1 = marketplace.createToken{value: marketplace.getListingPrice()}("Token 1", 2 ether);
        assertEq(id1, 1);
        NFTMarketplace.MarketItem[] memory unsold = marketplace.fetchMarketItems();
        assertEq(unsold.length, 1);
    }

    function testListingPrice() public {
        uint256 id1 = marketplace.createToken{value: 0.025 ether}("Token 1", 2 ether);
        assertEq(id1, 1);

        // this should go through
        marketplace.updateListingPrice(0.030 ether);
        emit log_named_uint("Listing price is now", marketplace.getListingPrice());
        
        // this should revert
        vm.expectRevert(bytes("Only contract owner can update listing price."));
        vm.prank(address(1));
        marketplace.updateListingPrice(0.030 ether);

    }

    function testMintAndBuy() public {
        uint256 id1 = marketplace.createToken{value: 0.025 ether}("Token 1", 2 ether);
        assertEq(id1, 1);
        vm.startPrank(address(1));
        marketplace.createMarketSale{value: 2 ether}(1);
        assertEq(marketplace.fetchMyNFTs().length, 1);
        // assertEq(marketplace.fetchMarketItems().length, 0);
        vm.stopPrank();
    }

    function testItemsListed() public {
        uint256 id1 = marketplace.createToken{value: 0.025 ether}("Token 1", 2 ether);
        assertEq(id1, 1);
        // assertEq(marketplace.fetchItemsListed().length, 1);
        vm.startPrank(address(1));
        marketplace.createMarketSale{value: 2 ether}(1);
        assertEq(marketplace.fetchMarketItems().length, 0);
        vm.stopPrank();
        // assertEq(marketplace.fetchItemsListed().length, 0);
    }

    function testMultiMintAndList() public {

        marketplace = new NFTMarketplace("Marketplace 2", "MKT", "Token");
        vm.deal(address(2), 100 ether);

        vm.startPrank(address(2));
        for (int i = 1; i <= 20; i++) {
            marketplace.createToken{value: 0.025 ether}(string.concat("Token ", Strings.toString(i)), 2 ether);
        }
        assertEq(marketplace.fetchMarketItems().length, 20);
        marketplace.fetchItemsListed();
        vm.stopPrank();

        // vm.startPrank(address(1));
        // marketplace.createMarketSale{value: 2 ether}(1);
        // assertEq(marketplace.fetchMarketItems().length, 19);
        // vm.stopPrank();
    }
}
