import { network } from "hardhat";

const { ethers, networkName } = await network.create();
console.log(`Start deploying in network ${networkName}`);

const voter = await ethers.deployContract("Voter", [
    ["Candidate 1", "Candidate 2", "Candidate 3"],
]);

console.log("Deployment started...");
await voter.waitForDeployment();
console.log("Deployment finished...");

console.log("Contract address: ", await voter.getAddress());

console.log(await voter.getCandidates());
console.log(await voter.getVotes());
console.log("owner:", await voter.owner());

console.log("Deployment finished");
