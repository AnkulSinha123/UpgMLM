const { ethers } = require('ethers');
const fs = require('fs');

const privateKey = '9d431845eba193edaa3631fc5c864d3687fa39729ca71f7fd26311950c7924f0'; // Replace with your own private key
const rpcUrl = 'https://data-seed-prebsc-1-s1.binance.org:8545'; // BSC Testnet RPC URL

const provider = new ethers.providers.JsonRpcProvider(rpcUrl);
const wallet = new ethers.Wallet(privateKey, provider);

async function deployContract() {
  // Load your contract's bytecode and ABI
  const bytecode = fs.readFileSync('path/to/Registration.sol', 'utf-8'); // Replace with your contract's path
  const abi = JSON.parse(fs.readFileSync('path/to/Registration.json', 'utf-8')); // Replace with your contract's ABI path

  // Create a factory for your contract
  const factory = new ethers.ContractFactory(abi, bytecode, wallet);

  // Deploy the contract
  const contract = await factory.deploy(/* constructor arguments if any */);
  await contract.deployed();

  console.log('Contract deployed to address:', contract.address);
}

deployContract();
