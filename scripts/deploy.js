const { ethers } = require("hardhat");

async function main() {
  // Get the signer
  const [deployer] = await ethers.getSigners();

  // Deploy AddressStorage contract
  const AddressStorage = await ethers.getContractFactory("AddressStorage");
  const addressStorage = await AddressStorage.deploy();

  // Wait for the contract to be mined
  await addressStorage.deployed();

  console.log("AddressStorage deployed to:", addressStorage.address);
}

// Execute the deployment script
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
