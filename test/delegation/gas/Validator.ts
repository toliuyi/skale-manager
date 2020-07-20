import { WalletEntity, signAndSend } from "./WalletEntity";
import { Account } from "web3/eth/accounts";
import { ValidatorServiceInstance } from "../../../types/truffle-contracts";
import Contract from "web3/eth/contract";
import { Context } from "./Context";

export class Validator extends WalletEntity {
    id: number;

    constructor(context: Context) {
        super(context, undefined);
        this.id = 0;
    }

    async registerValidator() {
        const validatorId = (await this.context.validatorService.numberOfValidators()).toNumber() + 1;
        await signAndSend(
            this.context.web3ValidatorService.methods.registerValidator(
                "Validator " + validatorId,
                "D2 is even",
                150,
                1e6 + 1
            ),
            this.account,
            this.context.validatorService.address
        );

        this.id = validatorId;
    }

    async acceptPendingDelegation(delegationId: number) {
        const receipt = await signAndSend(
            this.context.web3DelegationController.methods.acceptPendingDelegation(
                delegationId
            ),
            this.account,
            this.context.web3DelegationController.options.address
        );
        this.log.log("accept", receipt.gasUsed);
    }
}
