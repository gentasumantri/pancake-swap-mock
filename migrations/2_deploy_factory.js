// migrations/2_deploy_factory.js

require('dotenv').config();

const Factory = artifacts.require('PancakeFactory');

module.exports = async function (deployer, network, accounts) {
  const feeToSetter = accounts[1];

  await deployer.deploy(Factory, feeToSetter);
};
