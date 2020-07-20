export class Queue<T> {
    oldest: T[]
    newest: T[]

    constructor() {
        this.oldest = []
        this.newest = []
    }

    push(value: T) {
        this.newest.push(value);
    }

    pushFront(value: T) {
        this.oldest.push(value);
    }

    pop() {
        if (this.oldest.length === 0) {
            this.oldest = this.newest;
            this.newest = []
            this.oldest.reverse();
        }
        return this.oldest.pop();
    }

    toArray() {
        return this.oldest.slice().reverse().concat(this.newest);
    }
}