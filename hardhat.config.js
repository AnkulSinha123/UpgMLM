require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
require("@openzeppelin/hardhat-upgrades");

//const { API_KEY, BSC_TESTNET_PRIVATE_KEY } = process.env;
const API_KEY = "https://data-seed-prebsc-1-s1.bnbchain.org:8545"
const BSC_TESTNET_PRIVATE_KEY = "ce21113c6cf668d6ea9b84f03f06d6b3f473aabf537b1738f3ae7b234be2cf13"

module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    bsc: {
      url: API_KEY,
      accounts: [BSC_TESTNET_PRIVATE_KEY], // Use an array of private keys
    },
  },
};
