# ETHGlobal-New-York

## Frontend:
### Trade Widget:
- Stock selector with stock list
- Perpetual On/Off
- Direction (Long / Short)
- You pay field
- You receive field
- Buy button
- Wallet connect button
### Position list:
- active positions:
- stock
- amount
- current value
- close position button
- direction long/short

### Advanced Stock list (v2):
tradable stocks:
stock
amount
current value?
### Stock trade page (v2):


## Contracts

### Multi LSP:
- string name
- map period_ids -> lsp-pair address
- struct Period
- (wrapper functions to get lsp-pair information)
- start_period()
- create uniswapv3 pool
- long/short
- long/usdc
- short/usdc
- add pool liquidity
- long/short pool
- create lsppair
- resolve_period()
- by how much percent did the stock change?
- mock_resolve_period()
- mock_start_period()
### Rolling Pool:
- perpetual tokens
### Api Contract
- map stock_id -> multi lsp address
- get_stock_names returns string[]
- register_stock(name, leverage…)
- get_price(stock_id, is_long, is_perpetual, leverage)
- long(stock_id, is_long, is_perpetual, leverage, amount)
- mint lsp
- sell opposite side on uniswap
- sell(stock_id, is_long, leverage, period_id, amount)
- redeem(stock_id, leverage, period_id, amount)
- period_id MAX_INT = perpetual
- demo function
- start new period
- end period and resolve price
- roll over pool



### Leveraged Trades (v2)

### Perpetual Shorts (v2)
