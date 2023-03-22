# Homework 5 - Optimizing Your NFT Marketplace

At this point, you've gotten a chance to get your hands dirty with implementing some logic of a potential NFT Marketplace. However, after watching the lecture on gas optimization, you may now notice that the logic you implemented for the NFT Marketplace contains a lot of red flags. 

In this homework, you will be going back to your NFTMarketplace.sol file, and trying your hand at simplification and reducing gas costs. 

Created by Daniel Gushchyan

## Foundry Gas Tools

Along with all the purposes we've introduced so far, Foundry provides a powerful set of tools for testing your contract and its gas usage.

Check out the [Gas Tracking](https://book.getfoundry.sh/forge/gas-tracking) section of the Foundry Book to learn about [Gas Reports](https://book.getfoundry.sh/forge/gas-reports.html) and [Gas Snapshots](https://book.getfoundry.sh/forge/gas-snapshots.html). 

## Homework Objective

The objective for this homework is to reduce the estimated gas cost of any of the functions in our contract by at least 20%. 
The way you'll be measuring this is by running `forge test --gas-report` before and after your changes, and each output as a text file [to this Google Form](https://forms.gle/mAR3gHbcrkNYwQa97).

You can pipe the gas report to a text file with `forge test --gas-report > FILENAME.txt`. Name your original report (before changes to NFTMarketplace) as `original.txt`, and after changes, `improvement.txt`. 

To track the effects of your changes, you should save the results of a gas report to a file before you begin changing `NFTMarketplace.sol`, and reference them you make changes and run new reports in the terminal.  


### Scope of Changes

This assignment is very open-ended. 

You have full reign over this contract when it comes to the changes you're allowed to do to decrease the cost of interacting with this contract. You're welcome to rewrite functions or even change the API (parameters, return variables, etc) of the contract. The only limitation is that it must provide the same features of minting NFTs, putting them up for sale, and facilitating purchases. 

We've covered many potential strategies for improving gas cost in our lecture, so refer to that for inspiration as needed. 

### Using Tests

You may find it helpful or even necessary to edit or write new tests to test the efficiency / functionality of your NFT Marketplace. This is especially true if you decide to adjust any parts of the API. Don't be intimidated! Foundry has great documentation explaining its testing suite. [You can find it here.](https://book.getfoundry.sh/forge/tests)

You're more than welcome to do this, and need to simply submit your updated test file and an explanation of what you did in the same submission form.

Before you begin, we have also made a new test that you are required to add to `NFTMarketplace.t.sol`! It contains some loops which will test minting and using many NFTs. It will be much harder to notice or take advantage of gas optimization opportunities if you do not stress test your Marketplace's data structures. This test has plenty of comments explaining how it works, which should help you bootstrap your Foundry Test writing skills.

As with before, you are free to adjust this test as you may wish for your testing and optimization purposes, as long as you are not making the test "easier".

``` Solidity
    function testMultiMintAndList() public {
        
        // Instantiate a new marketplace so that it doesn't interfere with other tests
        marketplace = new NFTMarketplace("Marketplace 2", "MKT", "Token");

        // Supply addresses 0x1 and 0x2 with 100 ether each.
        vm.deal(address(2), 100 ether);
        vm.deal(address(1), 100 ether);
        
        // Until vm.stopPrank is called, all function calls are done by address 0x2
        vm.startPrank(address(2));

        // Mints 20 NFTs and puts them on the market, such that the function caller (0x2) is the seller.
        for (uint i = 1; i <= 20; i++) {
            // We are passing a value of 0.025 to our transaction to pay the required marketplace fee.
            // We pass in 2 as the parameter for how much we want to put our nft on sale for.
            marketplace.createToken{value: 0.025 ether}(string.concat("Token ", Strings.toString(i)), 2 ether);
        }

        // Asserts that there are 20 items on the market right now that are sold
        assertEq(marketplace.fetchMarketItems().length, 20);

        /* Asserts that there are 20 items on the market right now that are being sold by 
            the address calling this function (0x2) */
        assertEq(marketplace.fetchItemsListed().length, 20);

        /* Since all NFTs are on the market right now, under the custody of the NFT Marketplace,  
            trying to fetch all owned NFTs should return 0*/
        assertEq(marketplace.fetchMyNFTs().length, 0);
        vm.stopPrank();

        // Now, we will take the role of address 0x1 and purchase 10 of 0x2's items off of the market.
        vm.startPrank(address(1));

        for (uint i = 1; i <= 10; i++) {
            marketplace.createMarketSale{value: 2 ether}(i);
        }

        assertEq(marketplace.fetchMyNFTs().length, 10);
        assertEq(marketplace.fetchMarketItems().length, 10);

        vm.stopPrank();
    }
```

## Hints

Use the `-vvvv` flag after `forge test` to get a full trace and printout of your code's execution.

If you're stuck and not sure what to change, consider [this part of the lecture.](https://youtu.be/Ena2F38Kgmc?t=847)