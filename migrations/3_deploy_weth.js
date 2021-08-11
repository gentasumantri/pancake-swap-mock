// migrations/3_deploy_weth.js

require('dotenv').config();

const Weth = artifacts.require('WETH9');

module.exports = async function (deployer, network, accounts) {
  await deployer.deploy(Weth);
};
