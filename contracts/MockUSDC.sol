// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title MockUSDC
 * @dev A mock USDC contract for testing purposes.
 */
contract MockUSDC is ERC20 {
    /**
     * @dev Constructor that mints an initial supply of USDC to the deployer's address.
     * @param initialSupply The initial supply of tokens (in smallest unit, 6 decimals).
     */
    constructor(uint256 initialSupply) ERC20("Mock USDC", "USDC") {
        // USDC typically has 6 decimals, overriding decimals to match
        _mint(msg.sender, initialSupply * 10**decimals());
    }

    /**
     * @dev Override decimals to set it to 6, matching USDC standards.
     */
    function decimals() public pure override returns (uint8) {
        return 6;
    }
}
