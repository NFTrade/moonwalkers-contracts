const MoonWalkers = artifacts.require('MoonWalkers');

const deploy = async (deployer, network, accounts) => {
  await deployer.deploy(MoonWalkers, 'Moon Walkers', 'MNWLKRS', "https://ipfs.io/ipfs/example");
};

module.exports = deploy;
