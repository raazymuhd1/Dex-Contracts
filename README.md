 # Trading Bot Contract
    a contract that let user tobe able to perform trade operation on any token they wish.


 ## Important Terms   
 #### Slippage
  Slippage in crypto trading refers to the difference between the expected price of a trade and the actual price at which the trade is executed. It occurs when there is a change in the market price between the time a trader places an order and the time the order is filled.


 #### Slippage Tolerance  
   Slippage tolerance in crypto trading refers to the maximum percentage or amount of price movement that a trader is willing to accept when executing a trade. It accounts for the difference between the expected price of a trade and the actual price at which the trade is executed. 
  
   When a trader places an order, especially in a volatile market, the price can change between the time the order is placed and the time it is executed. Slippage can occur due to various factors, including market volatility, order size, and liquidity.

   For example, if a trader sets a slippage tolerance of 1% on a trade, and the price moves more than 1% from the expected price before the trade is executed, the trade will not go through. This helps protect traders from unexpected losses due to rapid price changes. 

   In summary, slippage tolerance is a risk management tool that allows traders to specify how much price movement they are willing to accept when executing trades.


 #### Liquidity Pool
  A pool of tokens pair, usually it has 2 pair of token that has an amount of each of them in the pool contract.


### A Refresher on how Proxy contract works
  Essentially a user interacting directly with the proxy contract instead of the implementation contract itself, See below example on how it works:
 - `User -> Tx -> Proxy Contract -> Implementation Contract`  

  When a developer trying to interact with an implementation contract, they can access it by passing an implementation contract addrss into a Proxy interface, that's because the `Proxy` contract will forwards all the functions call to the implementation contract, by trying to look the function the users trying to call, when those functions didn't exist in the `Proxy contract`, The `Proxy` contract will trigger a fallback function and from fallback function a `Proxy` forwarding the call to the implementation contract.