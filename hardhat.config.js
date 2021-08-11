// hardhat.config.js

require('dotenv').config();
require('@nomiclabs/hardhat-waffle');
require('@nomiclabs/hardhat-truffle5');
require('solidity-coverage');
require('hardhat-gas-reporter');

const mochaOptions = require('./.mocharc.js');

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    version: '0.6.12',
    settings: {
      optimizer: {
        enabled: false,
        runs: 200,
      },
    },
  },
  mocha: mochaOptions,
  gasReporter: {
    enabled: process.env.ENABLE_GAS_REPORT,
    currency: 'IDR',
    coinmarketcap: process.env.API_KEY_CMC,
  },
};
