require("@nomicfoundation/hardhat-toolbox");
require('@nomiclabs/hardhat-ethers'); // For ethers.js integration
require('@nomiclabs/hardhat-waffle'); // For Waffle testing framework
require('hardhat-deploy'); // For deployment automation
require('@nomiclabs/hardhat-etherscan'); // For Etherscan verification
require('dotenv').config(); // To manage environment variables

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.0", // Solidity compiler version
    settings: {
      optimizer: {
        enabled: true, // Enable optimization for gas usage
        runs: 200 // Optimizations run
      }
    }
  },
  defaultNetwork: "localhost",
  networks: {
    hardhat: {
      // Hardhat network settings (default for local testing)
      chainId: 31337, // Chain ID for the Hardhat network
    },
    localhost: {
      url: process.env.LOCALHOST_URL, // Localhost URL
      accounts: [process.env.PRIVATE_KEY], // Local deployer's private key
    },
    mainnet: {
      url: process.env.MAINNET_URL, // Mainnet URL
      accounts: [process.env.PRIVATE_KEY], // Mainnet deployer's private key
    },
    ropsten: {
      url: process.env.ROPSTEN_URL, // Ropsten network URL
      accounts: [process.env.PRIVATE_KEY], // Deployer's private key for Ropsten
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY, // API key for contract verification on Etherscan
  },
  namedAccounts: {
    deployer: {
      default: 0, // The default deployer account is the first account in the wallet
    },
  },
  paths: {
    artifacts: './artifacts', // Folder where compiled contract artifacts are stored
    sources: './contracts', // Folder containing Solidity contracts
    tests: './test', // Folder where test files are located
    cache: './cache', // Cache folder
  },
  mocha: {
    timeout: 20000, // Timeout for tests (in milliseconds)
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS ? true : false, // Enables gas reporting for test runs
    currency: 'USD', // Reporting gas costs in USD
    gasPrice: 20, // Default gas price to be used
    outputFile: 'gas-report.txt', // Output file for gas report
  },
};
