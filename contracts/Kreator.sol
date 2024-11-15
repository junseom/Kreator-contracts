// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Kreator is ERC721URIStorage, Ownable {
    uint256 private _tokenIdCounter;

    struct ViewRequest {
        address requester;
        bool approved;
    }

    mapping(uint256 => ViewRequest[]) public viewRequests;
    mapping(uint256 => uint256) public tokenPrices;
    mapping(uint256 => uint256) public salesProceeds;

    event NFTCreated(uint256 tokenId, address creator, string tokenURI);
    event ViewRequested(uint256 tokenId, address requester);
    event ViewRequestApproved(uint256 tokenId, address requester);
    event NFTPurchased(uint256 tokenId, address buyer, uint256 price);
    event PayoutSent(uint256 tokenId, uint256 payoutAmount, address payoutAddress);

    constructor() ERC721("Kreator", "KRT") Ownable(msg.sender) {}

    function createNFT(string memory tokenURI, uint256 price) public returns (uint256) {
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter += 1;

        _mint(msg.sender, tokenId);
        _setTokenURI(tokenId, tokenURI);
        tokenPrices[tokenId] = price;

        emit NFTCreated(tokenId, msg.sender, tokenURI);
        return tokenId;
    }

    function requestView(uint256 tokenId) public {
        require(_tokenIdCounter >= tokenId, "Token does not exist");
        viewRequests[tokenId].push(ViewRequest(msg.sender, false));
        emit ViewRequested(tokenId, msg.sender);
    }

    function approveViewRequest(uint256 tokenId, address requester) public {
        require(ownerOf(tokenId) == msg.sender, "Only the owner can approve view requests");
        ViewRequest[] storage requests = viewRequests[tokenId];
        bool found = false;

        for (uint256 i = 0; i < requests.length; i++) {
            if (requests[i].requester == requester && !requests[i].approved) {
                requests[i].approved = true;
                found = true;
                emit ViewRequestApproved(tokenId, requester);
                break;
            }
        }
        require(found, "No pending request found for this requester");
    }

    function hasViewAccess(uint256 tokenId, address user) public view returns (bool) {
        require(_tokenIdCounter >= tokenId, "Token does not exist");
        ViewRequest[] storage requests = viewRequests[tokenId];
        for (uint256 i = 0; i < requests.length; i++) {
            if (requests[i].requester == user && requests[i].approved) {
                return true;
            }
        }
        return false;
    }

    function getViewAccessList(uint256 tokenId) public view returns (address[] memory) {
        require(_tokenIdCounter >= tokenId, "Token does not exist");
        ViewRequest[] storage requests = viewRequests[tokenId];
        uint256 count = 0;

        for (uint256 i = 0; i < requests.length; i++) {
            if (requests[i].approved) {
                count++;
            }
        }

        address[] memory approvedUsers = new address[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < requests.length; i++) {
            if (requests[i].approved) {
                approvedUsers[index] = requests[i].requester;
                index++;
            }
        }

        return approvedUsers;
    }

    function purchaseNFT(uint256 tokenId) public payable {
        require(_tokenIdCounter >= tokenId, "Token does not exist");
        require(hasViewAccess(tokenId, msg.sender), "You do not have view access to this NFT");
        require(msg.value >= tokenPrices[tokenId], "Insufficient payment");

        address tokenOwner = ownerOf(tokenId);
        require(tokenOwner != msg.sender, "You already own this NFT");

        _transfer(tokenOwner, msg.sender, tokenId);
        salesProceeds[tokenId] += msg.value;

        emit NFTPurchased(tokenId, msg.sender, msg.value);
    }

    function payoutSales(address payoutAddress, uint256 amount) public {
        require(payoutAddress != address(0), "Invalid payout address");

        payable(payoutAddress).transfer(amount);

        emit PayoutSent(0, amount, payoutAddress);
    }
}
