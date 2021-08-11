// migrations/4_deploy_router.js

require('dotenv').config();

const Router = artifacts.require('PancakeRouter02');
const Weth = artifacts.require('WETH9');

const FactoryAddress = process.env.FACTORY_ADDRESS;

module.exports = async function (deployer) {
  await deployer.deploy(Router, FactoryAddress, Weth.address, { gas: 6721975 });
};
