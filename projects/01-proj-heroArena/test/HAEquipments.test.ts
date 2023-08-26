import { assert } from "chai";
import { constants, expectEvent, expectRevert } from "@openzeppelin/test-helpers";

import { artifacts, contract, ethers } from "hardhat";

const HAEquipments = artifacts.require("./HAEquipments.sol");

contract("HAEquipments", ([alice, bob, carol]) => {
    let haEquipments;
    let result;

    before(async () => {
        const _testBaseURI = "ipfs://ipfs/";
        haEquipments = await HAEquipments.new(_testBaseURI, { from: alice });
    });

    // Check ticker and symbols are correct
    describe("The NFT contract is properly deployed.", async () => {
        it("Symbol is correct", async () => {
            result = await haEquipments.symbol();
            assert.equal(result, "HAE");
        });
        it("Name is correct", async () => {
            result = await haEquipments.name();
            assert.equal(result, "HA Equipments");
        });
        it("Total supply is 0", async () => {
            result = await haEquipments.totalSupply();
            assert.equal(result, "0");
            result = await haEquipments.balanceOf(alice);
            assert.equal(result, "0");
        });
        it("Owner is Alice", async () => {
            result = await haEquipments.owner();
            assert.equal(result, alice);
        });
    });

    // Verify that ERC721 tokens can be minted, deposited and transferred
    describe("ERC721 are correctly minted, deposited, transferred", async () => {
        let testTokenURI = "testURI";
        let testId1 = "3";
        let testId2 = "1";

        it("NFT token is minted properly", async () => {
            result = await haEquipments.mint(alice, testTokenURI, testId1, {
                from: alice,
            });
            expectEvent(result, "Transfer", {
                from: constants.ZERO_ADDRESS,
                to: alice,
                tokenId: "0",
            });
            result = await haEquipments.totalSupply();
            assert.equal(result, "1");
            result = await haEquipments.tokenURI("0");
            assert.equal(result, "ipfs://ipfs/testURI");
            result = await haEquipments.balanceOf(alice);
            assert.equal(result, "1");
            result = await haEquipments.ownerOf("0");
            assert.equal(result, alice);
            result = await haEquipments.getEquipId("0");
            assert.equal(result, "3");
        });

        it("NFT token is transferred to Bob", async () => {
            result = await haEquipments.safeTransferFrom(alice, bob, "0", {
                from: alice,
            });
            expectEvent(result, "Transfer", {
                from: alice,
                to: bob,
                tokenId: "0",
            });
            result = await haEquipments.balanceOf(alice);
            assert.equal(result, "0");
            result = await haEquipments.balanceOf(bob);
            assert.equal(result, "1");
            result = await haEquipments.ownerOf("0");
            assert.equal(result, bob);
        });

        it("Second token is minted to Bob", async () => {
            result = await haEquipments.mint(bob, testTokenURI, testId2, {
                from: alice,
            });
            expectEvent(result, "Transfer", {
                from: constants.ZERO_ADDRESS,
                to: bob,
                tokenId: "1",
            });
            result = await haEquipments.totalSupply();
            assert.equal(result, "2");
            result = await haEquipments.balanceOf(bob);
            assert.equal(result, "2");
            result = await haEquipments.getEquipId("1");
            assert.equal(result, "1");
            await expectRevert(
                haEquipments.safeTransferFrom(alice, bob, "0", {
                    from: alice,
                }),
                "ERC721: transfer caller is not owner nor approved"
            );
        });

        it("Alice let Carol spend her NFT", async () => {
            await expectRevert(
                haEquipments.approve(carol, "1", { from: alice }),
                "ERC721: approve caller is not owner nor approved for all"
            );

            result = await haEquipments.approve(carol, "1", { from: bob });
            expectEvent(result, "Approval", {
                owner: bob,
                approved: carol,
                tokenId: "1",
            });
        });
    });
});