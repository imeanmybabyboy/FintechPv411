import { useEffect, useState } from "react";
import CounterABI from "../../evm/artifacts/contracts/Counter.sol/Counter.json";
import GreeterABI from "../../evm/artifacts/contracts/Greeter.sol/Greeter.json";
import VoterABI from "../../evm/artifacts/contracts/Voter.sol/Voter.json";
import "./App.css";
import { ethers } from "ethers";

const RPC_URL = "http://127.0.0.1:8545/";
const counterAddress = "0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9";
const greeterAddress = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";
const voterAddress = "0x9A676e781A523b5d0C0e43731313A708CB607508";

// MetaMask надає бібліотеки, але вбудовує їх до BOM (window.)
// Typescript має стандартне означення BOM, тому необхідно розширити її інтерфейс
declare global {
    interface Window {
        ethereum: ethers.Eip1193Provider | undefined;
    }
}

function App() {
    // дані про авторизацію користувача (його обліковий запис)
    const [signer, setSigner] = useState<ethers.JsonRpcSigner | null>(null);

    // дані про мережу (криптомережу), з якою здійсннюється робота
    const [networkInfo, setNetworkInfo] = useState<ethers.Network | null>(null);

    // дані про контракт, з яким здійснюється робота
    const [contractData, setContractData] = useState("");
    const [getCntData, setGetCntData] = useState("");

    // дані форми для введенну інкременту
    const [inpInc, setInpInc] = useState<number>(2);

    const [greetingData, setGreetingData] = useState("");
    const [newGreeting, setNewGreeting] = useState<string>("");

    useEffect(() => {
        // підключення до налаштувань
        const jsonProvider: ethers.JsonRpcProvider = // Remote Procedure Call
            new ethers.JsonRpcProvider(RPC_URL); // створюємо провайдера за адресою

        // вилучаємо з провайдера деталі мережі
        jsonProvider.getNetwork().then(setNetworkInfo);
    }, []);

    const setGreeting = async () => {
        if (!signer) {
            alert("Спочатку необхідно підключитись до мережі");
            return;
        }
        if (newGreeting.trim().length == 0) {
            alert("Вітання не може бути порожнім");
            return;
        }
        try {
            const contract = new ethers.Contract(
                greeterAddress,
                GreeterABI.abi,
                signer,
            );
            const data = await contract.setGreeting(newGreeting);
            console.log(data);
            setGreetingData(data);
        } catch (err) {
            alert("Помилка виконання контракту: " + JSON.stringify(err));
        }
    };

    const getGreeting = async () => {
        if (!signer) {
            alert("Спочатку необхідно підключитись до мережі");
            return;
        }
        try {
            const contract = new ethers.Contract(
                greeterAddress,
                GreeterABI.abi,
                signer,
            );
            const data = await contract.greet();
            console.log(data);
            setGreetingData(data);
        } catch (err) {
            alert("Помилка виконання контракту: " + JSON.stringify(err));
        }
    };

    const connectWallet = async () => {
        // Перевіряємо чи встановлено MetaMask
        // це слідує з наявності у BOM відповідних даних
        if (!window.ethereum) {
            alert("Для роботи з мережею необхідно встановити MetaMask");
            return;
        }

        // запитуємо обліковий запис
        try {
            await window.ethereum.request({ method: "eth_requestAccounts" });
            // додаємо "обгортку для браузера"
            const browserProvider = new ethers.BrowserProvider(window.ethereum);
            // через неї вилучаємо обліковий запис користувача
            const sgnr = await browserProvider.getSigner();
            console.log(sgnr);
            setSigner(sgnr);
        } catch (err) {
            alert("У доступі відмовлено " + JSON.stringify(err));
        }
    };

    const activateCounter = async () => {
        if (!signer) {
            alert("Спочатку необхідно підключитись до мережі");
            return;
        }
        try {
            const contract = new ethers.Contract(
                counterAddress,
                CounterABI.abi,
                signer,
            );
            const data = await contract.inc();
            console.log(data);
            setContractData(data);
        } catch (err) {
            alert("Помилка виконання контракту: " + JSON.stringify(err));
        }
    };

    const getCounter = async () => {
        if (!signer) {
            alert("Спочатку необхідно підключитись до мережі");
            return;
        }
        try {
            const contract = new ethers.Contract(
                counterAddress,
                CounterABI.abi,
                signer,
            );
            const data = await contract.getCount();
            console.log(data);
            setGetCntData(data);
        } catch (err) {
            alert("Помилка виконання контракту: " + JSON.stringify(err));
        }
    };

    const incBy = async () => {
        if (!signer) {
            alert("Спочатку необхідно підключитись до мережі");
            return;
        }
        try {
            const contract = new ethers.Contract(
                counterAddress,
                CounterABI.abi,
                signer,
            );
            const data = await contract.incBy(2);
            console.log(data);
            setGetCntData(data);
        } catch (err) {
            alert("Помилка виконання контракту: " + JSON.stringify(err));
        }
    };

    const incCounter = async () => {
        if (!signer) {
            alert("Спочатку необхідно підключитись до мережі");
            return;
        }
        // if (inpInc <= 0) {
        //     alert("Значення має бути додатнім");
        //     return;
        // }
        try {
            const contract = new ethers.Contract(
                counterAddress,
                CounterABI.abi,
                signer,
            );
            const data = await contract.incBy(inpInc);
            console.log(data);
            setGetCntData(data);
        } catch (err) {
            alert("Помилка виконання контракту: " + JSON.stringify(err));
        }
    };

    const decCounter = async () => {
        if (!signer) {
            alert("Спочатку необхідно підключитись до мережі");
            return;
        }
        // if (inpInc <= 0) {
        //     alert("Значення має бути додатнім");
        //     return;
        // }
        try {
            const contract = new ethers.Contract(
                counterAddress,
                CounterABI.abi,
                signer,
            );
            const data = await contract.decBy(inpInc);
            console.log(data);
            setGetCntData(data);
        } catch (err: any) {
            alert(
                "Помилка виконання контракту: " +
                    (typeof err.reason === "undefined"
                        ? JSON.stringify(err)
                        : err.reason),
            );
        }
    };

    const [candidates, setCandidates] = useState([]);

    const getCandidates = async () => {
        if (!signer) {
            alert("Спочатку необхідно підключитись до мережі");
            return;
        }
        try {
            const contract = new ethers.Contract(
                voterAddress,
                VoterABI.abi,
                signer,
            );
            const data = await contract.getCandidates();
            console.log(data);
            setCandidates(data);
        } catch (err: any) {
            alert("Помилка виконання " + err.reason);
        }
    };

    const vote = async (i: number) => {
        if (!signer) {
            alert("Спочатку необхідно підключитись до мережі");
            return;
        }
        try {
            const contract = new ethers.Contract(
                voterAddress,
                VoterABI.abi,
                signer,
            );
            const data = await contract.vote(i);
            console.log(data);
            alert("Ok");
        } catch (err: any) {
            alert("Помилка виконання " + err.reason);
        }
    };

    const getVotes = async () => {
        if (!signer) {
            alert("Спочатку необхідно підключитись до мережі");
            return;
        }
        try {
            const contract = new ethers.Contract(
                voterAddress,
                VoterABI.abi,
                signer,
            );
            const data = await contract.getVotes();
            console.log(data);
        } catch (err: any) {
            alert("Помилка виконання " + err.reason);
        }
    };

    const allow = async () => {
        if (!signer) {
            alert("Спочатку необхідно підключитись до мережі");
            return;
        }
        try {
            const contract = new ethers.Contract(
                voterAddress,
                VoterABI.abi,
                signer,
            );
            const data = await contract.allow(newGreeting);
            console.log(data);
        } catch (err: any) {
            alert("Помилка виконання " + err.reason);
        }
    };

    return (
        <>
            <h1>Hardhat + React + Ethers</h1>

            <button onClick={connectWallet}>Connect wallet</button>
            {signer && <pre>{JSON.stringify(signer, null, 4)}</pre>}

            <button onClick={getCandidates}>Get candidates</button>
            {candidates.map((c, i) => (
                <p key={c}>
                    {c} <button onClick={() => vote(i)}>Vote</button>
                </p>
            ))}

            <button onClick={getVotes}>Get votes</button>
            <button onClick={allow}>Allow</button>

            <button onClick={getGreeting}>Greeting</button>
            <input
                value={newGreeting}
                onChange={(e) => setNewGreeting(e.target.value)}
            />
            <button onClick={setGreeting}>Change greeting</button>
            {greetingData && <pre>{JSON.stringify(greetingData, null, 4)}</pre>}

            <button onClick={activateCounter}>Counter</button>
            {contractData && <pre>{JSON.stringify(contractData, null, 4)}</pre>}

            {/* Solidity оперує з даними, типовим розміром 256 біт
                У JS це відповідає BigInt і вимагає коригування способу JSON серіалізації */}
            <button onClick={getCounter}>GET counter</button>
            {getCntData && (
                <pre>
                    {JSON.stringify(
                        getCntData,
                        (_, v) =>
                            typeof v === "bigint" ? `${v.toString()}n` : v,
                        4,
                    )}
                </pre>
            )}

            <button onClick={incBy}>Inc by 2</button>
            {contractData && <pre>{JSON.stringify(contractData, null, 4)}</pre>}

            <input
                type="number"
                value={inpInc}
                onChange={(e) => setInpInc(Number(e.target.value))}
            />

            <button onClick={incCounter}>INC counter</button>
            <button onClick={decCounter}>DEC counter</button>
        </>
    );
}

export default App;

/*
Взаємодія з криптомережами здійснюється через бібліотеки, що надає MetaMask. Протокол взаємодії - ABI (App Binary Interface)

Дані для протоколу генеруються при публікції смарт-контракту (npx hardhat compile) і знаходяться у evm/artifacts/contracts.../.../Counter.sol/Counter.json
Дані можна скопіювати або послатись за іменем файлу

Сам смарт-контракт розміщений у мережі і звернення до нього іде через адресу мережі та адресу контракта в неї
*/
