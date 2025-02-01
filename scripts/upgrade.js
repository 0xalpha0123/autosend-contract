// scripts/upgrade-box.js
const { ethers, upgrades } = require("hardhat");

const AUTOSEND_ADDRESS = "0xe59c16ca3d361947f39b4417cec08d5084589aff";

async function main() {
  const AutoSendAssetsV2 = await ethers.getContractFactory("AutoSendAssets");
  const autoSendAssets = await upgrades.upgradeProxy(
    AUTOSEND_ADDRESS,
    AutoSendAssetsV2
  );
  console.log("AutoSend upgraded");
}

main();
