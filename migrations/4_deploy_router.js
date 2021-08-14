const Factory = artifacts.require('PancakeFactory');
const WBNB = artifacts.require('WBNBMock');
const Router = artifacts.require('PancakeRouter02');

module.exports = async function (deployer) {
  await deployer.deploy(Router, Factory.address, WBNB.address);
};
