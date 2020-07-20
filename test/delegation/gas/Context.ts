import { DelegationControllerInstance, ValidatorServiceInstance } from "../../../types/truffle-contracts";
import Contract from "web3/eth/contract";

export class Context {
    validatorService: ValidatorServiceInstance;
    web3ValidatorService: Contract;
    delegationController: DelegationControllerInstance;
    web3DelegationController: Contract;
    web3SkaleToken: Contract;

    constructor(
        validatorService: ValidatorServiceInstance,
        web3ValidatorService: Contract,
        delegationController: DelegationControllerInstance,
        web3DelegationController: Contract,
        web3SkaleToken: Contract
    ) {
        this.validatorService = validatorService;
        this.web3ValidatorService = web3ValidatorService;
        this.delegationController = delegationController;
        this.web3DelegationController = web3DelegationController;
        this.web3SkaleToken = web3SkaleToken;
    }
}