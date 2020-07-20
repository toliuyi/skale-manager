export class TestResult {
    holdersAmount: number;
    validatorsAmount: number;
    averageDelegationLength: number;
    delegationsAmount: number;
    delegateFunction: number[] = [];
    undelegateFunction: number[] = [];
    acceptFunction: number[] = [];

    constructor(holdersAmount: number, validatorsAmount: number, averageDelegationLength: number, delegationsAmount: number) {
        this.holdersAmount = holdersAmount;
        this.validatorsAmount = validatorsAmount;
        this.averageDelegationLength = averageDelegationLength;
        this.delegationsAmount = delegationsAmount;
    }
}