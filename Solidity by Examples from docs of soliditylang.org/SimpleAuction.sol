// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.22 <0.9.0;

contract SimpleAuction {
    
    address payable public beneficiary;
    uint public auctionEndTime;
    
    address public highestBidder;
    uint public highestBid;

    bool ended;
    
    mapping(address => uint) pendingReturns;

    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    constructor(
        uint _biddingTime,
        address payable _beneficiary
    ) {
        beneficiary = _beneficiary;
        auctionEndTime = block.timestamp + _biddingTime;
    }

    function bid() public payable {
        
        require(auctionEndTime >= block.timestamp);
        require(msg.value > highestBid, "Another bid is higher than yours");
        
        if (highestBid != 0) {
            pendingReturns[highestBidder] += highestBid;
        }
        
        highestBidder = msg.sender;
        highestBid = msg.value;
        
        emit HighestBidIncreased(msg.sender, msg.value);
    }

    function withdraw() public returns (bool) {
        
        uint amount = pendingReturns[msg.sender];
        
        if (amount > 0) {
            
            pendingReturns[msg.sender] = 0;
            
            if (!payable(msg.sender).send(amount)) {
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        
        return true;
    }

     function auctionEnd() public {
        
        require(block.timestamp >= auctionEndTime, "auction has been not ended");
        require(!ended, "auction is finished");
        
        ended = true;
        emit AuctionEnded(highestBidder, highestBid);
        
        beneficiary.transfer(highestBid);
    }
}