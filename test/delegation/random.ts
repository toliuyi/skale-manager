import BigNumber from "bignumber.js";
import * as chai from "chai";
import * as chaiAsPromised from "chai-as-promised";
import { Account } from "web3/eth/accounts";
import Contract from "web3/eth/contract";
import { ContractManagerInstance,
         DelegationControllerInstance,
         DelegationServiceInstance,
         SkaleManagerMockContract,
         SkaleManagerMockInstance,
         SkaleTokenInstance,
         ValidatorServiceInstance} from "../../types/truffle-contracts";
import { deployContractManager } from "../utils/deploy/contractManager";
import { deployDelegationController } from "../utils/deploy/delegation/delegationController";
import { deployDelegationService } from "../utils/deploy/delegation/delegationService";
import { deployValidatorService } from "../utils/deploy/delegation/validatorService";
import { deploySkaleToken } from "../utils/deploy/skaleToken";
import { currentTime, skipTime } from "../utils/time";

chai.should();
chai.use(chaiAsPromised);

const SkaleManagerMock: SkaleManagerMockContract = artifacts.require("./SkaleManagerMock");

contract("Random tests", ([owner]) => {
    let contractManager: ContractManagerInstance;
    let skaleManagerMock: SkaleManagerMockInstance;
    let skaleToken: SkaleTokenInstance;
    let delegationService: DelegationServiceInstance;
    let validatorService: ValidatorServiceInstance;
    let delegationController: DelegationControllerInstance;

    let web3DelegationService: Contract;
    let web3DelegationController: Contract;

    beforeEach(async () => {
        contractManager = await deployContractManager();

        skaleManagerMock = await SkaleManagerMock.new(contractManager.address);
        await contractManager.setContractsAddress("SkaleManager", skaleManagerMock.address);

        skaleToken = await deploySkaleToken(contractManager);
        delegationService = await deployDelegationService(contractManager);
        validatorService = await deployValidatorService(contractManager);
        delegationController = await deployDelegationController(contractManager);

        web3DelegationService = new web3.eth.Contract(
            artifacts.require("./DelegationService").abi, delegationService.address);
        web3DelegationController = new web3.eth.Contract(
            artifacts.require("./DelegationController").abi, delegationController.address);
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

    async function delegate(holder: Account, validatorId: number, amount: BigNumber, delegationPeriod: number) {
        const data = web3DelegationController.methods.delegate(
            validatorId, amount.toString(10), delegationPeriod, "D2 is even").encodeABI();
        const receipt = await sendTransaction(holder, delegationController.address, data);
        if (receipt.logs) {
            const log = web3.eth.abi.decodeLog([{type: "uint", name: "delegationId"}], receipt.logs[0].data, [ "0x44a3960d6c88b789c9497fa950b0dabebb5912af1be8dbe814175b1296007e68" ]);
            interface IDelegationRequestIsSent {
                delegationId: string;
            }
            return Number.parseInt((log as IDelegationRequestIsSent).delegationId, 10);
        }
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
                        validatorsAmount: number,
                        holdersAmount: number) {
        const timeStart = await currentTime(web3);
        const etherAmount = 5 * 1e18;
        const tokensAmount = new BigNumber(1e6).multipliedBy(new BigNumber(10).pow(18));

        const random = new Random(13);

        const validators = [];
        for (let i = 0; i < validatorsAmount; ++i) {
            const validator = web3.eth.accounts.create();
            validators.push(validator);
            await web3.eth.sendTransaction({from: owner, to: validator.address, value: etherAmount});
            const validatorId = await registerValidator(validator, "Validator #" + (i + 1), random.next() % 1001);
            await validatorService.enableValidator(validatorId);
        }

        const holders = validators.slice();
        if (holders.length > holdersAmount) {
            holders.length = holdersAmount;
        }
        for (let i = 0; i < holdersAmount; ++i) {
            let holder;
            if (i >= holders.length) {
                holder = web3.eth.accounts.create();
                holders.push(holder);
            } else {
                holder = holders[i];
            }
            await skaleToken.mint(owner, holder.address, tokensAmount.toString(10), "0x", "0x");
        }

        await delegate(holders[0], 1, new BigNumber(13), 3);
        await delegate(holders[0], 1, new BigNumber(13), 3);
        const delId = await delegate(holders[0], 1, new BigNumber(13), 3);
        console.log("delId:", delId);
        console.log("Type:", typeof(delId));

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
        await test(5 * 60, 60, 1, 1);
    });
});
