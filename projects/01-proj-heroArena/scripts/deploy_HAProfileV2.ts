import { ethers, upgrades } from "hardhat";

async function main() {
    const HAProfileV2 = await ethers.getContractFactory("HAProfileV2");
    let haProfileV1 = '0x4a125c02303b5d35d89f61659519bd9326b8ce80';
    let haProfileV2 = (await upgrades.upgradeProxy(haProfileV1, HAProfileV2));
    console.log(haProfileV2.address);
}

main();
