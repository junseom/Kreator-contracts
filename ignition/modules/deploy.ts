const { ethers } = require("hardhat");

async function deploy() {
    const signers = await ethers.getSigners();
    const owner = signers[0];

    // Deploy Kreator contract
    const Kreator = await ethers.getContractFactory("Kreator");
    const kreator = await Kreator.deploy();
    await kreator.waitForDeployment();
    const kreatorAddress = await kreator.getAddress();
    console.log("Kreator deployed to:", kreatorAddress);

    // Deploy GoodsStore contract
    const GoodsStore = await ethers.getContractFactory("GoodsStore");
    const goodsStore = await GoodsStore.deploy(owner.address);
    await goodsStore.waitForDeployment();
    const goodsStoreAddress = await goodsStore.getAddress();
    console.log("GoodsStore deployed to:", goodsStoreAddress);
}

// Run the deployment script
deploy().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
