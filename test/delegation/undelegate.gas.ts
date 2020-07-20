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

contract("Undelegate", ([owner, holder]) => {
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

    for (let duration = 1; duration <= 100 * 12; ++duration) {
        it("Delegate for " + duration + " months", async () => {
            await delegationController.delegate(validatorId, tokensAmount.toString(10), [3, 6, 12][Math.floor(Math.random() * 3)], "", {from: holder});
            const delegationId = 0;
            await delegationController.acceptPendingDelegation(delegationId);
            skipTime(web3, duration * month);
            const receipt = await delegationController.requestUndelegation(delegationId, {from: holder});
            console.log(receipt.receipt.gasUsed);
        });
    }
});