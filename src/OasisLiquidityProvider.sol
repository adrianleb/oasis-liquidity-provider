pragma solidity >= 0.5.0;

contract TokenLike {
    function approve(address guy, uint wad) public returns (bool);
    function transferFrom(address src, address dst, uint wad) public returns (bool);
}
contract MarketLike {
    function offer(uint pay_amt, TokenLike pay_gem, uint buy_amt, TokenLike buy_gem, uint pos) public returns (uint);
}

contract OasisLiquidityProvider {
    uint constant ONE = 10 ** 18;

    constructor() public {
    }

    function linearOffers(
        MarketLike otc, TokenLike baseToken, TokenLike quoteToken, uint midPrice, uint delta, uint baseAmount, uint count
    ) public {
        require(baseToken.transferFrom(msg.sender, address(this), baseAmount * count), "cannot-fetch-base-token");
        require(quoteToken.transferFrom(msg.sender, address(this), baseAmount * count * (midPrice - delta * (count+1)/2) / ONE), "cannot-fetch-quote-token");
        baseToken.approve(address(otc), uint(-1));
        quoteToken.approve(address(otc), uint(-1));
        linearOffersPair(otc, baseToken, quoteToken, midPrice*baseAmount/ONE, -int(delta*baseAmount/ONE), baseAmount, 0, count);
        linearOffersPair(otc, quoteToken, baseToken, baseAmount, 0, midPrice*baseAmount/ONE, int(delta*baseAmount/ONE), count);
    }

    function linearOffersPair(
        MarketLike otc, TokenLike buyToken, TokenLike payToken, uint midPriceBuy, int deltaBuy, uint midPriceSell, int deltaSell, uint count
    ) internal {
        for (uint i = 1; i <= count; i += 1) {
            otc.offer(
                uint(int(midPriceBuy) + int(i) * deltaBuy), payToken,
                uint(int(midPriceSell) + int(i) * deltaSell), buyToken,
                0
            );
        }
    }
}
