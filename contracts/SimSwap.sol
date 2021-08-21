//SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "./SimToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract SimSwap is Ownable{

    mapping(bytes32 => address) public pairHashPriceFeed;
    mapping(bytes32 => uint8) public pairHashPriceFeedDp;

    event pairChanged(address token0, address token1, address priceFeed, uint8 priceFeedDp);

    function setPairPriceFeed(address token0, address token1, address priceFeed, uint8 priceFeedDp) external onlyOwner{
        bytes32 pairHash = keccak256(abi.encodePacked(token0, token1));
        pairHashPriceFeed[pairHash] = priceFeed;
        pairHashPriceFeedDp[pairHash] = priceFeedDp;
    }

    function swap(address tokenIn_, address tokenOut_, uint amountIn, uint minAmountOut) external{
        bytes32 pairHash;
        address pairHashAddress;
        uint8 pairHashDp;
        
        SimToken tokenIn = SimToken(tokenIn_);
        SimToken tokenOut = SimToken(tokenOut_);

        pairHash = keccak256(abi.encodePacked(tokenIn, tokenOut));

        pairHashAddress = pairHashPriceFeed[pairHash];
        pairHashDp = pairHashPriceFeedDp[pairHash];

        if (pairHashAddress != address(0)){

            tokenIn.burn(msg.sender,amountIn);

            uint rawPrice = uint(getRawPrice(pairHash));
            
            uint mintAmount = rawPrice*amountIn/(10**pairHashDp);

            tokenOut.mint(msg.sender,mintAmount);

            require(mintAmount > minAmountOut, "SimSwap : Amount Out Is Not High Enough");

        }

        else{
            pairHash = keccak256(abi.encodePacked(tokenOut, tokenIn));
            pairHashAddress = pairHashPriceFeed[pairHash];

            pairHashDp = pairHashPriceFeedDp[pairHash];

            if (pairHashAddress != address(0)){

                tokenIn.burn(msg.sender,amountIn);

                uint rawPrice = uint(getRawPrice(pairHash));

                uint mintAmount = (10**pairHashDp)*amountIn/rawPrice;

                tokenOut.mint(msg.sender,mintAmount);

                require(mintAmount > minAmountOut, "SimSwap : Amount Out Is Not High Enough");

            }

            else{
                revert("SimSwap : Pair Does Not Exist");
            }

        }

    }

    function getRawPrice(bytes32 pairHash) public view returns (int) {

        address priceFeedAddress = pairHashPriceFeed[pairHash];

        require(priceFeedAddress != address(0), "SimSwap : getRawPrice : Price Feed Not Found");

        AggregatorV3Interface priceFeed = AggregatorV3Interface(priceFeedAddress);
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return price;

    }

}