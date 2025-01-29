// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

const PLATFORM_WALLET = "0xD8F340D533192888B306357C3eb3038F87bcbCD4";

module.exports = buildModule("AutoSendAssetsModule", (m) => {

  const autoSendAssets = m.contract("AutoSendAssets", [PLATFORM_WALLET]);

  return { autoSendAssets };
});
