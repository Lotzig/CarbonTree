const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("CarbB contract tests", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployCarbBFixture() {
    // Contracts are deployed using the first signer/account by default
    const [owner, customer1, customer2, customer3] = await ethers.getSigners();

    const CarbB = await ethers.getContractFactory("CarbB");
    const carbB = await CarbB.deploy(CarbB);

    return { carbB, owner, customer1, customer2, customer3 };
  }

  describe("Deployment", function () {
    it("Should deploy the contract", async function () {
      const { carbB, owner } = await loadFixture(deployCarbBFixture);

      expect(await carbB.owner()).to.equal(owner.address);
    });

    it("Should name the token correctly", async function () {
      const { carbB } = await loadFixture(deployCarbBFixture);
      const name = "CARBONTREE B";
      expect(await carbB.name()).to.equal(name);
    });

    it("Should set the token symbol correctly", async function () {
      const { carbB } = await loadFixture(deployCarbBFixture);
      const symbol = "CARB-B";
      expect(await carbB.symbol()).to.equal(symbol);
    });
  }); //describe("Deployment"

  describe("Admin features", function () {

    describe("Adding a token/tree", function () {

      it("Should revert if not owner", async function () {
      const { carbB, customer1 } = await loadFixture(deployCarbBFixture);

      await expect(carbB.connect(customer1).addTokenTree("species", 1, 1, "location", "locationOwnerName", "locationOwnerAddress")).to.be.revertedWithCustomError(carbB, "OwnableUnauthorizedAccount");
      });

      it("Should revert if passed species argument is empty", async function () {
        const { carbB } = await loadFixture(deployCarbBFixture);
        await expect(carbB.addTokenTree("", 1, 1, "location", "locationOwnerName", "locationOwnerAddress")).to.be.revertedWith("Species can not be empty");
      });

      it("Should revert if passed price argument is nul", async function () {
        const { carbB } = await loadFixture(deployCarbBFixture);
        await expect(carbB.addTokenTree("species", 0, 1, "location", "locationOwnerName", "locationOwnerAddress")).to.be.revertedWith("Price can not be nul");
      });

      it("Should revert if passed planting date argument is nul", async function () {
        const { carbB } = await loadFixture(deployCarbBFixture);
        await expect(carbB.addTokenTree("species", 1, 0, "location", "locationOwnerName", "locationOwnerAddress")).to.be.revertedWith("Planting date can not be nul");
      });
      
      it("Should revert if passed location argument is nul", async function () {
        const { carbB } = await loadFixture(deployCarbBFixture);
        await expect(carbB.addTokenTree("species", 1, 1, "", "locationOwnerName", "locationOwnerAddress")).to.be.revertedWith("Location can not be empty");
      });
      
      it("Should revert if passed location owner name argument is nul", async function () {
        const { carbB } = await loadFixture(deployCarbBFixture);
        await expect(carbB.addTokenTree("species", 1, 1, "location", "", "locationOwnerAddress")).to.be.revertedWith("Location owner name can not be empty");
      });

      it("Should revert if passed location owner address argument is nul", async function () {
        const { carbB } = await loadFixture(deployCarbBFixture);
        await expect(carbB.addTokenTree("species", 1, 1, "location", "locationOwnerName", "")).to.be.revertedWith("Location owner address can not be empty");
      });

      it("Should add an available token/tree", async function () {
        const { carbB } = await loadFixture(deployCarbBFixture);
        await carbB.addTokenTree("species", 1, 1, "location", "locationOwnerName", "locationOwnerAddress")
        const availableTokenTrees = await carbB.getAvailableTokenTrees(); 
        expect(availableTokenTrees.length).to.equal(2);
      });

      it("Should increment the available tokens/trees count", async function () {
        const { carbB } = await loadFixture(deployCarbBFixture);
        await carbB.addTokenTree("species", 1, 1, "location", "locationOwnerName", "locationOwnerAddress")
        const availableTokenTreeCount = await carbB.availableTokenTreeCount();
        expect(availableTokenTreeCount).to.equal(1);
      });

      it("Should emit AvailableTokenTreeAdded event", async function () {
        const { carbB, availableTokenTreeCount } = await loadFixture(deployCarbBFixture);
        await carbB.addTokenTree("species", 1, 1, "location", "locationOwnerName", "locationOwnerAddress")
        
        expect(await carbB.addTokenTree("species", 1, 1, "location", "locationOwnerName", "locationOwnerAddress")).to.emit(carbB, "AvailableTokenTreeAdded")
        .withArgs(availableTokenTreeCount, "species", 1, 1, "location", "locationOwnerName", "locationOwnerAddress");
      });
    }); //describe("Adding a token/tree

    describe("Removing a token/tree", function () {
    
      it("Should revert if not owner", async function () {
        const { carbB, customer1 } = await loadFixture(deployCarbBFixture);
        await expect(carbB.connect(customer1).removeAvailableTokenTreeAdmin(0)).to.be.revertedWithCustomError(carbB, "OwnableUnauthorizedAccount");
      });

      it("Should revert if passed token/tree key does not exists", async function () {
        const { carbB, customer1 } = await loadFixture(deployCarbBFixture);
        await expect(carbB.removeAvailableTokenTreeAdmin(0)).to.be.revertedWith("Token tree not found. Token tree Id 0 does not exists");
      });

      it("Should remove the token/tree from available tokens/trees array", async function () {
        const { carbB } = await loadFixture(deployCarbBFixture);
        await carbB.addTokenTree("species", 1, 1, "location", "locationOwnerName", "locationOwnerAddress")
        await carbB.removeAvailableTokenTreeAdmin(1);
        const availableTokenTrees = await carbB.getAvailableTokenTrees(); 
        expect(availableTokenTrees.length).to.equal(1);
      });

      it("Should decrement the available tokens/trees count", async function () {
        const { carbB } = await loadFixture(deployCarbBFixture);
        await carbB.addTokenTree("species", 1, 1, "location", "locationOwnerName", "locationOwnerAddress")
        await carbB.removeAvailableTokenTreeAdmin(1);
        const availableTokenTreeCount = await carbB.availableTokenTreeCount();
        expect(availableTokenTreeCount).to.equal(0);
      });

      it("Should emit AvailableTokenTreeRemovedByAdmin event", async function () {
        const { carbB, owner } = await loadFixture(deployCarbBFixture);
        await carbB.addTokenTree("species", 1, 1, "location", "locationOwnerName", "locationOwnerAddress")
        
        expect(await carbB.removeAvailableTokenTreeAdmin(1)).to.emit(carbB, "AvailableTokenTreeRemovedByAdmin")
        .withArgs(owner.address, 1);
      });

      it("Should emit AvailableTokenTreeRemoved event", async function () {
        const { carbB, owner } = await loadFixture(deployCarbBFixture);
        await carbB.addTokenTree("species", 1, 1, "location", "locationOwnerName", "locationOwnerAddress")
        
        expect(await carbB.removeAvailableTokenTreeAdmin(1)).to.emit(carbB, "AvailableTokenTreeRemoved")
        .withArgs(owner.address, 1);
      });
    }); //describe("Removing a token/tree"

    describe("Updating a token/tree", function () {

      it("Should revert if not owner", async function () {
      const { carbB, customer1 } = await loadFixture(deployCarbBFixture);

      await expect(carbB.connect(customer1).updateTokenTree(1, "species", 1, 1, "location", "locationOwnerName", "locationOwnerAddress")).to.be.revertedWithCustomError(carbB, "OwnableUnauthorizedAccount");
      });

      it("Should revert if token/tree to be updated does not exists", async function () {
        const { carbB } = await loadFixture(deployCarbBFixture);
        await expect(carbB.updateTokenTree(1, "species", 1, 1, "location", "locationOwnerName", "locationOwnerAddress")).to.be.revertedWith("Token tree not found. Token tree Id 1 does not exists");
      });

      it("Should revert if passed species argument is empty", async function () {
        const { carbB } = await loadFixture(deployCarbBFixture);
        await carbB.addTokenTree("species", 1, 1, "location", "locationOwnerName", "locationOwnerAddress");
        await expect(carbB.updateTokenTree(1, "", 1, 1, "location", "locationOwnerName", "locationOwnerAddress")).to.be.revertedWith("Species can not be empty");
      });

      it("Should revert if passed price argument is nul", async function () {
        const { carbB } = await loadFixture(deployCarbBFixture);
        await carbB.addTokenTree("species", 1, 1, "location", "locationOwnerName", "locationOwnerAddress");
        await expect(carbB.updateTokenTree(1, "species", 0, 1, "location", "locationOwnerName", "locationOwnerAddress")).to.be.revertedWith("Price can not be nul");
      });

      it("Should revert if passed planting date argument is nul", async function () {
        const { carbB } = await loadFixture(deployCarbBFixture);
        await carbB.addTokenTree("species", 1, 1, "location", "locationOwnerName", "locationOwnerAddress");
        await expect(carbB.updateTokenTree(1, "species", 1, 0, "location", "locationOwnerName", "locationOwnerAddress")).to.be.revertedWith("Planting date can not be nul");
      });
      
      it("Should revert if passed location argument is nul", async function () {
        const { carbB } = await loadFixture(deployCarbBFixture);
        await carbB.addTokenTree("species", 1, 1, "location", "locationOwnerName", "locationOwnerAddress");
        await expect(carbB.updateTokenTree(1, "species", 1, 1, "", "locationOwnerName", "locationOwnerAddress")).to.be.revertedWith("Location can not be empty");
      });
      
      it("Should revert if passed location owner name argument is nul", async function () {
        const { carbB } = await loadFixture(deployCarbBFixture);
        await carbB.addTokenTree("species", 1, 1, "location", "locationOwnerName", "locationOwnerAddress");
        await expect(carbB.updateTokenTree(1, "species", 1, 1, "location", "", "locationOwnerAddress")).to.be.revertedWith("Location owner name can not be empty");
      });

      it("Should revert if passed location owner address argument is nul", async function () {
        const { carbB } = await loadFixture(deployCarbBFixture);
        await carbB.addTokenTree("species", 1, 1, "location", "locationOwnerName", "locationOwnerAddress");
        await expect(carbB.updateTokenTree(1, "species", 1, 1, "location", "locationOwnerName", "")).to.be.revertedWith("Location owner address can not be empty");
      });

      it("Should update the token/tree", async function () {
        const { carbB } = await loadFixture(deployCarbBFixture);
        await carbB.addTokenTree("species", 1, 1, "location", "locationOwnerName", "locationOwnerAddress");
        await carbB.updateTokenTree(1, "new species", 1, 1, "location", "locationOwnerName", "locationOwnerAddress")
        const availableTokenTrees = await carbB.getAvailableTokenTrees();

        expect(availableTokenTrees[1].species).to.equal("new species");
      });

      it("Should emit AvailableTokenTreeUpdated event", async function () {
        const { carbB, availableTokenTreeCount } = await loadFixture(deployCarbBFixture);
        await carbB.addTokenTree("species", 1, 1, "location", "locationOwnerName", "locationOwnerAddress");
        await carbB.updateTokenTree(1, "new species", 1, 1, "location", "locationOwnerName", "locationOwnerAddress")
        
        expect(await carbB.updateTokenTree(1, "new species", 1, 1, "location", "locationOwnerName", "locationOwnerAddress")).to.emit(carbB, "AvailableTokenTreeUpdated")
        .withArgs(availableTokenTreeCount, "new species", 1, 1, "location", "locationOwnerName", "locationOwnerAddress");
      });

    }); //describe("Updating a token/tree"

  }); //describe("Admin features"
    
  /*
    it("Should receive and store the funds to carbB", async function () {
      const { carbB, lockedAmount } = await loadFixture(deployCarbBFixture);

      expect(await ethers.provider.getBalance(carbB.target)).to.equal(
        lockedAmount
      );
    });

    it("Should fail if the unlockTime is not in the future", async function () {
      // We don't use the fixture here because we want a different deployment
      const latestTime = await time.latest();
      const Lock = await ethers.getContractFactory("Lock");
      await expect(Lock.deploy(latestTime, { value: 1 })).to.be.revertedWith(
        "Unlock time should be in the future"
      );
    });
  });

  describe("Withdrawals", function () {
    describe("Validations", function () {
      it("Should revert with the right error if called too soon", async function () {
        const { carbB } = await loadFixture(deployCarbBFixture);

        await expect(carbB.withdraw()).to.be.revertedWith(
          "You can't withdraw yet"
        );
      });

      it("Should revert with the right error if called from another account", async function () {
        const { carbB, unlockTime, otherAccount } = await loadFixture(
          deployCarbBFixture
        );

        // We can increase the time in Hardhat Network
        await time.increaseTo(unlockTime);

        // We use carbB.connect() to send a transaction from another account
        await expect(carbB.connect(otherAccount).withdraw()).to.be.revertedWith(
          "You aren't the owner"
        );
      });

      it("Shouldn't fail if the unlockTime has arrived and the owner calls it", async function () {
        const { carbB, unlockTime } = await loadFixture(
          deployCarbBFixture
        );

        // Transactions are sent using the first signer by default
        await time.increaseTo(unlockTime);

        await expect(carbB.withdraw()).not.to.be.reverted;
      });
    });

    describe("Events", function () {
      it("Should emit an event on withdrawals", async function () {
        const { carbB, unlockTime, lockedAmount } = await loadFixture(
          deployCarbBFixture
        );

        await time.increaseTo(unlockTime);

        await expect(carbB.withdraw())
          .to.emit(carbB, "Withdrawal")
          .withArgs(lockedAmount, anyValue); // We accept any value as `when` arg
      });
    });

    describe("Transfers", function () {
      it("Should transfer the funds to the owner", async function () {
        const { carbB, unlockTime, lockedAmount, owner } = await loadFixture(
          deployCarbBFixture
        );

        await time.increaseTo(unlockTime);

        await expect(carbB.withdraw()).to.changeEtherBalances(
          [owner, carbB],
          [lockedAmount, -lockedAmount]
        );
      });
    });
  });
*/  
}); //describe("CarbB contract tests"
