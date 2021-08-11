module.exports = {
  skipFiles: ['mocks', 'Migrations.sol'],
  providerOptions: {
    default_balance_ether: '10000000000000000000000000',
  },
  istanbulReporter: ['html'],
  mocha: {
    fgrep: '[skip-on-coverage]',
    invert: true,
  },
};
