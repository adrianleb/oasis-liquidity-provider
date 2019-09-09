# Oasis Liquidity Provider

Smart contract for populating matching-market orderbook.

## linearOffers

```
function linearOffers(
    MarketLike otc, TokenLike baseToken, TokenLike quoteToken, uint midPrice, uint delta, uint baseAmount, uint count
) public
```

Adds `count` buy and `count` sell offers for trading `baseToken` and `quoteToken` to market `otc` by the following scheme:

- buy `count`: `baseAmount` at `midPrice` + `count` \* `delta`
- ...
- buy 1: `baseAmount` at `midPrice` + `delta`
- spread: midPrice
- sell 1: `baseAmount` at `midPrice` - `delta`
- ...
- sell `count`: `baseAmount` at `midPrice` - `count` \* `delta`

Takes funds from sender:
- `baseToken`: `baseAmount` \* `count`
- `quoteToken`: `baseAmount` \* `count` \* (`midPrice` - `delta` \* (`count`+1)/2)

The intention is that no new offers match when adding. It is up to the caller to ensure that.

## cancelMyOffers

```
function cancelMyOffers(MarketLike otc, TokenLike baseToken, TokenLike quoteToken) public
```

Cancels all offers created by the sender for trading `baseToken` and `quoteToken` to market `otc`.

Returns all funds to the sender.
