import { WalletEntity, signAndSend } from "./WalletEntity";
import { Validator } from "./Validator";
import { Context } from "./Context";
import { Queue } from "./Queue";
import { State } from "../../tools/types";

export class Holder extends WalletEntity {

    accepted = new Queue<number>();
    delegated: number[] = [];
    undelegationRequested: number[] = [];

    constructor(context: Context) {
        super(context, undefined);
    }

    async delegate(validator: Validator) {
        const balance = await this.getBalance();
        const locked = await this.getLocked();
        const available = balance - locked;
        const receipt = await signAndSend(
            this.context.web3DelegationController.methods.delegate(
                validator.id,
                Math.floor(available / 100).toString(10),
                this.pick([3, 6, 12]),
                "No info"
            ),
            this.account,
            this.context.web3DelegationController.options.address
        );
        this.log.log("delegate", receipt.gasUsed);
        if (receipt.logs) {
            const delegationId = Number.parseInt(receipt.logs[0].data, 16);
            await validator.acceptPendingDelegation(delegationId);
            this.accepted.push(delegationId);
            return delegationId;
        } else {
            throw new Error("Can't parce delegationId");
        }
    }

    async undelegate(delegationId: number) {
        try {
            const receipt = await signAndSend(
                this.context.web3DelegationController.methods.requestUndelegation(
                    delegationId
                ),
                this.account,
                this.context.web3DelegationController.options.address
            );
            this.log.log("undelegate", receipt.gasUsed);
            this.delegated.splice(this.delegated.indexOf(delegationId), 1);
            this.undelegationRequested.push(delegationId);
            return receipt;
        } catch (e) {
            console.log("undelegate fails");
            console.log(e);
            process.exit(1);
        }
    }

    async getBalance() {
        const balance = await this.context.web3SkaleToken.methods.balanceOf(this.account.address).call();
        return Number.parseInt(balance.toString(), 10);
    }

    async getLocked() {
        const locked = await this.context.web3SkaleToken.methods.getAndUpdateLockedAmount(this.account.address).call();
        return Number.parseInt(locked.toString(), 10);
    }

    getDelegationsAmount() {
        return this.accepted.toArray().length + this.delegated.length + this.undelegationRequested.length;
    }

    async updateDelegationsStatuses() {
        for (let delegationId = this.accepted.pop(); delegationId !== undefined; delegationId = this.accepted.pop()) {
            const state = (await this.context.delegationController.getState(delegationId)).toNumber();
            if (state === State.ACCEPTED) {
                this.accepted.pushFront(delegationId);
                break;
            } else if (state === State.DELEGATED) {
                this.delegated.push(delegationId);
            } else if (state === State.UNDELEGATION_REQUESTED) {
                this.undelegationRequested.push(delegationId);
            }
        }

        const undelegationRequested = []
        for (const delegationId of this.undelegationRequested) {
            const state = (await this.context.delegationController.getState(delegationId)).toNumber();
            if (state === State.UNDELEGATION_REQUESTED) {
                undelegationRequested.push(delegationId)
            }
        }
        this.undelegationRequested = undelegationRequested;
    }
}
