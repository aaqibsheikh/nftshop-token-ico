// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./INFTShop.sol";

contract NFTShopToken is ERC20, Ownable {
    // price of one token
    uint256 public constant tokenPrice = 0.0001 ether;

    // 10 (10 * 10 **18) token give to per NFT holders
    uint256 public constant tokensPerNFT = 10 * 10**18;
    // max supply of tokens
    uint256 public constant maxTokenSupply = 11111 * 10**18;
    // NFTShop instance
    INFTShop NFTShop;
    // claimed tokenIds track
    mapping(uint256 => bool) public tokenIdsClaimed;

    constructor(address _nftshopContract) ERC20("NFTShop Token", "NST") {
        NFTShop = INFTShop(_nftshopContract);
    }

    function mint(uint256 amount) public payable {
        uint256 _requiredAmount = amount * tokenPrice;
        require(msg.value >= _requiredAmount, "Ether sent is not correct" );
        uint256 amountWithDecimals = amount * 10**18;
        require(totalSupply() + amountWithDecimals <= maxTokenSupply, "Exceed the max total supply available");
        _mint(msg.sender, amountWithDecimals);
    }

    // claim tokens who have held NFTShop NFT
    function claim() public {
        address sender = msg.sender;
        // how much nfts held by this address
        uint256 balance = NFTShop.balanceOf(sender);
        require(balance > 0, "You don't own any NFTShop NFT");

        // logic to keep track of number of unclaimed tokenIds
        uint256 amount = 0;
        // loop over the balance and get the token ID owned by `sender` at a given `index` of its token list.
        for(uint256 i = 0; i < balance; i++) {
            uint256 tokenId = NFTShop.tokenOfOwnerByIndex(sender, i);
            if(!tokenIdsClaimed[tokenId]) {
                amount += 1;
                tokenIdsClaimed[tokenId] = true;
            }
        }

        // If all the token Ids have been claimed, revert the transaction;
        require(amount > 0, "You have already claimed the tokens");
        _mint(msg.sender, amount * tokensPerNFT);
    }

    function withdraw() public onlyOwner {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send ether");
    }

    receive() external payable {}
    fallback() external payable {}
}