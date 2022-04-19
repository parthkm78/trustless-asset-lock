const TrustlessTimeLocker = artifacts.require("./TrustlessTimeLocker.sol");
const TrustlessTimeLockerFactory = artifacts.require("./TrustlessTimeLockerFactory.sol");

let ethToSend = web3.utils.toWei(String(1), "ether");
let someGas = web3.utils.toWei(String(0.01), "ether");
let trustlessTimeFactoryVar;

let creator;
let owner;
const tokenAdd_MAINNET = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";

contract('TrustlessTimeLockerFactory', (accounts) => {

    before(async () => {
        creator = accounts[0];
        owner = accounts[1];
        trustlessTimeFactoryVar = await TrustlessTimeLockerFactory.new({from: creator});

    });

    it("Factory created contract is working well", async () => {
        // Create the wallet contract.
        let now = Math.floor((new Date).getTime() / 1000);
        await trustlessTimeFactoryVar.newTrustlessTimeLocker(
            owner, tokenAdd_MAINNET
        );

        // Check if wallet can be found in creator's wallets.
        let creatorWallets = await trustlessTimeFactoryVar.getWallets.call(creator);
        assert(1 == creatorWallets.length);

        // Check if wallet can be found in owners's wallets.
        let ownerWallets = await trustlessTimeFactoryVar.getWallets.call(owner);
        assert(1 == ownerWallets.length);
        
        // Check if this is the same wallet for both of them.
        assert(creatorWallets[0] === ownerWallets[0]);
    });

});
