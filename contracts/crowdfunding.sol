// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract CrowdFunding{
    mapping(address=>uint) public contributors; // mapping the address of people with their amount
    address public manager; // manager wll have access to donate amount
    uint public minimumContributor; // minimum required amount   ;
    uint public deadline; 
    uint public target;
    uint public raisedAmount;
    uint public noOfContributors;

    constructor(uint _target, uint _deadline){ // automatically called function
        target=_target;
        deadline=block.timestamp+_deadline; 
        minimumContributor=1000 wei; // let say 1000 wei=1000 rupees
        manager=msg.sender;
    }

    function sendEth() public payable{ //contributors can send money on manager address via this function
        require(block.timestamp < deadline,"Deadline has passed");
        require(msg.value>=minimumContributor,"Minium contribution is not met");
        if(contributors[msg.sender]==0){
            noOfContributors++;
        }
        contributors[msg.sender]+=msg.value;
        raisedAmount+=msg.value;
    }
    function gcb() public view returns(uint){ // total contract balance function
        
        return address(this).balance;
    } 
    function refund() public{ // function which will send money back to the contributors
        require(block.timestamp>deadline && raisedAmount<target," You are not eligible for refund");
        require(contributors[msg.sender]>0);
        address payable user=payable(msg.sender);
        user.transfer(contributors[msg.sender]);
        contributors[msg.sender]=0;
    }
    struct Request{ // It is just like a class in other programming language and the main motive of this is to encapsulate all the data together for donation purpose
        string description;
        address payable recipient;
        uint value;
        bool completed;
        uint noOfvoters;
        mapping(address=>bool) voters;
    }
    mapping (uint=>Request) public requests; // This mapping is basically for Request with the index_number 
    uint public numrequest; // variable for index_number
  
    function createrequest(string memory _description,address payable _recipient,uint _value) public {
       require(msg.sender==manager,"only manager can call this function");
       Request storage newRequest = requests[numrequest];
       numrequest++;
       newRequest.description=_description;
       newRequest.recipient=_recipient;
       newRequest.value=_value;
       newRequest.completed=false;
       newRequest.noOfvoters=0;  
    }
    function voterequest(uint _requestno) public{
        require(contributors[msg.sender]>0,"you must be a contributor");
        Request storage thisrequest=requests[_requestno];
        require(thisrequest.voters[msg.sender]==false,"you have allready voted ");
        thisrequest.voters[msg.sender]==true;
        thisrequest.noOfvoters++;
        
    }

    function makepayment(uint _requestno) public {
        require(msg.sender==manager);
        require(raisedAmount>=target);
        Request storage thisrequest=requests[_requestno];
        require(thisrequest.completed==false,"The request has been completed");
        require(thisrequest.noOfvoters>noOfContributors/2,"Majority does not support");
        thisrequest.recipient.transfer(thisrequest.value);
        thisrequest.completed=true;
    }
}