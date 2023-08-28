import { ethers, upgrades } from "hardhat";

async function main() {
    const HAProfileV1 = await ethers.getContractFactory("HAProfileV1")   ;
    let haProfileV1 = (await upgrades.deployProxy(HAProfileV1, {
        kind: "uups"
    }));
    console.log(haProfileV1.address);
}

main();
