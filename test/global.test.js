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

    describe("Ability to check initial values", () => {

        const THRESHOLD = 10000;
        const TIMESTAMP = 300;

        // setup
        beforeEach(async () => {

            // deploying token
            token = await Token.new();

            // deploying fundraiser
            contract = await WiseFunder.new(
                token.address,
                owner,
                THRESHOLD,
                TIMESTAMP
            );
        });

        it("should have correct token address", async () => {
            const tokenAddressValue = await contract.WISE_TOKEN();
            assert.equal(
                token.address,
                tokenAddressValue
            );
        });

        it("should have correct owner address", async () => {
            const fundOwnerValue = await contract.FUND_OWNER();
            assert.equal(
                owner,
                fundOwnerValue
            );
        });

        it("should have correct threshold value", async () => {
            const thresholdValue = await contract.THRESHOLD();
            assert.equal(
                thresholdValue,
                THRESHOLD
            );
        });

        it.skip("should have correct timestamp value", async () => {

            const timestampValue = await contract.TIMESTAMP();

            console.log(
                timestampValue.toString(),
                'timestampValue'
            );

            assert.equal(
                timestampValue,
                TIMESTAMP
            );
        });

        it.skip("should only allow to claim tokens by the owner", async () => {

            await catchRevert(
                contract.claimToken({from: user1}),
                "WiseFunder: invalid address"
            );

            await catchRevert(
                contract.claimToken({from: owner}),
                "WiseFunder: not funded"
            );

            await advanceTimeAndBlock(
                300
            );
        });
    });

    describe("Ability to fund contract as expected", () => {

        const THRESHOLD = 10000;
        const TIMESTAMP = 300;

        // setup
        beforeEach(async () => {

            // deploying token
            token = await Token.new();

            // deploying fundraiser
            contract = await WiseFunder.new(
                token.address,
                owner,
                THRESHOLD,
                TIMESTAMP
            );
        });

        it("should reflect user balance once funded", async () => {

            const TOKEN_AMOUNT = 1000;

            // step 1: approve
            await token.approve(
                contract.address,
                TOKEN_AMOUNT
            );

            // step 2: fund tokens
            await contract.fundTokens(
                TOKEN_AMOUNT
            );

            // step 3: read contract data
            const balanceValue = await contract.balanceMap(
                owner
            );

            // step 4: compare - actual test
            assert.equal(
                balanceValue,
                TOKEN_AMOUNT
            );
        });

        it("should reflect user balance multiple funded", async () => {

            const TOKEN_AMOUNT_A = 1000;
            const TOKEN_AMOUNT_B = 2000;
            const TOKEN_AMOUNT_TOTAL = TOKEN_AMOUNT_A + TOKEN_AMOUNT_B;

            // step 1: approve
            await token.approve(
                contract.address,
                TOKEN_AMOUNT_TOTAL
            );

            // step 2: fund tokens
            await contract.fundTokens(
                TOKEN_AMOUNT_A
            );

            await contract.fundTokens(
                TOKEN_AMOUNT_B
            );

            // step 3: read contract data
            const balanceValue = await contract.balanceMap(
                owner
            );

            // step 4: compare - actual test
            assert.equal(
                balanceValue,
                TOKEN_AMOUNT_TOTAL
            );
        });

        it("should allow to refund tokens back if not fully funded", async () => {

            const TOKEN_AMOUNT_A = 1000;
            const TOKEN_AMOUNT_B = 2000;
            const TOKEN_AMOUNT_TOTAL = TOKEN_AMOUNT_A + TOKEN_AMOUNT_B;

            // step 1: approve
            await token.approve(
                contract.address,
                TOKEN_AMOUNT_TOTAL
            );

            // step 2: fund tokens
            await contract.fundTokens(
                TOKEN_AMOUNT_A
            );

            await contract.fundTokens(
                TOKEN_AMOUNT_B
            );

            // step 3: read contract data
            const refundAmount = await contract.balanceMap(
                owner
            );

            // step 4: double check refund amount
            assert.equal(
                refundAmount,
                TOKEN_AMOUNT_TOTAL
            );

            // step 5: try to refund early
            await catchRevert(
                contract.refundTokens(),
                'WiseFunder: ongoing funding'
            );

            // step 6: advance time forward
            await advanceTimeAndBlock(
                TIMESTAMP // amount of seconds
            );

            // step 7: INVOKE REFUND (shoudl generate 2 events)
            // event1: transfer from token movement
            // event2: RefundIssued from contract
            await contract.refundTokens();

            const eventData = await getLastEvent(
                'Transfer',
                token
            );

            // TEST
            assert.equal(
                eventData.from,
                contract.address
            );

            // TEST
            assert.equal(
                eventData.to,
                owner
            );

            // TEST
            assert.equal(
                eventData.value,
                TOKEN_AMOUNT_TOTAL
            );

            // step 8: check refund balance again
            const amountAfterRefund = await contract.balanceMap(
                owner
            );

            // step 9: compare with 0
            assert.equal(
                amountAfterRefund,
                0
            );
        });
    });
});
