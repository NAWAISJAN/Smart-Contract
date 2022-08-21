// SPDX-License-Identifier: GPL-3.0


pragma solidity ^0.8;

contract Auction{

    address payable public autioneer;
    uint public startBlock; // start time 
    uint public endBlock; // end time

    enum Auc_State {Started,Running, Ended , Cancelled}
    Auc_State public auctionState;

    uint public highestBid;
    uint public higherstPayableBid;
    uint public bidInc;

    address payable public highestBidder;

    mapping(address => uint) public bids;


    constructor(){

        autioneer = payable(msg.sender);
        auctionState = Auc_State.Running;
        startBlock = block.number;
        endBlock = startBlock + 240;
        bidInc = 1 ether;

    }


    modifier notOwner()  {
        require(msg.sender != autioneer,"Owner cannot Bid");
        _;

    }
    modifier Owner()  {
        require(msg.sender == autioneer,"Owner cannot Bid");
        _;

    }
    modifier started()  {
        require(block.number > startBlock);
        _;

    }
    modifier beforeEnding()  {
        require(block.number < endBlock);
        _;

    }

    function cancelAuct() public Owner{

        auctionState = Auc_State.Cancelled;

    }
    function endAuc() public Owner{

        auctionState = Auc_State.Ended;

    }

    function min(uint a, uint b) pure private returns (uint)
    {
        if(a<=b)
        return a;
        else
        return b;

    }

    function bid() payable public notOwner started beforeEnding{

        require(auctionState == Auc_State.Running);
        require(msg.value >= 1 ether);

        uint currentBid = bids[msg.sender] + msg.value;

        require(currentBid > higherstPayableBid);
         bids[msg.sender] = currentBid;

         if(currentBid < bids[highestBidder]){
             higherstPayableBid = min(currentBid + bidInc ,bids[highestBidder]); 
         }
         else{
             higherstPayableBid = min(currentBid,bids[highestBidder]+bidInc);
             highestBidder  = payable(msg.sender);

         }





    }

    function finalizeAuc() public {
        require(auctionState == Auc_State.Cancelled || auctionState == Auc_State.Ended ||block.number>endBlock);
        require(msg.sender == autioneer || bids[msg.sender]>0);

        address payable person ;
        uint value;

        if(auctionState == Auc_State.Cancelled)
        {
            person = payable(msg.sender);
            value = bids[msg.sender];
        }
        else{
            if(msg.sender == autioneer)
            {
                person = autioneer;
                value = higherstPayableBid;
            }
            else
            {
                if(msg.sender == highestBidder)
                {
                    person = highestBidder;
                    value = bids[highestBidder]-higherstPayableBid;
                }
                else
                {
                    person = payable(msg.sender);
                    value = bids[msg.sender];

                }
            }
        }
        bids[msg.sender]=0;
        person.transfer(value);
    }






}
