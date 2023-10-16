import { loadFixture } from '@nomicfoundation/hardhat-network-helpers';
import { deployEmana } from '../../scripts/deployEmana';
import {
  defaultICOSettings,
  deployEmanaICO,
} from '../../scripts/deployEmanaICO';
import {
  deployBUSDMock,
  deployDAIMock,
  deployUSDTMock,
} from '../../scripts/deployMocks';
import { getSignerAddresses, getSigners } from '../../utils/signers';
import { ZeroAddress, formatEther, parseEther } from 'ethers';
import { expect } from 'chai';
import { Emana, EmanaICO } from '../../typechain-types';

describe.only('Emana ICO', async () => {
  async function fixture() {
    const addr = await getSignerAddresses();
    const { emana, emanaAddr } = await deployEmana();
    const { busd, busdAddr } = await deployBUSDMock();
    const { usdt, usdtAddr } = await deployUSDTMock();
    const { dai, daiAddr } = await deployDAIMock();

    const { minPurchaseInUsd, emanaPerUsd } = defaultICOSettings;

    const { emanaICO, emanaICOAddr } = await deployEmanaICO({
      emanaAddr,
      busdAddr,
      usdtAddr,
      daiAddr,
      liquidityAddr: addr.liquidity,
      projectAddr: addr.project,
      operation1Addr: addr.operation1,
      operation2Addr: addr.operation2,
      minPurchaseInUsd,
      emanaPerUsd,
    });

    return {
      emanaICO,
      emanaICOAddr,
      emana,
      emanaAddr,
      busd,
      usdt,
      dai,
      minPurchaseInUsd,
      emanaPerUsd,
    };
  }

  describe('BUSD', async () => {
    it('purchase using busd for $10', async () => {
      const { emanaICO, emana, emanaAddr, busd, emanaICOAddr } =
        await loadFixture(fixture);
      const signers = await getSigners();
      const addr = await getSignerAddresses();

      const emanaAdmin = emana.connect(signers.deployer);
      await emanaAdmin.grantGovernance(emanaICOAddr);

      await busd.transfer(signers.buyer1, parseEther('10').toString());

      const busdBalance = formatEther(await busd.balanceOf(addr.buyer1));
      console.log('initial balance: ' + busdBalance);

      const toPay = parseEther('10').toString();
      const buyerICO = emanaICO.connect(signers.buyer1) as EmanaICO;
      const buyerBusd = busd.connect(signers.buyer1);

      await buyerBusd.approve(emanaICOAddr, toPay);
      await buyerICO.purchaseUsingBusd(toPay, ZeroAddress);

      const busdBalance2 = formatEther(await busd.balanceOf(addr.buyer1));
      console.log('after balance: ' + busdBalance2);
    });

    // it('Grant governance', async () => {
    //   const { emana, emanaAddr, emanaICO, emanaICOAddr } = await loadFixture(
    //     fixture
    //   );
    //   const signers = await getSigners();
    //   const addr = await getSignerAddresses();

    //   await emana.grantGovernance(emanaICOAddr);

    //   const buyerICO = emanaICO.connect(signers.buyer1) as EmanaICO;
    //   await buyerICO.governanceTransfer();

    //   console.log({ buyerBalance: await emana.balanceOf(addr.buyer1) });
    // });
  });

  // describe('BUSD', async () => {});

  // describe('BUSD', async () => {});

  // it('purchase using busd below $10', async () => {
  //   const { emanaICO } = await loadFixture(fixture);
  //   const { buyer1 } = await getSigners();
  //   const addr = await getSignerAddresses();

  //   const amount = parseEther('5').toString();
  //   const newEmanaICO = emanaICO.connect(buyer1) as EmanaICO;

  //   const tx = newEmanaICO.purchaseUsingBusd(amount, '');

  //   expect(tx).to.be.revertedWith('MinimumPurchaseNotMet');
  // });
});
