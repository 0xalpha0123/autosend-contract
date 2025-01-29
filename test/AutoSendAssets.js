const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("AutoSendAssets", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployAutoSendAssetsFixture() {
    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const AutoSendAssets = await ethers.getContractFactory("AutoSendAssets");
    const autoSendAssets = await AutoSendAssets.deploy(owner);

    return { autoSendAssets, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("Should set the right unlockTime", async function () {
      const { autoSendAssets, owner } = await loadFixture(deployAutoSendAssetsFixture);

      expect(await autoSendAssets.owner()).to.equal(owner);
    });
  });
});
