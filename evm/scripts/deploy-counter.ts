import { network } from "hardhat";

// смарт-контракти публікуються у певній мережі
// початкова дія - підключення до мережі
const { ethers, networkName } = await network.create();
console.log(`Start deploying in network ${networkName}`);

// знаходимо посилання на контракт
// (у стандартній директорії /contracts)
const counter = await ethers.deployContract("Counter");

// запускаємо публікацію
console.log("Deployment started...");
await counter.waitForDeployment();
console.log("Deployment finished...");

// одержуємо адресу опублікованого контракту
console.log("Contract address:", await counter.getAddress());

// виконуємо пробне звернення до методу .inc() (див. Counter.sol)
console.log("Calling .inc() method...");
const task = await counter.inc();

const initialGreet = await counter.initial();

// метод запускає подію, результат якої також слід чекати
console.log("Waiting for an event result...", task);
await task.wait();

const cnt = await counter.getCount();
console.log("GetCount -> ", cnt);

console.log("Deployment finished");
