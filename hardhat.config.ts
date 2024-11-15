import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.27",
  networks: {
    goerli: {
        url: "https://eth-goerli.alchemyapi.io/v2/YOUR_ALCHEMY_API_KEY",
        accounts: ["d02e759ca27aa5fcbd9d4f8eb779f6e20c9c515722332b47a4ee37357a5e6a62"] // 배포 계정의 개인 키
    },
  }
};

export default config;
