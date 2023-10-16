import path from 'path';
import dotenv from 'dotenv';
import { HardhatUserConfig } from 'hardhat/config';
import '@nomicfoundation/hardhat-toolbox';
import '@nomicfoundation/hardhat-chai-matchers';
import '@nomicfoundation/hardhat-ethers';
import '@nomicfoundation/hardhat-verify';
import '@nomiclabs/hardhat-solhint';
import '@openzeppelin/hardhat-upgrades';
import '@typechain/hardhat';
import 'hardhat-gas-reporter';

dotenv.config({ path: path.resolve(process.cwd(), '.env.local') });

export const envConfig = {
  coinmarketcapApiKey: process.env.COINMARKETCAP_API_KEY,
  mainnet: {
    url: process.env.MAINNET_RPC_URL as string,
  },
  staging: {
    url: process.env.STAGING_RPC_URL as string,
    busd: process.env.STAGING_BUSD as string,
    usdt: process.env.STAGING_USDT as string,
    dai: process.env.STAGING_DAI as string,
    deployer: process.env.STAGING_DEPLOYER as string,
    liquidity: process.env.STAGING_LIQUIDITY as string,
    project: process.env.STAGING_PROJECT as string,
    operation1: process.env.STAGING_OPERATION_1 as string,
    operation2: process.env.STAGING_OPERATION_2 as string,
    buyer1: process.env.STAGING_BUYER_1 as string,
    buyer2: process.env.STAGING_BUYER_2 as string,
    buyer3: process.env.STAGING_BUYER_3 as string,
  },
} as const;

const config: HardhatUserConfig = {
  solidity: {
    compilers: [
      { version: '0.8.19' },
      { version: '0.6.6' },
      { version: '0.6.0' },
      { version: '0.5.16' },
      { version: '0.5.0' },
    ],
  },

  gasReporter: {
    enabled: true,
    outputFile: './generated/gas-report.txt',
    noColors: true,
    currency: 'PHP',
    token: 'BNB',
    coinmarketcap: envConfig.coinmarketcapApiKey,
    gasPriceApi: 'https://api.bscscan.com/api?module=proxy&action=eth_gasPrice',
  },

  defaultNetwork: 'localhost',
  networks: {
    localhost: {
      url: 'http://127.0.0.1:8545/',
      // forking: {
      //   url: envConfig.mainnet.url,
      // },
      chainId: 31337,
      accounts: 'remote',
      initialBaseFeePerGas: 0,
    },

    staging: {
      url: envConfig.staging.url,
      chainId: 97,
      accounts: [
        envConfig.staging.deployer,
        envConfig.staging.liquidity,
        envConfig.staging.project,
        envConfig.staging.operation1,
        envConfig.staging.operation2,
        envConfig.staging.buyer1,
        envConfig.staging.buyer2,
        envConfig.staging.buyer3,
      ],
    },
  },
};

export default config;
