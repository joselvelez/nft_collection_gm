import hre from "hardhat";
import { run, ethers } from "hardhat";

async function Main() {
    const contractFactory = await hre.ethers.getContractFactory('GoodMorning');
    const contract = await contractFactory.deploy();
    await contract.deployed();
    console.log("GM Contract deployed to ", contract.address);

    let txn;

    txn = await contract.mintGMKit();
    txn.wait();

    txn = await contract.mintGMKit();
    txn.wait();
}

async function runMain() {
    try {
        await Main();
        process.exit(0);
    } catch (e) {
        console.log("error", e);
        process.exit(1);
    }
}

runMain();