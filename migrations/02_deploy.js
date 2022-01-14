const MoonWalkers = artifacts.require('MoonWalkers');

const deploy = async (deployer, network, accounts) => {
  await deployer.deploy(MoonWalkers, 'Moon Walkers', 'MNWLKRS', "ipfs://QmQ4nSABsvZpBeXrvHDEjfkkWn3AbWnHZpxSpS9uVznYo1", "5", accounts[0]);
};

module.exports = deploy;
