import { ethers } from "hardhat";

async function deploy() {
    const signers = await ethers.getSigners();
    const owner = signers[0];
    const initialSupply = ethers.parseEther("1000000");

    // Deploy Kreator contract
    const KREToekn = await ethers.getContractFactory("KREToken");
    const kretoken = await KREToekn.deploy(owner.address, initialSupply);
    await kretoken.waitForDeployment();
    const kretokenAddress = await kretoken.getAddress();
    console.log("Kreator deployed to:", kretokenAddress);

    // Deploy GoodsStore contract
    const MockUSDC = await ethers.getContractFactory("MockUSDC");
    const mockUSDC = await MockUSDC.deploy(initialSupply);
    await mockUSDC.waitForDeployment();
    const mockUSDCAddress = await mockUSDC.getAddress();
    console.log("GoodsStore deployed to:", mockUSDCAddress);
}

// Run the deployment script
deploy().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

// npx hardhat run ignition/modules/deploy.ts --network localhost