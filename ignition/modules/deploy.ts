const { ethers } = require("hardhat");

async function deploy() {
    // Deploy Kreator contract
    const Kreator = await ethers.getContractFactory("Kreator");
    const kreator = await Kreator.deploy();
    await kreator.deployed();
    console.log("Kreator deployed to:", kreator.address);

    // Deploy GoodsStore contract
    const GoodsStore = await ethers.getContractFactory("GoodsStore");
    const goodsStore = await GoodsStore.deploy();
    await goodsStore.deployed();
    console.log("GoodsStore deployed to:", goodsStore.address);
}

// Run the deployment script
deploy().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
