import { ethers, upgrades } from 'hardhat';
import { Emana } from '../typechain-types';
import { getSignerAddresses } from '../utils/signers';

export async function deployEmana() {
  const addr = await getSignerAddresses();

  const Emana = await ethers.getContractFactory('Emana');
  const emana = (await upgrades.deployProxy(Emana, {
    initializer: 'initialize',
    kind: 'transparent',
  })) as unknown as Emana;
  await emana.waitForDeployment();
  console.log({
    'Emana Token': emana,
    owner: await emana.getOwner(),
    balance: await emana.balanceOf(addr.deployer),
  });

  return { emana, emanaAddr: await emana.getAddress() };
}
