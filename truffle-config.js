// truffle-config.js

require('dotenv').config();

const HDWalletProvider = require('@truffle/hdwallet-provider');

module.exports = {
  networks: {
    development: {
      host: '127.0.0.1',
      port: 8545,
      network_id: '*', // eslint-disable-line camelcase
    },
    testnet: {
      provider: () => new HDWalletProvider(process.env.MNEMONIC, 'https://data-seed-prebsc-1-s1.binance.org:8545'),
      network_id: 97, // eslint-disable-line camelcase
      confirmations: 10,
      timeoutBlocks: 200,
      skipDryRun: true,
    },
    live: {
      provider: () => new HDWalletProvider(process.env.MNEMONIC, 'https://bsc-dataseed1.defibit.io/'),
      network_id: 56, // eslint-disable-line camelcase
      confirmations: 10,
      timeoutBlocks: 200,
      skipDryRun: true,
    },
  },
  compilers: {
    solc: {
      version: '0.6.12',
      settings: {
        optimizer: {
          enabled: false,
          runs: 200,
        },
      },
    },
  },
  db: {
    enabled: false,
  },
  plugins: ['truffle-plugin-verify'],
  // eslint-disable-next-line camelcase
  api_keys: {
    etherscan: process.env.API_KEY_ETHERSCAN,
    bscscan: process.env.API_KEY_BSCSCAN,
  },
};
