// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {AggregatorV3Interface} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConvert {
    function getPrice(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        //address 0x694AA1769357215DE4FAC081bf1f309aDC325306

        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return uint256(answer * 1e10);
    }

    // function withdraw(){
    function getConversion(
        uint256 ethMount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsd = (ethPrice * ethMount) / 1e18;
        return ethAmountInUsd;
    }
}
