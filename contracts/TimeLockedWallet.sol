pragma solidity 0.6.6;

import "./ERC20.sol";
import '@uniswap/v2-periphery/contracts/UniswapV2Router02.sol';



contract TimeLockedWallet {

    address public creator;
    address public owner;
    uint256 public unlockDate;
    uint256 public createdAt;
     address internal constant UNISWAP_V2_ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
  IUniswapV2Router02 public uniswapRouter;
  address internal constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    constructor(
        address _creator,
        address _owner,
        uint256 _unlockDate
    ) public {
        creator = _creator;
        owner = _owner;
        unlockDate = _unlockDate;
        createdAt = now;
         uniswapRouter = IUniswapV2Router02(UNISWAP_V2_ROUTER);
    }

    // keep all the ether sent to this address
    receive() external payable { 
        emit Received(msg.sender, msg.value);
    }

    // callable by owner only, after specified time
    function withdraw() onlyOwner public {
       require(now >= unlockDate);
       //now send all the balance
       msg.sender.transfer(address(this).balance);
       emit Withdrew(msg.sender, address(this).balance);
    }

    // callable by owner only, after specified time, only for Tokens implementing ERC20
    function withdrawTokens(address _tokenContract) onlyOwner public {
       require(now >= unlockDate);
       ERC20 token = ERC20(_tokenContract);
       //now send all the token balance
       uint256 tokenBalance = token.balanceOf(address(this));
       token.transfer(owner, tokenBalance);
      emit  WithdrewTokens(_tokenContract, msg.sender, tokenBalance);
    }

    function info() public view returns(address, address, uint256, uint256, uint256) {
        return (creator, owner, unlockDate, createdAt, address(this).balance);
    }

    function swapEthForUSDC(uint ethAmount) external payable {
    uint deadline = block.timestamp + 150;
    address[] memory path = getEthForUSDCPath();
    uint amountOutMin = uniswapRouter.getAmountsOut(ethAmount, path)[1];
    uniswapRouter.swapExactETHForTokens{value: msg.value}(amountOutMin, path, msg.sender, deadline);
  }

  function swapUSDCForEth(uint tokenAmount) external payable {
    uint deadline = block.timestamp + 150;
    address[] memory path = getUSDCForEthPath();
    uint amountOutMin = uniswapRouter.getAmountsOut(tokenAmount, path)[1];
    IERC20(USDC).transferFrom(msg.sender, address(this), tokenAmount);
    IERC20(USDC).approve(UNISWAP_V2_ROUTER, tokenAmount);
    uniswapRouter.swapExactTokensForETH(tokenAmount, amountOutMin, path, msg.sender, deadline);
  }

  function getEthForUSDCPath() private view returns (address[] memory) {
    address[] memory path = new address[](2);
    path[0] = uniswapRouter.WETH();
    path[1] = USDC;

    return path;
  }

  function getUSDCForEthPath() private view returns (address[] memory) {
    address[] memory path = new address[](2);
    path[0] = USDC;
    path[1] = uniswapRouter.WETH();

    return path;
  }

    event Received(address from, uint256 amount);
    event Withdrew(address to, uint256 amount);
    event WithdrewTokens(address tokenContract, address to, uint256 amount);
}
