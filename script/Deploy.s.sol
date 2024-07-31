// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;

import {Script, console} from "forge-std/Script.sol";
import {MockToken} from "../src/MockToken.sol";
import {UniswapV3Factory} from "../src/UniswapV3Factory.sol";
import {UniswapV3Pool} from "../src/UniswapV3Pool.sol";
import {TickMath} from "../src/libraries/TickMath.sol";

contract Deploy is Script {
    address recipient = makeAddr("recipient");

    function run() public {
        // Deploy two ERC20 tokens
        MockToken mockUsdt = new MockToken("USDT Tether", "USDT");
        MockToken mockDai = new MockToken("Dai Stablecoin", "DAI");

        console.log("Deployed MockToken USDT at:", address(mockUsdt));
        console.log("Deployed MockToken DAI at:", address(mockDai));

        // Deploy UniswapV3Factory
        UniswapV3Factory factoryV3 = new UniswapV3Factory();
        console.log("Deployed UniswapV3Factory at:", address(factoryV3));

        // Create pool using 2 tokens
        factoryV3.createPool(address(mockUsdt), address(mockDai), 500);
        console.log("Created pool with USDT and DAI");
        address poolAddress = factoryV3.getPool(address(mockUsdt), address(mockDai), 500);
        console.log("Pool address:", poolAddress);

        // Initialize pool
        UniswapV3Pool pool = UniswapV3Pool(poolAddress);
        int24 tick = 0; // tick0
        uint160 sqrtPriceX96 = TickMath.getSqrtRatioAtTick(tick);
        pool.initialize(sqrtPriceX96);

        // Calculate price
        uint256 price = uint256(sqrtPriceX96) * uint256(sqrtPriceX96) / 2 ** 192;
        console.log("Price:", price);

        // Log tick and sqrtPriceX96 separately
        console.log("Initialized pool with tick:", tick);
        console.log("Initialized pool with sqrtPriceX96:", uint256(sqrtPriceX96));

        // mint position :
        //1. Both ticks are below the current tick
        mockUsdt.approve(address(pool), 5000 * 10 ** 18);
        mockDai.approve(address(pool), 5000 * 10 ** 18);

        // creation of positions -> call mint

        // mint with both ticks below the current tick (below 0?)
        pool.mint(address(this), -200, -100, 200, "XXX");

        // mint with the lower tick below tick 0 and the upper tick above
        pool.mint(address(this), 100, 100, 200, "XXX");

        //both ticks are above the current tick
    }
}
