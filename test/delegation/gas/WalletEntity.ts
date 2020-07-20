import { Account } from "web3/eth/accounts";
import { TransactionObject } from "web3/eth/types";
import { Context } from "./Context";
import { GasLogger } from "./GasLogger";

export class WalletEntity {
    account: Account;
    context: Context;
    log = new GasLogger();

    constructor(context: Context, account: Account | undefined) {
        this.context = context;
        if (account === undefined) {
            this.account = web3.eth.accounts.create();
        } else {
            this.account = account;
        }
    }

    pick(array: any[]) {
        return array[Math.floor(Math.random() * array.length)]
    }
}

export async function signAndSend(method: TransactionObject<any>, from: Account, toAddress: string) {
    const callData = method.encodeABI();

    const tx = {
        data: callData,
        from: from.address,
        gas: 10e6,
        to: toAddress,
    };

    const signedTx = await from.signTransaction(tx);
    try {
        return await web3.eth.sendSignedTransaction(signedTx.rawTransaction);
    } catch (e) {
        console.log("Something fails");
        console.log(e);
        throw e;
    }
}
