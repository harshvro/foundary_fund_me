// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
import {Script} from "lib/forge-std/src/Script.sol";
import {MockV3Aggregator} from "../test/mocks/mockV3Aggregator.sol";

contract HelperConfig is Script {
    //if we are on a local anvil , we deploy mocks
    //otherwise , grab the existing address from the live network
    NetworkConfig public activeNetworkConnfig;
    uint8 public constant DECIMALS = 8;
    int256 public constant initialPrice = 2000e8;

    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConnfig = getSepoliaEthConfig();
        } else {
            activeNetworkConnfig = getAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaconfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaconfig;
    }

    function getAnvilEthConfig() public returns (NetworkConfig memory) {

        if(activeNetworkConnfig.priceFeed!=address(0)){
            return activeNetworkConnfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            initialPrice
        );
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
        return anvilConfig;
    }
}
