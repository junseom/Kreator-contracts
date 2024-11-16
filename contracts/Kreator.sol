// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Kreator is ERC1155, Ownable {
    uint256 private _tokenIdCounter;

    mapping(uint256 => uint256) public tokenPrices;
    mapping(uint256 => uint256) public salesProceeds;
    mapping(uint256 => address[]) public buyers;

    event NFTCreated(uint256 tokenId, address creator, string tokenURI);
    event NFTPurchased(uint256 tokenId, address buyer, uint256 price);
    event PayoutSent(uint256 tokenId, uint256 payoutAmount, address payoutAddress);

    constructor(address initialOwner, string memory uri) ERC1155(uri) Ownable(initialOwner) {}

    function createNFT(string memory tokenURI, uint256 price) public returns (uint256) {
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter += 1;

        // Set token URI (ERC-1155 does not support per-token URI out of the box)
        emit URI(tokenURI, tokenId);

        tokenPrices[tokenId] = price;

        emit NFTCreated(tokenId, msg.sender, tokenURI);
        return tokenId;
    }

    function purchaseNFT(uint256 tokenId, uint256 amount) public payable {
        require(tokenId < _tokenIdCounter, "Token does not exist");
        require(msg.value >= tokenPrices[tokenId] * amount, "Insufficient payment");

        address tokenOwner = owner();

        // Transfer funds to the owner
        salesProceeds[tokenId] += msg.value;
        payable(tokenOwner).transfer(msg.value);

        // Mint the NFT to the buyer
        _mint(msg.sender, tokenId, amount, "");

        // Track buyer
        buyers[tokenId].push(msg.sender);

        emit NFTPurchased(tokenId, msg.sender, msg.value);
    }

    function getBuyers(uint256 tokenId) public view returns (address[] memory) {
        require(tokenId < _tokenIdCounter, "Token does not exist");
        return buyers[tokenId];
    }

    function payoutSales(address payoutAddress, uint256 amount) public {
        require(payoutAddress != address(0), "Invalid payout address");
        require(amount > 0, "Amount must be greater than 0");

        payable(payoutAddress).transfer(amount);

        emit PayoutSent(0, amount, payoutAddress);
    }
}
