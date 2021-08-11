// migrations/2_deploy_factory.js

require('dotenv').config();

const Weth = artifacts.require('WETH9');

module.exports = async function (deployer, network, accounts) {
  await deployer.deploy(Weth);
};
