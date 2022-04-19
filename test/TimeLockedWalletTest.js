const TrustlessTimeLocker = artifacts.require("./TrustlessTimeLocker.sol");
const ERC20Token = artifacts.require("./ERC20.sol");

let ethToSend = web3.utils.toWei(String(1), "ether");
let someGas = web3.utils.toWei(String(0.01), "ether");
let creator;
let owner;

const tokenAdd_MAINNET = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
const UNLOCKED_ACCOUNT = "0x6262998ced04146fa42253a5c0af90ca02dfd2a3";
const uni_r = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
//

contract('TrustlessTimeLocker', (accounts) => {

    before(async () => {
        creator = accounts[0];
        owner = accounts[1];
        other = accounts[2];
    });

    describe("UniswapTradeExample", function () {
        it("Swap ETH for DAI", async function () {
            const provider = ethers.provider;
            const [owner, addr1] = await ethers.getSigners();
            const DAI = new ethers.Contract(DAI_ADDRESS, ERC20ABI, provider);
    
            // Assert addr1 has 1000 ETH to start
            addr1Balance = await provider.getBalance(addr1.address);
            expectedBalance = ethers.BigNumber.from("10000000000000000000000");
            assert(addr1Balance.eq(expectedBalance));
    
            // Assert addr1 DAI balance is 0
            addr1Dai = await DAI.balanceOf(addr1.address);
            assert(addr1Dai.isZero());
    
            // Deploy UniswapTradeExample
            const uniswapTradeExample =
                await ethers.getContractFactory("UniswapTradeExample")
                    .then(contract => contract.deploy(UNISWAPV2ROUTER02_ADDRESS));
            await uniswapTradeExample.deployed();
    
            // Swap 1 ETH for DAI
            await uniswapTradeExample.connect(addr1).swapExactETHForTokens(
                0,
                DAI_ADDRESS,
                { value: ethers.utils.parseEther("1") }
            );
    
            // Assert addr1Balance contains one less ETH
            expectedBalance = addr1Balance.sub(ethers.utils.parseEther("1"));
            addr1Balance = await provider.getBalance(addr1.address);
            assert(addr1Balance.lt(expectedBalance));
    
            // Assert DAI balance increased
            addr1Dai = await DAI.balanceOf(addr1.address);
            assert(addr1Dai.gt(ethers.BigNumber.from("0")));
        });
    });
    it("Owner can withdraw the funds after the unlock date", async () => {

        const tokenAdd = await ERC20Token.at(tokenAdd_MAINNET);
        let creatorBal = await web3.eth.getBalance(creator);
        console.log("----OWNER v:",await web3.eth.getBalance(owner));
        console.log("----Creator v:",await web3.eth.getBalance(creator));
        //set unlock date in unix epoch to now
        let now = Math.floor((new Date).getTime() / 1000);
        //create the contract and load the contract with some eth
        let TrustlessTimeLocker = await TrustlessTimeLocker.new(creator, owner, tokenAdd_MAINNET);

        //await tokenAdd.approve(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 100000000000000);
        await tokenAdd.approve(creator, 100000000000000);
        await tokenAdd.approve(owner, 100000000000000);
        await tokenAdd.approve(TrustlessTimeLocker.address, 100000000000000);

        console.log("-----1----------");
        await TrustlessTimeLocker.swapEthForToken(1), { from: creator };
        console.log("-----1----------");
       // await TrustlessTimeLocker.send(ethToSend, {from: creator});
       console.log("TrustlessTimeLocker v:",await web3.eth.getBalance(TrustlessTimeLocker.address));
       console.log("OWNER v:",await web3.eth.getBalance(owner));
       console.log("Creator v:",await web3.eth.getBalance(creator));
        assert(ethToSend == await web3.eth.getBalance(TrustlessTimeLocker.address));

        let balanceBefore = await web3.eth.getBalance(owner);
        let creatorBalaf = await web3.eth.getBalance(creator);
        console.log("creatorBalaf:",creatorBalaf)
        await TrustlessTimeLocker.withdraw({from: owner});
        let balanceAfter = await web3.eth.getBalance(owner);
        assert(balanceAfter - balanceBefore >= ethToSend - someGas);
    });


    it("only owner can pull fund before the timeout", async () => {
        //set unlock date in unix epoch to now
        let now = Math.floor((new Date).getTime() / 1000);
        
        //create the contract
        let TrustlessTimeLocker = await TrustlessTimeLocker.new(creator, owner, tokenAdd_MAINNET);

        //load the contract with some eth
        await TrustlessTimeLocker.send(ethToSend, {from: creator});
        assert(ethToSend == await web3.eth.getBalance(TrustlessTimeLocker.address));
        
        try {
            await TrustlessTimeLocker.withdraw({from: creator})
            assert(false, "Expected error not received");
        } catch (error) {} //expected

        try {
            await TrustlessTimeLocker.withdraw({from: other})
            assert(false, "Expected error not received");
        } catch (error) {} //expected

        //contract balance is intact
        assert(ethToSend == await web3.eth.getBalance(TrustlessTimeLocker.address));
    });

    it("Nobody other than the creator can withdraw funds after the timeout", async () => {
        //set unlock date in unix epoch to now
        let now = Math.floor((new Date).getTime() / 1000);

        //create the contract
        let TrustlessTimeLocker = await TrustlessTimeLocker.new(creator, owner, tokenAdd_MAINNET);

        //load the contract with some eth
        await TrustlessTimeLocker.send(ethToSend, {from: creator});
        assert(ethToSend == await web3.eth.getBalance(TrustlessTimeLocker.address));
        let balanceBefore = await web3.eth.getBalance(owner);

        try {
          await TrustlessTimeLocker.withdraw({from: owner})
          assert(false, "Expected error not received");
        } catch (error) {} //expected

        try {
          await TrustlessTimeLocker.withdraw({from: other})
          assert(false, "Expected error not received");
        } catch (error) {} //expected

        //contract balance is intact
        assert(ethToSend == await web3.eth.getBalance(TrustlessTimeLocker.address));
    });

});
