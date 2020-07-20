export class GasLogger {
    gas = new Map<string, number[]>();

    log(func: string, amount: number) {
        if(!this.gas.has(func)) {
            this.gas.set(func, []);
        }
        this.gas.get(func)?.push(amount);
    }
}