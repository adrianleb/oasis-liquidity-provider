pragma solidity >= 0.5.0;

import "ds-test/test.sol";
import "ds-token/token.sol";

import "./OasisLiquidityProvider.sol";
import { MatchingMarket } from "maker-otc/matching_market.sol";

contract OasisLiquidityProviderTest is DSTest {
    OasisLiquidityProvider olp;
    MatchingMarket otc;
    DSToken weth;
    DSToken dai;

    function setUp() public {
        olp = new OasisLiquidityProvider();
        otc = new MatchingMarket(uint64(now + 1 weeks));
        weth = new DSToken("WETH");
        dai = new DSToken("DAI");
    }

    function testBasic() public {
        weth.mint(address(this), 0.1*3 ether);
        dai.mint(address(this), 0.1*1440 ether);
        weth.approve(address(olp), uint(-1));
        dai.approve(address(olp), uint(-1));
        olp.linearOffers(
            MarketLike(address(otc)), TokenLike(address(weth)), TokenLike(address(dai)),
            500 ether, 10 ether, 0.1 ether, 3
        );
        uint pay_amt;
        ERC20 pay_gem;
        uint buy_amt;
        ERC20 buy_gem;

        (pay_amt, pay_gem, buy_amt, buy_gem) = otc.getOffer(1);
        assertEq(pay_amt, 0.1*490 ether);
        assertEq(address(pay_gem), address(dai));
        assertEq(buy_amt, 0.1*1 ether);
        assertEq(address(buy_gem), address(weth));

        (pay_amt, pay_gem, buy_amt, buy_gem) = otc.getOffer(2);
        assertEq(pay_amt, 0.1*480 ether);
        assertEq(address(pay_gem), address(dai));
        assertEq(buy_amt, 0.1*1 ether);
        assertEq(address(buy_gem), address(weth));

        (pay_amt, pay_gem, buy_amt, buy_gem) = otc.getOffer(3);
        assertEq(pay_amt, 0.1*470 ether);
        assertEq(address(pay_gem), address(dai));
        assertEq(buy_amt, 0.1*1 ether);
        assertEq(address(buy_gem), address(weth));

        (pay_amt, pay_gem, buy_amt, buy_gem) = otc.getOffer(4);
        assertEq(pay_amt, 0.1*1 ether);
        assertEq(address(pay_gem), address(weth));
        assertEq(buy_amt, 0.1*510 ether);
        assertEq(address(buy_gem), address(dai));

        (pay_amt, pay_gem, buy_amt, buy_gem) = otc.getOffer(5);
        assertEq(pay_amt, 0.1*1 ether);
        assertEq(address(pay_gem), address(weth));
        assertEq(buy_amt, 0.1*520 ether);
        assertEq(address(buy_gem), address(dai));

        (pay_amt, pay_gem, buy_amt, buy_gem) = otc.getOffer(6);
        assertEq(pay_amt, 0.1*1 ether);
        assertEq(address(pay_gem), address(weth));
        assertEq(buy_amt, 0.1*530 ether);
        assertEq(address(buy_gem), address(dai));

        assertEq(otc.getBestOffer(weth, dai), 4);
        assertEq(otc.getBestOffer(dai, weth), 1);
    }
}
