import { deployments } from '../utils/deployments';
import { contractAt } from '../utils/lib';
import { getSignerAddresses, getSigners } from '../utils/signers';

async function setGovernance() {
  const signers = await getSigners();

  const emana = (await contractAt('Emana', deployments.local.emana)).connect(
    signers.deployer
  );

  await emana.grantGovernance(deployments.local.emanaICO);
}

setGovernance().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
