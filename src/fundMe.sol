// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
// get funds from users
// withdraw funds
import "./PriceConvertor.sol";
// set a minimum funding value
//gas cost = 771531
//after using constant keyword in minusd gas=751617 beacuse it does not takes memory

error NotOwner();

contract fundMe {
    using PriceConvert for uint256;
    uint256 public constant minUSd = 5 * 10 ** 18;
    address[] public funders;
    mapping(address => uint256) public addToAmount;
    address private immutable owner;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        //set minimum amount of money
        require(
            msg.value.getConversion(s_priceFeed) >= minUSd,
            "Didn't send enough eth"
        );
        funders.push(msg.sender);
        addToAmount[msg.sender] += msg.value;
        //what is reverting
        //undo any action before and send remaining gas back
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function withDraw() public onlyOwner {
        for (
            uint256 fundersIndex = 0;
            fundersIndex < funders.length;
            fundersIndex++
        ) {
            address ind = funders[fundersIndex];
            addToAmount[ind] = 0;
        }
        funders = new address[](0);
        //withdraw the funds
        // transfer
        // payable(msg.sender).transfer(address(this).balance);
        // // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess,"Not Successfull");
        // call

        (bool callSuccessfull, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccessfull, "Call failed");
    }

    modifier onlyOwner() {
        // require(msg.sender==owner,"sender is not owner");
        if (msg.sender != owner) {
            revert NotOwner();
        }
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    function getAddressToAmountFunded(
        address fundingAddress
    ) external view returns (uint256) {
        return addToAmount[fundingAddress];
    }

    function getFunders(uint256 index) external view returns(address){
        return funders[index];
    }
    function getOwner()external view returns(address){
        return owner;
    }
}
