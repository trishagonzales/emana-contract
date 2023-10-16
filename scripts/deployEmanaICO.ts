import { parseEther } from 'ethers';
import { ethers, upgrades } from 'hardhat';

export interface IcoConfig extends IcoSettings {
  emanaAddr: string;
  busdAddr: string;
  usdtAddr: string;
  daiAddr: string;
  // pancakeRouterAddr: string;
  liquidityAddr: string;
  projectAddr: string;
  operation1Addr: string;
  operation2Addr: string;
  minPurchaseInUsd: string;
  emanaPerUsd: string;
}

export interface IcoSettings {
  minPurchaseInUsd: string;
  emanaPerUsd: string;
}

export const defaultICOSettings: IcoSettings = {
  minPurchaseInUsd: '10',
  emanaPerUsd: parseEther('20000').toString(),
};

export async function deployEmanaICO(config: IcoConfig) {
  const EmanaICO = await ethers.getContractFactory('EmanaICO');
  const emanaICO = await upgrades.deployProxy(EmanaICO, Object.values(config), {
    initializer: 'initialize',
    kind: 'transparent',
  });
  await emanaICO.waitForDeployment();
  console.log({ 'Emana ICO': emanaICO });

  return { emanaICO, emanaICOAddr: await emanaICO.getAddress() };
}
