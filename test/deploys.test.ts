import { expect } from 'chai';
import { deployEmana } from '../scripts/deployEmana';
import { defaultICOSettings, deployEmanaICO } from '../scripts/deployEmanaICO';
import {
  deployBUSDMock,
  deployUSDTMock,
  deployDAIMock,
  // deployPancakeRouterMock,
} from '../scripts/deployMocks';
import { getSignerAddresses } from '../utils/signers';

describe('Individual deploys', async () => {
  it('deploy emana', async () => {
    const { emana } = await deployEmana();
    expect(emana).to.exist;
  });

  it('deploy busd mock', async () => {
    const { busd } = await deployBUSDMock();
    expect(busd).to.exist;
  });

  it('deploy usdt mock', async () => {
    const { usdt } = await deployUSDTMock();
    expect(usdt).to.exist;
  });
  it('deploy dai mock', async () => {
    const { dai } = await deployDAIMock();
    expect(dai).to.exist;
  });

  // it('deploy router mock', async () => {
  //   const { pancakeRouter } = await deployPancakeRouterMock();
  //   expect(pancakeRouter).to.exist;
  // });

  it('deploy ico', async () => {
    const addr = await getSignerAddresses();
    const { emanaAddr } = await deployEmana();
    const { busdAddr } = await deployBUSDMock();
    const { usdtAddr } = await deployUSDTMock();
    const { daiAddr } = await deployDAIMock();
    // const { pancakeRouterAddr } = await deployPancakeRouterMock();

    const { minPurchaseInUsd, emanaPerUsd } = defaultICOSettings;

    const { emanaICO } = await deployEmanaICO({
      emanaAddr,
      busdAddr,
      usdtAddr,
      daiAddr,
      // pancakeRouterAddr,
      liquidityAddr: addr.liquidity,
      projectAddr: addr.project,
      operation1Addr: addr.operation1,
      operation2Addr: addr.operation2,
      minPurchaseInUsd,
      emanaPerUsd,
    });

    expect(emanaICO).to.exist;
  });
});
