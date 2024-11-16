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

    IERC20 public usdc;
    mapping(uint256 => address) public postOwners;
    mapping(uint256 => uint256) public postPrices;
    uint256 public nextPostId;

    event CreationRegistered(uint256 indexed postId, address indexed creator, uint256 price);
    event TokensRewarded(address indexed recipient, uint256 amount);
    /**
     * @dev Constructor that mints an initial supply of KRE tokens to the deployer's address.
     * @param initialSupply The initial supply of tokens (in smallest unit, 18 decimals).
     */
    constructor(address initialOwner, uint256 initialSupply) ERC20("Kreator Token", "KRE") Ownable(initialOwner) {
        _mint(msg.sender, initialSupply * 10**decimals());
    }

    function registerCreation(uint256 price) external {
        require(price > 0, "Price must be greater than 0");

        uint256 postId = nextPostId;
        nextPostId += 1;

        // Store the post details
        postOwners[postId] = msg.sender;
        postPrices[postId] = price;

        SafeERC20.safeTransfer(
                IERC20(this),
                msg.sender,
                2 ether
        );

        emit CreationRegistered(postId, msg.sender, price);
        emit TokensRewarded(msg.sender, 2 ether);
    }


    /**
     * @dev Function to reward creators for registering content.
     * @param recipient Address to receive the reward.
     */
    function rewardForCreation(address recipient) external onlyOwner {
        require(recipient != address(0), "Invalid recipient address");
        _mint(recipient, 2 ether); // Reward with 2 KRE tokens
    }

    /**
     * @dev Function to reward users for reposting content.
     * @param recipient Address to receive the reward.
     */
    function rewardForRepost(address recipient) external onlyOwner {
        require(recipient != address(0), "Invalid recipient address");
        _mint(recipient, 1 ether); // Reward with 1 KRE token
    }

    /**
     * @dev Function to reward users for commenting.
     * @param recipient Address to receive the reward.
     */
    function rewardForComment(address recipient) external onlyOwner {
        require(recipient != address(0), "Invalid recipient address");
        _mint(recipient, 1 ether); // Reward with 1 KRE token
    }

    /**
     * @dev Function to handle token burns for platform sustainability.
     * @param amount Amount of tokens to burn (in smallest unit).
     */
    function burn(uint256 amount) external onlyOwner {
        _burn(msg.sender, amount);
    }
}
