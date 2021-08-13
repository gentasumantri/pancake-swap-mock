const Factory = artifacts.require('PancakeFactory');

module.exports = async function (deployer, network, accounts) {
  const feeToSetter = accounts[1];

  await deployer.deploy(Factory, feeToSetter);
};
