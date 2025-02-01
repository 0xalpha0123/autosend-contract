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
  async function deployAssetsFixture() {
    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const AutoSendAssets = await ethers.getContractFactory("AutoSendAssets");
    const autoSendAssets = await AutoSendAssets.deploy(owner);

    const MockERC20 = await ethers.getContractFactory("MockERC20");
    const mockERC20 = await MockERC20.deploy(owner);

    return { autoSendAssets, mockERC20, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("Should set the right unlockTime", async function () {
      const { autoSendAssets, mockERC20, owner } = await loadFixture(
        deployAssetsFixture
      );

      expect(await autoSendAssets.owner()).to.equal(owner);

      await mockERC20
        .connect(owner)
        .approve(autoSendAssets.getAddress(), "1000000000000000000000");

      await autoSendAssets
        .connect(owner)
        .createSchedule(
          "test",
          mockERC20.getAddress(),
          owner.address,
          "1000000000000000000",
          0,
          1738442027
        );

      console.log("hhhhhhh");

      await autoSendAssets.connect(owner).checkUpkeep("0x");

      console.log("hhhhhhh");
      console.log(await autoSendAssets.getTempUsers());

      console.log("hhhhhhh");

      console.log(await autoSendAssets.getTempIndexes());

      console.log("hhhhhhh");

      await autoSendAssets.connect(owner).performUpkeep("0x");
    });
  });
});
