import { HardhatUserConfig } from "hardhat/config";
import "@openzeppelin/hardhat-upgrades";
import "@nomicfoundation/hardhat-ethers";
import "@nomicfoundation/hardhat-toolbox";
import * as dotenv from "dotenv";
dotenv.config();
import { EtherscanConfig } from "@nomiclabs/hardhat-etherscan/dist/src/types";

interface Config extends HardhatUserConfig {
  etherscan: EtherscanConfig;
}

const PRIVATE_KEY = process.env.PRIVATE_KEY || "";
const INFURA_KEY = process.env.INFURA_KEY;

const config: Config = {
  solidity: {
    version: "0.8.18",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    mainnet: {
      url: `https://mainnet.infura.io/v3/${INFURA_KEY}`,
      accounts: [PRIVATE_KEY],
    },
    goerli: {
      url: `https://goerli.infura.io/v3/${INFURA_KEY}`,
      accounts: [`0x${PRIVATE_KEY}`],
    },
    sepolia: {
      url: `https://sepolia.infura.io/v3/${INFURA_KEY}`,
      accounts: [`0x${PRIVATE_KEY}`],
    },
  },
  etherscan: {
    customChains: [],
    apiKey: {
      goerli: "T3S7NPQWMYC4ZTSS4YTU3F848XP7JAD2CE",
      sepolia: "T3S7NPQWMYC4ZTSS4YTU3F848XP7JAD2CE",
      mainnet: "YIUBT2TCTDZW5HWTV73GT3QAVY2R1JIZY5",
    },
  },
};

export default config;
