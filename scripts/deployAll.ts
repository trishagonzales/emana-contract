import { getSignerAddresses } from '../utils/signers';
import { envConfig } from '../hardhat.config';
import { deployEmana } from './deployEmana';
import {
  deployBUSDMock,
  deployDAIMock,
  deployUSDTMock,
  // deployPancakeRouterMock,
} from './deployMocks';
import { defaultICOSettings, deployEmanaICO } from './deployEmanaICO';
import { currentChainId } from '../utils/network';

async function deployAll() {
  const { emanaAddr } = await deployEmana();
  const { busdAddr } = await deployBUSDMock();
  const { usdtAddr } = await deployUSDTMock();
  const { daiAddr } = await deployDAIMock();
  const addr = await getSignerAddresses();

  // Local
  if (currentChainId === 31337) {
    // const { pancakeRouterAddr } = await deployPancakeRouterMock();

    await deployEmanaICO({
      emanaAddr,
      busdAddr,
      usdtAddr,
      daiAddr,
      // pancakeRouterAddr,
      liquidityAddr: addr.liquidity,
      projectAddr: addr.project,
      operation1Addr: addr.operation1,
      operation2Addr: addr.operation2,
      ...defaultICOSettings,
    });

    // Staging (testnet)
  } else if (currentChainId === 97) {
    await deployEmanaICO({
      emanaAddr,
      busdAddr,
      usdtAddr,
      daiAddr,
      // busdAddr: envConfig.staging.busd,
      // usdtAddr: envConfig.staging.usdt,
      // daiAddr: envConfig.staging.dai,
      // pancakeRouterAddr: envConfig.staging.pancakeRouter,
      liquidityAddr: addr.liquidity,
      projectAddr: addr.project,
      operation1Addr: addr.operation1,
      operation2Addr: addr.operation2,
      ...defaultICOSettings,
    });
  }
}

deployAll().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
