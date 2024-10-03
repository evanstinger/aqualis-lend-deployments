// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {stdJson} from "forge-std/StdJson.sol";
import {ScriptTools} from "dss-test/ScriptTools.sol";

import {AaveV3ConfigEngine} from "aave-helpers/v3-config-engine/AaveV3ConfigEngine.sol";
import {IAaveV3ConfigEngine} from "aave-helpers/v3-config-engine/IAaveV3ConfigEngine.sol";
import {IV3RateStrategyFactory} from "aave-helpers/v3-config-engine/IV3RateStrategyFactory.sol";
import {EngineFlags} from "aave-helpers/v3-config-engine/EngineFlags.sol";

contract AddAssets is Script {
    using stdJson for string;
    using ScriptTools for string;

    string config;
    string instanceId;
    string sceInstanceId;
    string deployedContracts;
    string sceDeployedContracts;

    AaveV3ConfigEngine configEngine;

    function run() external {
        instanceId = vm.envOr("INSTANCE_ID", string("primary"));
        sceInstanceId = string(abi.encodePacked(instanceId, "-sce"));
        vm.setEnv("FOUNDRY_ROOT_CHAINID", vm.toString(block.chainid));

        config = ScriptTools.readInput(instanceId);
        deployedContracts = ScriptTools.readOutput(instanceId);
        sceDeployedContracts = ScriptTools.readOutput(sceInstanceId);

        configEngine = AaveV3ConfigEngine(sceDeployedContracts.readAddress(".configEngine"));

        vm.startBroadcast();

        IAaveV3ConfigEngine.Listing[] memory listings = new IAaveV3ConfigEngine.Listing[](5);

        // WETH Listing
        listings[0] = createListing(
            config.readAddress(".nativeToken"),
            "WETH",
            config.readAddress(".nativeTokenOracle"),
            createDefaultRateStrategy(),
            80_00, // LTV
            82_00, // Liquidation Threshold
            5_00,  // Liquidation Bonus
            8_00, // Reserve Factor
            1_000_000, // Supply Cap
            500_000    // Borrow Cap
        );

        // WBTC Listing
        listings[1] = createListing(
            config.readAddress(".wbtcToken"),
            "WBTC",
            config.readAddress(".wbtcOracle"),
            createDefaultRateStrategy(),
            75_00, // LTV
            80_00, // Liquidation Threshold
            5_00,  // Liquidation Bonus
            8_00, // Reserve Factor
            20_000, // Supply Cap
            15_000  // Borrow Cap
        );

        // USDC Listing
        listings[2] = createListing(
            config.readAddress(".usdcToken"),
            "USDC",
            config.readAddress(".usdcOracle"),
            createStablecoinRateStrategy(),
            85_00, // LTV
            88_00, // Liquidation Threshold
            4_00,  // Liquidation Bonus
            8_00, // Reserve Factor
            500_000_000, // Supply Cap
            400_000_000  // Borrow Cap
        );

        // USDT Listing
        listings[3] = createListing(
            config.readAddress(".usdtToken"),
            "USDT",
            config.readAddress(".usdtOracle"),
            createStablecoinRateStrategy(),
            75_00, // LTV
            80_00, // Liquidation Threshold
            4_00,  // Liquidation Bonus
            8_00, // Reserve Factor
            500_000_000, // Supply Cap
            400_000_000  // Borrow Cap
        );

        // DAI Listing
        listings[4] = createListing(
            config.readAddress(".daiToken"),
            "DAI",
            config.readAddress(".daiOracle"),
            createStablecoinRateStrategy(),
            80_00, // LTV
            85_00, // Liquidation Threshold
            4_00,  // Liquidation Bonus
            8_00, // Reserve Factor
            300_000_000, // Supply Cap
            250_000_000  // Borrow Cap
        );

        IAaveV3ConfigEngine.PoolContext memory context = IAaveV3ConfigEngine.PoolContext({
            networkName: "Aqualis",
            networkAbbreviation: "AQL"
        });

        configEngine.listAssets(context, listings);

        vm.stopBroadcast();
    }

    function createListing(
        address asset,
        string memory symbol,
        address priceFeed,
        IV3RateStrategyFactory.RateStrategyParams memory rateStrategy,
        uint256 ltv,
        uint256 liquidationThreshold,
        uint256 liquidationBonus,
        uint256 reserveFactor,
        uint256 supplyCap,
        uint256 borrowCap
    ) internal pure returns (IAaveV3ConfigEngine.Listing memory) {
        return IAaveV3ConfigEngine.Listing({
            asset: asset,
            assetSymbol: symbol,
            priceFeed: priceFeed,
            rateStrategyParams: rateStrategy,
            enabledToBorrow: EngineFlags.ENABLED,
            stableRateModeEnabled: EngineFlags.DISABLED,
            borrowableInIsolation: EngineFlags.DISABLED,
            withSiloedBorrowing: EngineFlags.DISABLED,
            flashloanable: EngineFlags.ENABLED,
            ltv: ltv,
            liqThreshold: liquidationThreshold,
            liqBonus: liquidationBonus,
            reserveFactor: reserveFactor,
            supplyCap: supplyCap,
            borrowCap: borrowCap,
            debtCeiling: 0, // No debt ceiling
            liqProtocolFee: 10_00, // 10% protocol fee on liquidations
            eModeCategory: 0 // No E-mode category
        });
    }

    function createDefaultRateStrategy() internal pure returns (IV3RateStrategyFactory.RateStrategyParams memory) {
        return IV3RateStrategyFactory.RateStrategyParams({
            optimalUsageRatio: 80 * 1e25,
            baseVariableBorrowRate: 0,
            variableRateSlope1: 7 * 1e25,
            variableRateSlope2: 300 * 1e25,
            stableRateSlope1: 7 * 1e25,
            stableRateSlope2: 300 * 1e25,
            baseStableRateOffset: 1 * 1e25,
            stableRateExcessOffset: 8 * 1e25,
            optimalStableToTotalDebtRatio: 20 * 1e25
        });
    }

    function createStablecoinRateStrategy() internal pure returns (IV3RateStrategyFactory.RateStrategyParams memory) {
        return IV3RateStrategyFactory.RateStrategyParams({
            optimalUsageRatio: 90 * 1e25,
            baseVariableBorrowRate: 0,
            variableRateSlope1: 4 * 1e25,
            variableRateSlope2: 60 * 1e25,
            stableRateSlope1: 5 * 1e25,
            stableRateSlope2: 60 * 1e25,
            baseStableRateOffset: 1 * 1e25,
            stableRateExcessOffset: 8 * 1e25,
            optimalStableToTotalDebtRatio: 20 * 1e25
        });
    }
}