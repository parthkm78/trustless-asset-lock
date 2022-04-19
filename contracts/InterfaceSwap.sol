// SPDX-License-Identifier: MIT
pragma solidity 0.6.6;


/**
 * This is a swap interface.
 */
interface SwapInterface{

    /**
      swap eth againts token
      callable by 'creator'
    */
    function swapEthForToken(uint _ethAmount, uint256 _unlockDate) external payable;

    /**
      swap token againts ether
      callable by 'creator'
    */
    function swapTokenForEth(uint _tokenAmount, uint256 _unlockDate) external payable;
}