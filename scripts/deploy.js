const { ethers, upgrades } = require("hardhat");

async function main() {
  const AutoSendAssets = await ethers.getContractFactory("AutoSendAssets");
  const autoSendAssets = await upgrades.deployProxy(AutoSendAssets, []);
  await autoSendAssets.waitForDeployment();
  console.log("AutoSendAssets deployed to:", await autoSendAssets.getAddress());
}

main();
