// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;
pragma abicoder v2;

import {UniswapV3Pool} from "../src/UniswapV3Pool.sol";
import {MockToken} from "../src/MockToken.sol";
import {Test, console} from "forge-std/Test.sol";
import {TickMath} from "../src/libraries/TickMath.sol";
import {UniswapV3Factory} from "../src/UniswapV3Factory.sol";

contract TestLiquidity is Test {
    function testSwapBeforeLiquidityProvided() public {
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

        // swap before liquidity provided
        UniswapV3Pool pool = UniswapV3Pool(poolAddress);
        int24 tick = 0; // tick0
        uint160 sqrtPriceX96 = TickMath.getSqrtRatioAtTick(tick);
        uint160 sqrtPriceX96Limit = sqrtPriceX96 - 1; // ensure sqrtPriceX96Limit < slot0Start.sqrtPriceX96

        // Initialize pool
        pool.initialize(sqrtPriceX96);
        pool.swap(address(this), true, 1, sqrtPriceX96Limit, "");
    }
}
