import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import { configDotenv } from "dotenv";

configDotenv();

const pk = process.env.PK!;

const config: HardhatUserConfig = {
  solidity: "0.8.27",
  defaultNetwork: "sepolia",
  networks: {
    sepolia: {
      url: "https://sepolia.infura.io/v3/b7346d6e7f12453f820ba5f60b684014",
      accounts: [pk]
    },
  },
};

export default config;
