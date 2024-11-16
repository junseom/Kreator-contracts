// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title KRE Token
 * @dev ERC20 Token with Ownable functionality for managing specific platform operations.
 */
contract KREToken is ERC20, Ownable {
    using SafeERC20 for IERC20;

    address public usdcAddress;
    mapping(uint256 => address) public postOwners;
    mapping(uint256 => uint256) public postPrices;
    mapping(uint256 => uint256) public revenueOf;
    uint256 public nextPostId;

    event CreationRegistered(uint256 indexed postId, address indexed creator, uint256 price);
    event TokensRewarded(address indexed recipient, uint256 amount);
    event RevenueDistributed(uint256 postId, address postOwners, uint256 revenue);

    constructor(address initialOwner, uint256 initialSupply, address mockUSDC) ERC20("Kreator Token", "KRE") Ownable(initialOwner) {
        _mint(msg.sender, initialSupply * 10**decimals());
        usdcAddress = mockUSDC;
    }

    function registerCreation(uint256 price) external {
        require(price > 0, "Price must be greater than 0");

        uint256 postId = nextPostId;
        nextPostId += 1;

        // Store the post details
        postOwners[postId] = msg.sender;
        postPrices[postId] = price;

        _mint(msg.sender, 2 ether); // Reward with 2 KRE tokens

        emit TokensRewarded(msg.sender, 2 ether);
    }

    function rewardForRepost() external {
        _mint(msg.sender, 1 ether); // Reward with 1 KRE token
        emit TokensRewarded(msg.sender, 1 ether);
    }

    function rewardForComment() external  {
        _mint(msg.sender, 1 ether); // Reward with 1 KRE token
        emit TokensRewarded(msg.sender, 1 ether);
    }

    function buy(uint256 postId) external {
        // transferFrom(token, amount, from, to)
        // USDC approve가 먼저 되어있어야 한다 -> front에서 해야 함
        uint256 price = postPrices[postId];
        address productOwner = postOwners[postId];

        SafeERC20.safeTransferFrom(
            IERC20(usdcAddress),
            msg.sender,
            address(this),
            2 ether
        );
        _mint(productOwner, 2 ether);

        revenueOf[postId] += price;
        
        emit TokensRewarded(productOwner, 2 ether);
    }

    address public artistEOA;
    address public donationEOA;

    function distribute(uint postId) external onlyOwner {
        uint256 revenue = revenueOf[postId];

        uint256 artistShare = (revenue * 30) / 100;
        uint256 donationShare = (revenue * 30) / 100;
        uint256 creatorShare = (revenue * 30) / 100;
        uint256 platformShare = (revenue * 5) / 100;
        uint256 burned = (revenue * 5) / 100;

        _burn(owner(), burned);

        SafeERC20.safeTransfer(
            IERC20(usdcAddress),
            artistEOA,
            artistShare * 10 ** decimals()
        );

        SafeERC20.safeTransfer(
            IERC20(usdcAddress),
            donationEOA,
            donationShare * 10 ** decimals()
        );

        SafeERC20.safeTransfer(
            IERC20(usdcAddress),
            postOwners[postId],
            creatorShare * 10 ** decimals()
        );

        revenueOf[postId] = 0;

        emit RevenueDistributed(postId, postOwners[postId], revenue);
    }

}
