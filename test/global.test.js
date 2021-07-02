const Token = artifacts.require("Token");
const WiseFunder = artifacts.require("WiseFunder");
const catchRevert = require("./exceptionsHelpers.js").catchRevert;

require("./utils");
const BN = web3.utils.BN;

// TESTING PARAMETERS
const ONE_ETH = web3.utils.toWei("1");
const TWO_ETH = web3.utils.toWei("2");
const STATIC_SUPPLY = web3.utils.toWei("5000000");
const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";

const getLastEvent = async (eventName, instance) => {
    const events = await instance.getPastEvents(eventName, {
        fromBlock: 0,
        toBlock: "latest",
    });
    return events.pop().returnValues;
};

contract("WiseFunder", ([owner, user1, user2, random]) => {

    describe("Ability to ...", () => {

        beforeEach(async () => {

            const THRESHOLD = 10000;
            const TIMESTAMP = 300;

            token = await Token.new();
            contract = await WiseFunder.new(
                token.address,
                owner,
                THRESHOLD,
                TIMESTAMP
            );
        });

        it("should ...", async () => {

            await catchRevert(
                contract.claimToken(),
                "WiseFunder: not funded"
            );

            await advanceTimeAndBlock(
                300
            );
        });
    });

    describe("Ability to ...", () => {

        beforeEach(async () => {
        });

        it("should ...", async () => {
        });

        it.skip("should ...", async () => {
        });

        it("should ...", async () => {
        });
    });

    describe.skip("Ability to ...", () => {

        beforeEach(async () => {
            token = await WiseToken.new({gas: 12000000});
        });

        it("should ...", async () => {
        });

        it("should ...", async () => {
        });

        it("should ...", async () => {
        });

        it("should ...", async () => {
        });
    });

    describe.only("Ability to ...", () => {

        const THRESHOLD = 10000;
        const TIMESTAMP = 300;

        beforeEach(async () => {

            token = await Token.new();
            contract = await WiseFunder.new(
                token.address,
                owner,
                THRESHOLD,
                TIMESTAMP
            );
        });

        it.skip("should ...", async () => {
        });

        it.skip("should ...", async () => {
        });

        it("should ...", async () => {
            await catchRevert(
                contract.claimToken(),
                "WiseFunder: not funded"
            );

            await advanceTimeAndBlock(
                300
            );

            const valueInContract = await contract.THRESHOLD();

            assert.equal(
                valueInContract,
                THRESHOLD
            );
        });
    });
});
