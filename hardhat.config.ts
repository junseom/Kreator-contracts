import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const pk = process.env.PK!;

const config: HardhatUserConfig = {
  solidity: "0.8.27",
  networks: {
    goerli: {
        url: "https://eth-goerli.alchemyapi.io/v2/YOUR_ALCHEMY_API_KEY",
        accounts: [pk] // 배포 계정의 개인 키
    },
  }
};

export default config;
