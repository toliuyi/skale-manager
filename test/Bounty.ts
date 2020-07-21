import { ContractManagerInstance, BountyInstance, SkaleManagerInstance, DelegationControllerInstance } from "../types/truffle-contracts";
import { deployContractManager } from "./tools/deploy/contractManager";
import { deploySkaleManager } from "./tools/deploy/skaleManager";
import { deployBounty } from "./tools/deploy/bounty";
import * as chaiAsPromised from "chai-as-promised";
import chaiAlmost = require("chai-almost");
import * as chai from "chai";
import { deployDelegationController } from "./tools/deploy/delegation/delegationController";
import { deploySkaleToken } from "./tools/deploy/skaleToken";
import { deployValidatorService } from "./tools/deploy/delegation/validatorService";
import { skipTime, currentTime } from "./tools/time";
import { deployConstantsHolder } from "./tools/deploy/constantsHolder";
import { deployDistributor } from "./tools/deploy/delegation/distributor";
import { deployDelegationPeriodManager } from "./tools/deploy/delegation/delegationPeriodManager";

chai.should();
chai.use(chaiAsPromised);
chai.use(chaiAlmost(0.1));

contract("Bounty", ([owner, admin, holder1, holder2, holder3, hacker]) => {
    let contractManager: ContractManagerInstance;
    let skaleManager: SkaleManagerInstance;
    let bountyContract: BountyInstance;

    beforeEach(async () => {
        contractManager = await deployContractManager();
        skaleManager = await deploySkaleManager(contractManager);
        bountyContract = await deployBounty(contractManager);

        await skaleManager.grantRole(await skaleManager.ADMIN_ROLE(), admin);
    });

    it("should allow only owner to call enableBountyReduction", async() => {
        await bountyContract.enableBountyReduction({from: hacker})
            .should.be.eventually.rejectedWith("Caller is not the owner");
        await bountyContract.enableBountyReduction({from: admin})
            .should.be.eventually.rejectedWith("Caller is not the owner");
        await bountyContract.enableBountyReduction({from: owner});
    });

    it("should allow only owner to call disableBountyReduction", async() => {
        await bountyContract.disableBountyReduction({from: hacker})
            .should.be.eventually.rejectedWith("Caller is not the owner");
        await bountyContract.disableBountyReduction({from: admin})
            .should.be.eventually.rejectedWith("Caller is not the owner");
        await bountyContract.disableBountyReduction({from: owner});
    });

    it("should pay bounty to a node in proportion of validator stake", async () => {
        const delegationController = await deployDelegationController(contractManager);
        const skaleToken = await deploySkaleToken(contractManager);
        const validatorService = await deployValidatorService(contractManager);
        const constantsHolder = await deployConstantsHolder(contractManager);
        const distributor = await deployDistributor(contractManager);
        const delegationPeriodManager = await deployDelegationPeriodManager(contractManager);

        const tokenAmount = 1e18;
        const month = 31 * 24 * 60 * 60;

        await skaleToken.mint(holder1, tokenAmount.toString(), "0x", "0x");
        await skaleToken.mint(holder2, tokenAmount.toString(), "0x", "0x");
        await skaleToken.mint(holder3, tokenAmount.toString(), "0x", "0x");
        await skaleToken.mint(skaleManager.address, "2000000000" + "0".repeat(18), "0x", "0x"); // bounty pool

        const validator1 = holder1;
        const validator2 = holder2;
        await validatorService.registerValidator("Validator 1", "", 0, 0, {from: validator1});
        await validatorService.registerValidator("Validator 2", "", 0, 0, {from: validator2});
        const validatorId1 = 1;
        const validatorId2 = 2;
        await validatorService.enableValidator(validatorId1);
        await validatorService.enableValidator(validatorId2);

        await delegationController.delegate(validatorId1, tokenAmount.toString(), 12, "", {from: holder1});
        await delegationController.delegate(validatorId1, tokenAmount.toString(), 6, "", {from: holder2});
        await delegationController.delegate(validatorId2, tokenAmount.toString(), 3, "", {from: holder3});
        await delegationController.acceptPendingDelegation(0, {from: validator1});
        await delegationController.acceptPendingDelegation(1, {from: validator1});
        await delegationController.acceptPendingDelegation(2, {from: validator2});

        skipTime(web3, month);

        const randomPublicKey = [
            "0x1122334455667788990011223344556677889900112233445566778899001122",
            "0x1122334455667788990011223344556677889900112233445566778899001122"
        ];
        await skaleManager.createNode(1, 0, "0x7F000001", "0x7F000001", randomPublicKey, "Node 1", {from: validator1});
        await skaleManager.createNode(2, 0, "0x7F000002", "0x7F000002", randomPublicKey, "Node 2", {from: validator2});

        const start = await currentTime(web3);
        await constantsHolder.setPeriods(month, 2 * 60 * 60);
        await constantsHolder.setLaunchTimestamp(start);

        const rewardPeriod = (await constantsHolder.rewardPeriod()).toNumber();
        skipTime(web3, rewardPeriod);
        for(;await currentTime(web3) < start + (await bountyContract.STAGE_LENGTH()).toNumber(); skipTime(web3, rewardPeriod)) {
            console.log(".");
            await skaleManager.getBounty(0, {from: validator1});
            await skaleManager.getBounty(1, {from: validator2});
        }

        const balance = web3.utils.toBN(await skaleToken.balanceOf(distributor.address));
        const ten18 = web3.utils.toBN(10).pow(web3.utils.toBN(18));
        const totalEarned = balance.div(ten18).toNumber();

        const earnedByHolder1 = web3.utils.toBN(
            (await distributor.getAndUpdateEarnedBountyAmount.call(validatorId1, {from: holder1}))[0]
        ).div(ten18).toNumber();
        const earnedByHolder2 = web3.utils.toBN(
            (await distributor.getAndUpdateEarnedBountyAmount.call(validatorId1, {from: holder2}))[0]
        ).div(ten18).toNumber();
        const earnedByHolder3 = web3.utils.toBN(
            (await distributor.getAndUpdateEarnedBountyAmount.call(validatorId2, {from: holder3}))[0]
        ).div(ten18).toNumber();
        console.log(earnedByHolder1);
        console.log(earnedByHolder2);
        console.log(earnedByHolder3);

        const coefficient1 = (await delegationPeriodManager.stakeMultipliers(12)).toNumber();
        const coefficient2 = (await delegationPeriodManager.stakeMultipliers(6)).toNumber();
        const coefficient3 = (await delegationPeriodManager.stakeMultipliers(3)).toNumber();

        earnedByHolder1.should.be.almost.equal(totalEarned * coefficient1 / (coefficient1 + coefficient2 + coefficient3));
        earnedByHolder1.should.be.almost.equal(totalEarned * coefficient2 / (coefficient1 + coefficient2 + coefficient3));
        earnedByHolder1.should.be.almost.equal(totalEarned * coefficient3 / (coefficient1 + coefficient2 + coefficient3));
    });
});
