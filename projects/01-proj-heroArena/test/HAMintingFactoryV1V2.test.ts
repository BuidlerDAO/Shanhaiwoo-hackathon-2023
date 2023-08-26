import { assert } from "chai";
import { expectEvent, expectRevert, time } from "@openzeppelin/test-helpers";
import { artifacts, contract, ethers } from "hardhat";

const MockERC20 = artifacts.require("./utils/MockERC20.sol");
const HAMintingFarm = artifacts.require("./HAMintingFarm.sol");
const HAMintingFactoryV2 = artifacts.require("./HAMintingFactoryV2.sol");
const HAEquipments = artifacts.require("./HAEquipments.sol");

contract("HAMintingFarm", ([alice, bob, carol, david, erin, frank, minterTester]) => {
    let mockArn,
        haEquipments,
        haEquipmentsAddress,
        haMintingFarm,
        haMintingFactoryV2,
        haMintingFarmAddress,
        result,
        result2;

    before(async () => {
        let _totalSupplyDistributed = 5;
        let _arnPerBurn = 20;
        let _testBaseURI = "ipfs://ipfs/";
        let _ipfsHash = "IPFSHASH/";
        let _endBlockTime = 150;

        mockArn = await MockERC20.new("HA Mock Token", "ARN", 10000, {
            from: minterTester,
        });

        haMintingFarm = await HAMintingFarm.new(
            mockArn.address,
            _totalSupplyDistributed,
            _arnPerBurn,
            _testBaseURI,
            _ipfsHash,
            _endBlockTime,
            { from: alice }
        );

        haMintingFarmAddress = haMintingFarm.address;
        haEquipmentsAddress = await haMintingFarm.haEquipments();
        haEquipments = await HAEquipments.at(haEquipmentsAddress);
    });

    // Check ticker, symbols, supply, and owner are correct
    describe("All contracts are deployed correctly", async () => {
        it("Symbol is correct", async () => {
            result = await haEquipments.symbol();
            assert.equal(result, "HAE");
        });
        it("Name is correct", async () => {
            result = await haEquipments.name();
            assert.equal(result, "HA Equipments");
        });
        it("Total supply + number of NFT distributed is 0", async () => {
            result = await haEquipments.totalSupply();
            assert.equal(result, 0);
            result = await haMintingFarm.totalSupplyDistributed();
            assert.equal(result, 5);
            result = await haMintingFarm.currentDistributedSupply();
            assert.equal(result, 0);
        });

    });
});