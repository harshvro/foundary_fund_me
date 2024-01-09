// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "lib/forge-std/src/Script.sol";
import {fundMe} from "../src/fundMe.sol";
import {HelperConfig} from "../script/HelperConfig.s.sol";
contract DeployFundMe is Script {
    function run() external returns(fundMe) {
        HelperConfig helperconfig  = new HelperConfig();
        address ethPriceFeed = helperconfig.activeNetworkConnfig();
        vm.startBroadcast();
        fundMe fundme = new fundMe(ethPriceFeed);

        vm.stopBroadcast();
        return fundme;
    }
}
