//SPDX-License-Identifier: Unlicense
pragma solidity 0.6.6;

// import file
import "./TrustlessTimeLocker.sol";

/**
    This contract is factory contract which generate new trustless lock between two parties  
*/
contract TrustlessTimeLockerFactory {
    
    // map user address againts trustless locks
    mapping(address => address[]) wallets;

    // fetch all trustless locks of user
    function getWallets(address _user) 
        public
        view
        returns(address[] memory)
    {
        return wallets[_user];
    }

    /**
        Generate new trustless lock
    
        @param _unlockAdd The '_unlockAdd' is who will take fund - unlocker address
                term represent number of months
        @param _tokenAdd - This describe 'deployed tokenaddress' adaints 'eth' will be swapped 

        @return _wallet - return address of newy generated trustless lock
    */
    function newTrustlessTimeLocker(address _unlockAdd, address _tokenAdd)
        payable
        public
        returns(address _wallet)
    {
        // Create new wallet.
        address payable wallet = address(new TrustlessTimeLocker(msg.sender, _unlockAdd, _tokenAdd));
        
        // Add wallet to sender's wallets.
        wallets[msg.sender].push(wallet);

        // If owner is the same as sender then add wallet to sender's wallets too.
        if(msg.sender != _unlockAdd){
            wallets[_unlockAdd].push(wallet);
        }

        // Send ether from this transaction to the created contract.
        wallet.transfer(msg.value);

        // Emit event.
        Created(wallet, msg.sender, _unlockAdd, now, msg.value);
    }

    // Prevents accidental sending of ether to the factory
    receive() external payable{ 
        revert();
    }

    // event
    event Created(address wallet, address from, address to, uint256 createdAt, uint256 amount);
}
