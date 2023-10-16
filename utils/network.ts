import { network } from 'hardhat';

export type ChainIDType = 31337 | 97;

export const currentChainId = (network.config.chainId as ChainIDType) ?? 31337;
