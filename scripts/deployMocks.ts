import { ethers } from 'hardhat';

export async function deployBUSDMock() {
  const busd = await ethers.deployContract('BUSDMock');
  await busd.waitForDeployment();
  console.log({ 'BUSD Mock': busd });

  return { busd, busdAddr: await busd.getAddress() };
}

export async function deployUSDTMock() {
  const usdt = await ethers.deployContract('USDTMock');
  await usdt.waitForDeployment();
  console.log({ 'USDT Mock': usdt });

  return { usdt, usdtAddr: await usdt.getAddress() };
}

export async function deployDAIMock() {
  const dai = await ethers.deployContract('DAIMock');
  await dai.waitForDeployment();
  console.log({ 'DAI Mock': dai });

  return { dai, daiAddr: await dai.getAddress() };
}

// export async function deployPancakeRouterMock() {
//   const pancakeRouter = await ethers.deployContract('PancakeRouterMock');
//   await pancakeRouter.waitForDeployment();

//   return {
//     pancakeRouter,
//     pancakeRouterAddr: await pancakeRouter.getAddress(),
//   };
// }
