const WBNB = artifacts.require('WBNBMock');

module.exports = async function (deployer) {
  await deployer.deploy(WBNB);
};
