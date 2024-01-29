const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Ether MLM Contract", function () {
  let EtherMLMContract;
  let etherMLM;
  let owner;
  let user1;
  let user2;

  beforeEach(async function () {
    EtherMLMContract = await ethers.getContractFactory("Ether_MLMContract");
    [owner, user1, user2] = await ethers.getSigners();

    etherMLM = await upgrades.deployProxy(EtherMLMContract, [owner.address, owner.address]);
    await etherMLM.waitForDeployment();
  });

  it("should deploy the contract and initialize values", async function () {
    const packagePrices = await etherMLM.packagePrices();
    expect(packagePrices.length).to.equal(12);

    const upline1 = await etherMLM.upline1();
    const upline2 = await etherMLM.upline2();
    const upline3 = await etherMLM.upline3();
    const upline4 = await etherMLM.upline4();
    const upline5 = await etherMLM.upline5();

    expect(upline1).to.equal(owner.address);
    expect(upline2).to.equal(owner.address);
    expect(upline3).to.equal(owner.address);
    expect(upline4).to.equal(owner.address);
    expect(upline5).to.equal(owner.address);

    const royaltyContract = await etherMLM.RoyaltyContract();
    expect(royaltyContract).to.equal(owner.address);
  });

  it("should allow users to purchase packages", async function () {
    // User1 purchases the first package
    await etherMLM.connect(user1).purchasePackage(0, owner.address);

    // Check user's package and upline
    const user1Package = await etherMLM.getUserPackage(user1.address);
    expect(user1Package).to.equal(0);

    const user1Upline = await etherMLM.upline(user1.address);
    expect(user1Upline).to.equal(owner.address);

    // User2 purchases the second package
    await etherMLM.connect(user2).purchasePackage(1, user1.address);

    // Check user's package and upline
    const user2Package = await etherMLM.getUserPackage(user2.address);
    expect(user2Package).to.equal(1);

    const user2Upline = await etherMLM.upline(user2.address);
    expect(user2Upline).to.equal(user1.address);
  });

  it("should distribute Ether correctly", async function () {
    // User1 purchases the first package
    await etherMLM.connect(user1).purchasePackage(0, owner.address);

    // Check Ether distribution
    const user1BalanceBefore = await ethers.provider.getBalance(user1.address);

    // Trigger distribution
    await etherMLM.connect(user2).purchasePackage(1, user1.address);

    const user1BalanceAfter = await ethers.provider.getBalance(user1.address);

    // Check if Ether is distributed correctly
    expect(user1BalanceAfter.sub(user1BalanceBefore)).to.equal(ethers.utils.parseEther("2"));

    // Check Ether balances of uplines
    const ownerBalance = await ethers.provider.getBalance(owner.address);
    const user1Balance = await ethers.provider.getBalance(user1.address);
    const user2Balance = await ethers.provider.getBalance(user2.address);

    // Modify these values according to your distribution logic
    const expectedOwnerBalance = ownerBalance.add(ethers.utils.parseEther("0.8"));
    const expectedUser1Balance = user1Balance.add(ethers.utils.parseEther("0.5"));
    const expectedUser2Balance = user2Balance.add(ethers.utils.parseEther("0.2"));

    expect(ownerBalance).to.equal(expectedOwnerBalance);
    expect(user1Balance).to.equal(expectedUser1Balance);
    expect(user2Balance).to.equal(expectedUser2Balance);
  });
});
