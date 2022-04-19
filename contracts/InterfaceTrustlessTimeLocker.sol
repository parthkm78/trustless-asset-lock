// SPDX-License-Identifier: MIT
pragma solidity 0.6.6;

import "./ERC20.sol";

/**
 * This is a Trustless time locker interface.
 */
interface TrustlessTimeLockerInterface{

    /**
        Unlock address pull fund(eth)
        callable by owner(unocker address) only, before unlockdate time ends
    */
    function withdraw() external;
    /**
        Unlock address pull fund(token)
        callable by owner(unocker address) only, before unlockdate time ends
    */
    function withdrawTokens()  external ;

    /**
      retrive Uncaimed fund aftre timeout
      callable by creator
    */
    function retriveUncaimedTokens()  external;

    /**
      Trustless locker information
    */
    function info() external view returns(address, address, uint256, uint256, uint256);

    // events
    event Received(address from, uint256 amount);
    event Withdrew(address to, uint256 amount);
    event WithdrewTokens(ERC20 tokenContract, address to, uint256 amount);
    event RetriveUncaimedTokens(ERC20 tokenContract, address to, uint256 amount);
}