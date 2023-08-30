import dotenv from 'dotenv';
import { HardhatUserConfig } from 'hardhat/config';
import '@nomicfoundation/hardhat-toolbox';
import '@nomicfoundation/hardhat-ethers';
import 'hardhat-deploy';
import 'hardhat-gas-reporter';

dotenv.config();

const config: HardhatUserConfig = {
  solidity: '0.8.19',
  defaultNetwork: 'hardhat',

  networks: {
    localhost: {
      url: 'http://127.0.0.1:8545/',
    },
    // testnet: {
    //   url: 'https://data-seed-prebsc-1-s1.binance.org:8545/',
    //   chainId: 97,
    //   accounts: [process.env.PRIVATE_KEY as string],
    // },
  },
};

export default config;
