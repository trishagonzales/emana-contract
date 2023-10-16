import { ethers } from 'hardhat';

export async function getSigners() {
  const users =  await ethers.getSigners();
  const deployer =  users[0];
  const liquidity =  users[1];
  const project =  users[2];
  const operation1 =  users[3];
  const operation2 =  users[4];
  const buyer1 =  users[5];
  const buyer2 =  users[6];
  const buyer3 =  users[7];

  return {
    deployer,
    liquidity,
    project,
    operation1,
    operation2,
    buyer1,
    buyer2,
    buyer3,
  };
}

export async function getSignerAddresses() {
  const users = await ethers.getSigners();
  const deployer = await users[0].getAddress();
  const liquidity = await users[1].getAddress();
  const project = await users[2].getAddress();
  const operation1 = await users[3].getAddress();
  const operation2 = await users[4].getAddress();
  const buyer1 = await users[5].getAddress();
  const buyer2 = await users[6].getAddress();
  const buyer3 = await users[7].getAddress();

  return {
    deployer,
    liquidity,
    project,
    operation1,
    operation2,
    buyer1,
    buyer2,
    buyer3,
  };
}
