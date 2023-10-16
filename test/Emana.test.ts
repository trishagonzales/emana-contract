import { HardhatEthersSigner } from '@nomicfoundation/hardhat-ethers/signers';
import { expect } from 'chai';
import { Contract, formatEther, parseEther } from 'ethers';
import { ethers, upgrades } from 'hardhat';

describe('Emana', async () => {
  let emana: Contract,
    deployer: HardhatEthersSigner,
    buyer1: HardhatEthersSigner,
    buyer2: HardhatEthersSigner,
    users: HardhatEthersSigner[];
  let deployerAddr: string, buyer1Addr: string, buyer2Addr: string;

  beforeEach(async () => {
    const EmanaFactory = await ethers.getContractFactory('Emana');
    emana = await upgrades.deployProxy(EmanaFactory, {
      initializer: 'initialize',
      kind: 'transparent',
    });

    await emana.waitForDeployment();
    users = await ethers.getSigners();

    deployer = users[0];
    buyer1 = users[1];
    buyer2 = users[2];
    deployerAddr = await users[0].getAddress();
    buyer1Addr = await users[1].getAddress();
    buyer2Addr = await users[2].getAddress();
  });

  it('totalSupply', async () => {
    const totalSupply = (await emana.totalSupply()).toString();
    expect(totalSupply).to.equal(parseEther('10000000000').toString());
  });

  it('name', async () => {
    const name = await emana.name();
    expect(name).to.equal('Emana');
  });

  it('symbol', async () => {
    const symbol = await emana.symbol();
    expect(symbol).to.equal('EMN');
  });

  it('decimals', async () => {
    const decimals = await emana.decimals();
    expect(decimals).to.equal('18');
  });

  it('owner', async () => {
    const owner = await emana.owner();
    expect(owner).to.equal(deployerAddr);
  });

  it('balanceOf', async () => {
    const balance = formatEther(await emana.balanceOf(deployerAddr));
    const totalSupply = formatEther(await emana.totalSupply());
    expect(balance).to.equal(totalSupply);
  });

  describe('Buying Tokens', async () => {
    let amount: bigint;
    let initFundsTx: ReturnType<typeof emana.transfer>;

    beforeEach(async () => {
      amount = parseEther('5');
      initFundsTx = emana.transfer(buyer1Addr, amount);
      await initFundsTx;
    });

    it('transfer', async () => {
      await expect(initFundsTx)
        .to.emit(emana, 'Transfer')
        .withArgs(deployerAddr, buyer1Addr, amount);
      await expect(initFundsTx).to.changeTokenBalances(
        emana,
        [deployerAddr, buyer1Addr],
        [-amount, amount]
      );
    });

    it('revert transferFrom if insufficient allowance', async () => {
      const tx = emana.transferFrom(buyer1Addr, buyer2Addr, amount);

      await expect(tx).to.be.revertedWithCustomError(
        emana,
        'ERC20InsufficientAllowance'
      );
    });
  });
});
