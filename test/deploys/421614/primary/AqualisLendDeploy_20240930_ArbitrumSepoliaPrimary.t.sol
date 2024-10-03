// SPDX-License-Identifier: AGPL-3.0
pragma solidity ^0.8.0;

import "../../../SparkDeployBase.t.sol";

contract AqualisLendDeploy_20240930_ArbitrumSepoliaPrimaryTest is SparkDeployBaseTest {
    
    constructor() {
        rpcUrl     = getChain("arbitrum_sepolia").rpcUrl;
        forkBlock  = 29817464;
        instanceId = "primary";
    }

}
