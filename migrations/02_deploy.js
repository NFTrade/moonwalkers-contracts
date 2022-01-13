const MoonWalkers = artifacts.require('MoonWalkers');

const deploy = async (deployer, network, accounts) => {
  await deployer.deploy(MoonWalkers, 'Moon Walkers', 'MNWLKRS', "https://ipfs.nftrade.com/ipfs/QmX9Uyub6tJriV6MK24A3brkJVchxXqHBWBBXpm86s4AQK/1073.json");
};

module.exports = deploy;
