import { ethers } from "hardhat";
import { LinkedList__factory } from "../typechain-types";

describe("LinkedList tests", () => {
    let NUM_TO_PUSH = 300 
    it("random", async () => {
        let [signer] = await ethers.getSigners()
        let factory = new LinkedList__factory(signer)
        let ll = await factory.deploy(getRandomInt(1000))
        await ll.deployTransaction.wait(1)

        let pushed: number[] = []
        for (let i = 0; i < NUM_TO_PUSH; i++) {
            let val = getRandomInt(1000)
            if (!pushed.find(p => p === val)) {
                pushed.push(val)
                await ll.push(val)
                console.log((await ll.getSortedList()).map((val: any) => val.toString()))
            }
        }
        console.log(await ll.getSortedList())
    })
    it.only("ascending", async () => {
        let [signer] = await ethers.getSigners()
        let factory = new LinkedList__factory(signer)
        let ll = await factory.deploy(getRandomInt(1000))
        await ll.deployTransaction.wait(1)

        for (let i = 0; i < NUM_TO_PUSH; i++) {
            await ll.push(i)
        }
        console.log((await ll.getSortedList()).map((val: any) => val.toString()))
    })
    it("descending", async () => {
        let [signer] = await ethers.getSigners()
        let factory = new LinkedList__factory(signer)
        let ll = await factory.deploy(getRandomInt(1000))
        await ll.deployTransaction.wait(1)

        for (let i = NUM_TO_PUSH; i > 0; i--) {
            await ll.push(i)
        }
        console.log((await ll.getSortedList()).map((val: any) => val.toString()))
    })
})

function getRandomInt(max: number): number {
    return Math.floor(Math.random() * max);
  }