// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract UsdEthPairConverter {
    AggregatorV3Interface internal priceFeed;

    constructor() {
        priceFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306 // ETH/USD pair
        );
    }

    function getLatestPrice() private view returns (int) {
        (
            ,
            /* uint80 roundID */ int price /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/,
            ,
            ,

        ) = priceFeed.latestRoundData();
        return (price * 1e10);
    }

    function getAnUsdPriceInTermsOfEther() internal view returns (uint) {
        int EthUsdPair = getLatestPrice();
        return uint(1e36 / EthUsdPair);
    }
}
