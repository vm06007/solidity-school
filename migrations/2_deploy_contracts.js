const WiseFunder = artifacts.require("WiseFunder");

module.exports = async function(deployer) {

    const TIMESTAMP = 300;
    const THRESHOLD = 1000;

    const TOKEN = "0x66a0f676479Cee1d7373f3DC2e2952778BfF5bd6";
    const OWNER = "0x641AD78BAca220C5BD28b51Ce8e0F495e85Fe689";

    await Promise.all([
        deployer.deploy(
            WiseFunder,
            TOKEN,
            OWNER,
            THRESHOLD,
            TIMESTAMP,
            {gas: 8000000}
        )
    ]);
};
