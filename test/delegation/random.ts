import * as chai from "chai";
import * as chaiAsPromised from "chai-as-promised";
import { Account } from "web3/eth/accounts";
import Contract from "web3/eth/contract";
import { ContractManagerInstance,
         DelegationControllerContract,
         DelegationServiceContract,
         DelegationServiceInstance,
         SkaleManagerMockContract,
         SkaleManagerMockInstance,
         SkaleTokenInstance,
         ValidatorServiceInstance} from "../../types/truffle-contracts";
import { deployContractManager } from "../utils/deploy/contractManager";
import { deployDelegationService } from "../utils/deploy/delegation/delegationService";
import { deployValidatorService } from "../utils/deploy/delegation/validatorService";
import { deploySkaleToken } from "../utils/deploy/skaleToken";
import { currentTime, skipTime } from "../utils/time";

chai.should();
chai.use(chaiAsPromised);

const SkaleManagerMock: SkaleManagerMockContract = artifacts.require("./SkaleManagerMock");
const DelegationService: any = artifacts.require("./DelegationService");

contract("Random tests", ([owner]) => {
    let contractManager: ContractManagerInstance;
    let skaleManagerMock: SkaleManagerMockInstance;
    let skaleToken: SkaleTokenInstance;
    let delegationService: DelegationServiceInstance;
    let validatorService: ValidatorServiceInstance;

    let web3DelegationService: Contract;

    beforeEach(async () => {
        contractManager = await deployContractManager();

        skaleManagerMock = await SkaleManagerMock.new(contractManager.address);
        await contractManager.setContractsAddress("SkaleManager", skaleManagerMock.address);

        skaleToken = await deploySkaleToken(contractManager);
        delegationService = await deployDelegationService(contractManager);
        validatorService = await deployValidatorService(contractManager);

        web3DelegationService = new web3.eth.Contract(DelegationService.abi, delegationService.address);
    });

    class Random {
        private static bigPrime = 2147483647;
        private seed: number;

        constructor(seed: number = Math.floor(Math.random() * Random.bigPrime)) {
            this.seed = seed % Random.bigPrime;
            if (this.seed <= 0) {
                this.seed += Random.bigPrime - 1;
            }
        }

        public next() {
            this.seed = this.seed * 16807 % Random.bigPrime;
            assert(this.seed > 0);
            return this.seed - 1;
        }

        public nextFloat() {
            return this.next() / (Random.bigPrime - 1);
        }
    }

    async function sendTransaction(account: Account, to: string, data: string) {
        const tx = {
            data,
            from: account.address,
            gas: 1e6,
            to,
        };

        const signedTx = await account.signTransaction(tx);
        return await web3.eth.sendSignedTransaction(signedTx.rawTransaction);
    }

    async function returnMoney(account: Account, address: string) {
        const balance = Number.parseInt(await web3.eth.getBalance(account.address), 10);
        const gas = 21 * 1e3;
        const gasPrice = 20 * 1e9;
        const sendTx = {
            from: account.address,
            gas,
            gasPrice,
            to: address,
            value: balance - gas * gasPrice,
        };
        const signedSendTx = await account.signTransaction(sendTx);
        await web3.eth.sendSignedTransaction(signedSendTx.rawTransaction);
        await web3.eth.getBalance(account.address).should.be.eventually.equal("0");
    }

    async function registerValidator(validator: Account, name: string, feeRate: number) {
        const data = web3DelegationService.methods.registerValidator(
            name, name, feeRate, 0).encodeABI();
        await sendTransaction(validator, delegationService.address, data);
        return await validatorService.numberOfValidators();
    }

    // operations:

    // Holder:
    // - delegate
    // - cancel
    // - undelegate
    // - withdraw bounty

    // validator:
    // - accept
    // - withdraw fee

    // skaleManager:
    // - payBounth
    // - slash

    async function test(duration: number,
                        timeDelta: number,
                        validatorsAmount: number) {
        const timeStart = await currentTime(web3);
        const etherAmount = 5 * 1e18;

        const random = new Random(13);

        const validators = [];
        for (let i = 0; i < validatorsAmount; ++i) {
            const validator = web3.eth.accounts.create();
            validators.push(validator);
            await web3.eth.sendTransaction({from: owner, to: validator.address, value: etherAmount});
            await registerValidator(validator, "Validator #" + (i + 1), random.next() % 1001);
        }

        for (let currentTimestamp = timeStart;
            currentTimestamp < timeStart + duration;
            skipTime(web3, timeDelta), currentTimestamp = await currentTime(web3)) {
                console.log("Click");
                console.log(random.next() % 100);
        }

        for (const validator of validators) {
            await returnMoney(validator, owner);
        }

        console.log(await validatorService.numberOfValidators());
    }

    it("test", async () => {
        await test(5 * 60, 60, 1);
    });
});
