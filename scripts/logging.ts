import { ethers } from 'hardhat';
import { getSignerAddresses, getSigners } from '../utils/signers';
import { parseEther } from 'ethers';
import { deployments } from '../utils/deployments';

async function logging() {
  const signers = await getSigners();
  const addr = await getSignerAddresses();
}

logging().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
