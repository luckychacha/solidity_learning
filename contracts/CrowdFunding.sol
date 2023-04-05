// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract CrowdFunding {
    address immutable owner;

    constructor() {
        owner = msg.sender;
    }

    struct Campaign {
        address payable receiver;
        uint numFunders;
        uint fundingGoal;
        uint totalAmount;
    }

    struct Funder {
        address addr;
        uint amount;
    }

    uint public numCampaigns;
    mapping(uint => Campaign) campaigns;

    Campaign[] public campaignArray;
    mapping(uint => Funder[]) funders;

    mapping(uint => mapping(address => bool)) campaignUserParticipated;

    event CampaignLog(uint campaignId, address receiver, uint goal);

    event BidLog(uint campaignId, address addr, uint amount);

    function newCampaign(
        address payable receiver,
        uint goal
    ) external isOwner returns (uint campaginID) {
        campaginID = numCampaigns++;
        Campaign storage c = campaigns[campaginID];
        c.receiver = receiver;
        c.fundingGoal = goal;

        campaignArray.push(c);
        emit CampaignLog(campaginID, receiver, goal);
    }

    modifier judgeParticipate(uint campaginID) {
        require(campaignUserParticipated[campaginID][msg.sender] == false);
        _;
    }

    modifier isOwner() {
        require(msg.sender == owner);
        _;
    }

    function bid(
        uint campaginID
    ) external payable judgeParticipate(campaginID) {
        Campaign storage c = campaigns[campaginID];

        c.totalAmount += msg.value;
        c.numFunders += 1;

        funders[campaginID].push(Funder({addr: msg.sender, amount: msg.value}));

        campaignUserParticipated[campaginID][msg.sender] = true;

        emit BidLog(campaginID, msg.sender, msg.value);
    }

    function withdraw(uint campaginID) external payable returns (bool reached) {
        Campaign storage c = campaigns[campaginID];

        if (c.totalAmount < c.fundingGoal) {
            return false;
        }
        uint amount = c.totalAmount;
        c.totalAmount = 0;
        c.receiver.transfer(amount);
        return true;
    }
}
