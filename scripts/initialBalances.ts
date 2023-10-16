import { ethers } from 'hardhat';
import { deployments } from '../utils/deployments';
import { getSignerAddresses, getSigners } from '../utils/signers';
import { parseEther } from 'ethers';
import { contractAt } from '../utils/lib';

async function initialBalances() {
  const signers = await getSigners();
  const addr = await getSignerAddresses();

  const busd = (
    await contractAt('BUSDMock', deployments.local.busdMock)
  ).connect(signers.deployer);

  await busd.transfer(addr.buyer1, parseEther('100'));
  await busd.transfer(addr.buyer2, parseEther('100'));
  await busd.transfer(addr.buyer3, parseEther('100'));

  const usdt = (
    await contractAt('BUSDMock', deployments.local.usdtMock)
  ).connect(signers.deployer);

  await usdt.transfer(addr.buyer1, parseEther('100'));
  await usdt.transfer(addr.buyer2, parseEther('100'));
  await usdt.transfer(addr.buyer3, parseEther('100'));

  const dai = (await contractAt('BUSDMock', deployments.local.daiMock)).connect(
    signers.deployer
  );

  await dai.transfer(addr.buyer1, parseEther('100'));
  await dai.transfer(addr.buyer2, parseEther('100'));
  await dai.transfer(addr.buyer3, parseEther('100'));
}

initialBalances().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
