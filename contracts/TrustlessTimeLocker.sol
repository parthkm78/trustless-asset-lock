//SPDX-License-Identifier: Unlicense
pragma solidity 0.6.6;

// import file
import "./ERC20.sol";
import "./InterfaceTrustlessTimeLocker.sol";
import "./InterfaceSwap.sol";
// impport uniswapv2 router
import "@uniswap/v2-periphery/contracts/UniswapV2Router02.sol";

contract TrustlessTimeLocker is TrustlessTimeLockerInterface, SwapInterface{

    // The user who has deposite fund
    address public creator;
    // The user who will take fund
    address public unlockAdd;
     // The datetime before user can take fund
    uint256 public unlockDate;
    // Trustless lock creation time
    uint256 public createdAt;  

    // uniswap router deployd on mainnet
    address internal constant UNISWAP_V2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    IUniswapV2Router02 public uniswapRouter;
    // token address deployed on network
    address public  token;

    constructor(
        address _creator,
        address _unlockAdd,
        address _tokenAdd
    ) public payable{
        creator = _creator;
        unlockAdd = _unlockAdd;
        createdAt = now;
        token =_tokenAdd;
        uniswapRouter = IUniswapV2Router02(UNISWAP_V2_ROUTER);
    }
    
    // keep all the ether sent to this address
    receive() external payable { 
        emit Received(msg.sender, msg.value);
    }

  // callable by owner only, after specified time
    function withdraw() public override {
       require(now <= unlockDate, "The fund access time is over");
       require(msg.sender == unlockAdd, "Access denied. Only creator can access");
       //now send all the balance
       msg.sender.transfer(address(this).balance);
       emit Withdrew(msg.sender, address(this).balance);
    }
    /**
        Unlock address pull fund
        callable by owner(unocker address) only, before unlockdate time ends
    */
    function withdrawTokens()  public override{
       require(now <= unlockDate, "The fund access time is over");
       require(msg.sender == unlockAdd, "Access denied. Only creator can access");
       ERC20 token = ERC20(token);
  
       uint256 tokenBalance = token.balanceOf(address(this));
       // unlock address pulling fund
       token.transfer(unlockAdd, tokenBalance);
       emit  WithdrewTokens(token, msg.sender, tokenBalance);
    }

    /**
      retrive Uncaimed fund aftre timeout
      callable by creator
    */
    function retriveUncaimedTokens()  public override{
       require(now >= unlockDate, "The fund access time is not over");
       require(msg.sender == creator, "Access denied. Only creator can access");
       ERC20 token = ERC20(token);
       // check balance
       uint256 tokenBalance = token.balanceOf(address(this));
       // retrieve unclaimed funds after
       token.transfer(creator, tokenBalance);
       emit RetriveUncaimedTokens(token, msg.sender, tokenBalance);
    }

    /**
      Trustless token information

      @return creator - who created lock and provides fund
      @return owner - unlocker address who pull fund
      @return createdAt - creation time
      @return balance - balance of contract 
    */
    function info() public view override returns(address, address, uint256, uint256, uint256) {
        return (creator, unlockAdd, unlockDate, createdAt, address(this).balance);
    }

    /**
      swap eth againts token
      callable by 'creator'

      @param _ethAmount - eth amount
      @param _unlockDate - set timeout 
    */
    function swapEthForToken(uint _ethAmount, uint256 _unlockDate) external  override payable {
      unlockDate = _unlockDate;
      address[] memory path = getEthFortokenAddPath();
      uint amountOutMin = uniswapRouter.getAmountsOut(_ethAmount, path)[1];
      uniswapRouter.swapExactETHForTokens{value: msg.value}(amountOutMin, path, address(this), unlockDate);
    
    }

    /**
      swap token againts ether
      callable by 'creator'

      @param _tokenAmount - token amount
      @param _unlockDate - set timeout
    */
    function swapTokenForEth(uint _tokenAmount, uint256 _unlockDate) external override payable {
      unlockDate = _unlockDate;
      // configure path address
      address[] memory path = getTokenForEthPath();
      uint amountOutMin = uniswapRouter.getAmountsOut(_tokenAmount, path)[1];
      // transfer tokens
      ERC20(token).transferFrom(msg.sender, address(this), _tokenAmount);
      ERC20(token).approve(UNISWAP_V2_ROUTER, _tokenAmount);
      uniswapRouter.swapExactTokensForETH(_tokenAmount, amountOutMin, path, address(this), unlockDate);
    }

    /** 
      swap path for token againts eth

      @return - address array
    */
    function getEthFortokenAddPath() private view returns (address[] memory) {
      address[] memory path = new address[](2);
      path[0] = uniswapRouter.WETH();
      path[1] = token;

      return path;
    }

    /** 
      swap path for eth againts tokens

      @return - address array
    */
    function getTokenForEthPath() private view returns (address[] memory) {
      address[] memory path = new address[](2);
      path[0] = token;
      path[1] = uniswapRouter.WETH();

      return path;
    }
}
