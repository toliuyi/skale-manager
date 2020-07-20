import { ContractManagerInstance,
    SkaleTokenInstance,
    DelegationControllerInstance,
    ValidatorServiceInstance,
    ConstantsHolderInstance } from "../../types/truffle-contracts";
import { deployContractManager } from "../tools/deploy/contractManager";
import { deploySkaleToken } from "../tools/deploy/skaleToken";
import { deployDelegationController } from "../tools/deploy/delegation/delegationController";
import { deployValidatorService } from "../tools/deploy/delegation/validatorService";
import { deployConstantsHolder } from "../tools/deploy/constantsHolder";
import { skipTime } from "../tools/time";
import * as chai from "chai";
import * as chaiAsPromised from "chai-as-promised";
import { Validator } from "./gas/Validator";
import { Holder } from "./gas/Holder";
import { WalletEntity } from "./gas/WalletEntity";
import { Context } from "./gas/Context";
import fs = require('fs');
import { TestResult } from "./gas/TestResult";

chai.should();
chai.use(chaiAsPromised);

contract("Gas usage", ([owner]) => {
    let contractManager: ContractManagerInstance;
    let skaleToken: SkaleTokenInstance;
    let delegationController: DelegationControllerInstance;
    let validatorService: ValidatorServiceInstance;
    let constantsHolder: ConstantsHolderInstance;

    let context: Context;

    const results: TestResult[] = [];
    const etherAmount = 50 * 1e18;
    const tokensAmount = 100 * 1e18;
    const month = 60 * 60 * 24 * 31;
    // const averageDelegationLength = 6 * month;
    // const delegationsAmount = 10;
    const testDuration = 20;

    beforeEach(async () => {
        contractManager = await deployContractManager();

        delegationController = await deployDelegationController(contractManager);
        constantsHolder = await deployConstantsHolder(contractManager);
        validatorService = await deployValidatorService(contractManager);
        skaleToken = await deploySkaleToken(contractManager);

        context = new Context(
            validatorService,
            new web3.eth.Contract(
                artifacts.require("./ValidatorService").abi,
                validatorService.address
            ),
            delegationController,
            new web3.eth.Contract(
                artifacts.require("./DelegationController").abi,
                delegationController.address
            ),
            new web3.eth.Contract(
                artifacts.require("./SkaleToken").abi,
                skaleToken.address
            )
        )

        await constantsHolder.setLaunchTimestamp(0);
    });

    // for (let holdersAmount = 1; holdersAmount <= 1000; holdersAmount += holdersAmount === 1 ? 199 : 200) {
    //     for (let validatorsAmount = 1; validatorsAmount <= 1000; validatorsAmount += validatorsAmount === 1 ? 199 : 200) {
    //         for (let delegationsAmount = 10; delegationsAmount <= 1000; delegationsAmount += delegationsAmount === 10 ? 190: 200) {

    // for (const holdersAmount of [3, 100, 1000]) {
    //     for (const validatorsAmount of [3, 10, 100]) {
    //         for (const totalDelegationsAmount of [10, 500, 1000]) {
    //             for (const averageDelegationLength of [3 * month, 3 * 12 * month, 10 * 12 * month]) {

    // // for (const holdersAmount of [200]) {
    // //     for (const validatorsAmount of [500]) {
    // //         for (const totalDelegationsAmount of [500]) {
    // //             for (const averageDelegationLength of [10 * 12 * month]) {
    //                 it("" + holdersAmount + " holders -> " + validatorsAmount + " validators (" + Math.floor(totalDelegationsAmount / holdersAmount) + " delegations each) for ~" + averageDelegationLength / month + " months", async () => {
    //                     const delegationsAmount = Math.max(1, Math.floor(totalDelegationsAmount / holdersAmount));
    //                     // generate holders
    //                     const holders = [];
    //                     for (let i = 0; i < holdersAmount; ++i) {
    //                         holders.push(new Holder(context));
    //                     }

    //                     // generate validators
    //                     const validators = [];
    //                     for (let i = 0; i < validatorsAmount; ++i) {
    //                         validators.push(new Validator(context));
    //                     }

    //                     // give ether
    //                     for (const entity of (holders as WalletEntity[]).concat(validators)) {
    //                         await web3.eth.sendTransaction({from: owner, to: entity.account.address, value: etherAmount});
    //                     }

    //                     // give tokens
    //                     for (const holder of holders) {
    //                         await skaleToken.mint(holder.account.address, tokensAmount.toString(10), "0x", "0x");
    //                     }

    //                     // register validators
    //                     for (const validator of validators) {
    //                         await validator.registerValidator();
    //                         await validatorService.enableValidator(validator.id);
    //                     }

    //                     let start = 0;
    //                     let iterateions = 0;
    //                     do {
    //                         ++iterateions;
    //                         // console.log("-----------------------------------------------------");
    //                         skipTime(web3, month);

    //                         for (const holder of holders) {
    //                             await holder.updateDelegationsStatuses();

    //                             // delegate
    //                             for (let i = holder.getDelegationsAmount(); i < delegationsAmount; ++i) {
    //                                 // console.log("Delegate");
    //                                 await holder.delegate(holder.pick(validators));
    //                             }

    //                             // undelegate
    //                             for (const delegationId of holder.delegated) {
    //                                 const probability = month / averageDelegationLength;
    //                                 if (Math.random() < probability) {
    //                                     // console.log("Undelegate");
    //                                     await holder.undelegate(delegationId);
    //                                 }
    //                             }
    //                         }
    //                         if (start === 0) {
    //                             start = new Date().getTime();
    //                         }
    //                     } while (new Date().getTime() - start < testDuration * 1000);
    //                     console.log(iterateions + " iterations");

    //                     // return ether

    //                     for (const entity of (holders as WalletEntity[]).concat(validators)) {
    //                         const balance = Number.parseInt(await web3.eth.getBalance(entity.account.address), 10);
    //                         const gas = 21 * 1e3;
    //                         const gasPrice = 20 * 1e9;
    //                         const sendTx = {
    //                             from: entity.account.address,
    //                             gas,
    //                             gasPrice,
    //                             to: owner,
    //                             value: balance - gas * gasPrice,
    //                         };
    //                         const signedSendTx = await entity.account.signTransaction(sendTx);
    //                         await web3.eth.sendSignedTransaction(signedSendTx.rawTransaction);
    //                         await web3.eth.getBalance(entity.account.address).should.be.eventually.equal("0");
    //                     }

    //                     const testResult = new TestResult(holdersAmount, validatorsAmount, averageDelegationLength, delegationsAmount);
    //                     for (const holder of holders) {
    //                         let data = holder.log.gas.get("delegate");
    //                         if (data !== undefined) {
    //                             testResult.delegateFunction = testResult.delegateFunction.concat(data);
    //                         }
    //                         data = holder.log.gas.get("undelegate");
    //                         if (data !== undefined) {
    //                             testResult.undelegateFunction = testResult.undelegateFunction.concat(data);
    //                         }
    //                     }
    //                     for (const validator of validators) {
    //                         const data = validator.log.gas.get("accept");
    //                         if (data !== undefined) {
    //                             testResult.acceptFunction = testResult.acceptFunction.concat(data);
    //                         }
    //                     }
    //                     results.push(testResult);
    //                 })
    //             }
    //         }
    //     }
    // }

    // afterEach(async () => {
    //     await fs.promises.writeFile("result.json", JSON.stringify(results));
    // })

    it("each to each", async () => {
        const n = 20;
        const holdersAmount = n;
        const validatorsAmount = n;

        // generate holders
        const holders = [];
        for (let i = 0; i < holdersAmount; ++i) {
            holders.push(new Holder(context));
        }

        // generate validators
        const validators = [];
        for (let i = 0; i < validatorsAmount; ++i) {
            validators.push(new Validator(context));
        }

        // give ether
        for (const entity of (holders as WalletEntity[]).concat(validators)) {
            await web3.eth.sendTransaction({from: owner, to: entity.account.address, value: etherAmount});
        }

        // give tokens
        for (const holder of holders) {
            await skaleToken.mint(holder.account.address, tokensAmount.toString(10), "0x", "0x");
        }

        // register validators
        for (const validator of validators) {
            await validator.registerValidator();
            await validatorService.enableValidator(validator.id);
        }

        const delegations = new Map<Holder, number[]>();
        for (const holder of holders) {
            const holderDelegations = [];
            for (const validator of validators) {
                holderDelegations.push(await holder.delegate(validator));
                skipTime(web3, month);
            }
            delegations.set(holder, holderDelegations);
        }
        let holderIndex = 0;
        for (const holder of holders) {
            const holderDelegations = delegations.get(holder);
            if (holderDelegations !== undefined) {
                for (const delegationId of holderDelegations) {
                    const receipt = await holder.undelegate(delegationId);
                    // console.log("Undelegate: " + receipt.gasUsed);

                    const delegation = await delegationController.delegations(delegationId);
                    const validatorId = delegation[1].toNumber();
                    validators[validatorId - 1].id.should.be.equal(validatorId);

                    await holder.delegate(validators[validatorId - 1]);
                    const gasLog = holder.log.gas.get('delegate');
                    if (gasLog !== undefined) {
                        const gasUsed = gasLog.slice(-1)[0];
                        if (gasUsed > 1e6) {
                            console.log("Delegate: " + holderIndex + " -> " + validatorId + ": " + gasLog.slice(-1)[0]);
                        }
                    }
                    skipTime(web3, month);
                }
            }
            ++holderIndex;
        }
    });
});