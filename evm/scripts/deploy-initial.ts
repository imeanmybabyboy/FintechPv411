import { network } from "hardhat";

const { ethers, networkName } = await network.create();
console.log(`Start deploying in network ${networkName}`);

const initial = await ethers.deployContract("Initial");

console.log("Deployment started...");
await initial.waitForDeployment();
console.log("Deployment finished...");

const task = await initial.greet();
console.log(task);