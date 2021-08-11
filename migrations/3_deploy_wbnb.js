// migrations/3_deploy_wbnb.js

require('dotenv').config();

const Wbnb = artifacts.require('WBNB');

module.exports = async function (deployer) {
  await deployer.deploy(Wbnb);
};
