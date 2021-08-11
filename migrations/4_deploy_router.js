// migrations/4_deploy_router.js

require('dotenv').config();

const Router = artifacts.require('PancakeRouter02');
const Factory = artifacts.require('PancakeFactory');
const Wbnb = artifacts.require('Wbnb');

module.exports = async function (deployer) {
  await deployer.deploy(Router, Factory.address, Wbnb.address, { gas: 6721975 });
};
