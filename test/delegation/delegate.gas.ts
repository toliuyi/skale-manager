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

contract("Delegate", ([owner, holder]) => {
    let contractManager: ContractManagerInstance;
    let skaleToken: SkaleTokenInstance;
    let delegationController: DelegationControllerInstance;
    let validatorService: ValidatorServiceInstance;
    let constantsHolder: ConstantsHolderInstance;

    let context: Context;

    // const results: TestResult[] = [];
    const etherAmount = 50 * 1e18;
    const tokensAmount = 100 * 1e18;
    const month = 60 * 60 * 24 * 31;
    // const averageDelegationLength = 6 * month;
    // const delegationsAmount = 10;
    const testDuration = 20;
    const validatorId = 1;

    beforeEach(async () => {
        contractManager = await deployContractManager();

        delegationController = await deployDelegationController(contractManager);
        constantsHolder = await deployConstantsHolder(contractManager);
        validatorService = await deployValidatorService(contractManager);
        skaleToken = await deploySkaleToken(contractManager);

        await skaleToken.mint(holder, tokensAmount.toString(10), "0x", "0x");
        await validatorService.registerValidator("D2", "", 150, 1e6);
        await validatorService.enableValidator(validatorId);

        await constantsHolder.setLaunchTimestamp(0);
    });

    it("long break", async () => {
        let currentDelegationId = 0;
        await delegationController.delegate(validatorId, 1e7.toString(10), [3, 6, 12][Math.floor(Math.random() * 3)], "", {from: holder});
        await delegationController.acceptPendingDelegation(currentDelegationId);
        ++currentDelegationId;
        const results = new Map<number, number[]>();
        for (let duration = 1; duration <= 100 * 12; ++duration) {
            skipTime(web3, duration * month);
            const receipt = await delegationController.delegate(validatorId, 1e7.toString(10), [3, 6, 12][Math.floor(Math.random() * 3)], "", {from: holder});
            await delegationController.acceptPendingDelegation(currentDelegationId);
            ++currentDelegationId;
            results.set(duration, receipt.receipt.gasUsed);
            console.log(receipt.receipt.gasUsed);
            await fs.promises.writeFile("result.json", JSON.stringify([...results]));
        }
    });

    // it("long break with undelegations", async () => {
    //     await delegationController.delegate(validatorId, 1e7.toString(10), [3, 6, 12][Math.floor(Math.random() * 3)], "", {from: holder});
    //     const results = new Map<number, number[]>();
    //     let currentDelegationId = 0;
    //     let delegations: number[][] = [];
    //     for (let duration = 1; duration <= 1 * 12; ++duration) {
    //         const n = Math.ceil(duration / 3);
    //         const delegationPeriod = 3;
    //         for (let i = 0; i < delegationPeriod; ++i) {
    //             delegations.push([]);
    //             console.log('Delegations bucket start');
    //             for (let j = 0; j < n; ++j) {
    //                 console.log('Delegate');
    //                 await delegationController.delegate(validatorId, 1e7.toString(10), delegationPeriod, "", {from: holder});
    //                 delegations[i].push(currentDelegationId);
    //                 ++currentDelegationId;
    //             }
    //             skipTime(web3, month);
    //         }
    //         console.log("Preparations completed");
    //         console.log(delegations);
    //         for (let i = 0; i < duration; ++i) {
    //             const bucket = Math.floor(i / delegationPeriod);
    //             console.log("Undelegate");
    //             console.log("State:", (await delegationController.getState(delegations[bucket][0])).toNumber());
    //             await delegationController.requestUndelegation(delegations[bucket][0], {from: holder});
    //             delegations[bucket].shift();
    //             skipTime(web3, month);
    //         }
    //         const receipt = await delegationController.delegate(validatorId, 1e7.toString(10), [3, 6, 12][Math.floor(Math.random() * 3)], "", {from: holder});
    //         delegations[0].push(currentDelegationId);
    //         ++currentDelegationId;
    //         const gas = receipt.receipt.gasUsed;
    //         console.log(gas);
    //         results.set(duration, gas);
    //         for (const delegationsBucket of delegations) {
    //             for (const delegationId of delegationsBucket) {
    //                 await delegationController.requestUndelegation(delegationId, {from: holder});
    //             }
    //         }
    //         delegations = [];
    //     }
    //     await fs.promises.writeFile("result.json", JSON.stringify([...results]));
    // });

    // for (let duration = 1; duration <= 100 * 12; ++duration) {
    //     it("Delegate after " + duration + " months", async () => {
    //         await delegationController.delegate(validatorId, (tokensAmount / 2).toString(10), [3, 6, 12][Math.floor(Math.random() * 3)], "", {from: holder});
    //         const delegationId = 0;
    //         await delegationController.acceptPendingDelegation(delegationId);
    //         skipTime(web3, duration * month);
    //         const receipt = await delegationController.delegate(validatorId, (tokensAmount / 2).toString(10), [3, 6, 12][Math.floor(Math.random() * 3)], "", {from: holder});
    //         console.log(receipt.receipt.gasUsed);
    //     });
    // }
});