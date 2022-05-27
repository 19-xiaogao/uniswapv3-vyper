# @version ^0.3.3

MAX_UINT128: constant(uint128) = 2**128 - 1
MAX_UINT64: constant(uint64) = 2**64 - 1
MAX_UINT32: constant(uint32) = 2**32 - 1
MAX_UINT16: constant(uint32) = 2**16 - 1
MAX_UINT8: constant(uint8) = 2**8 - 1

Q128: constant(uint256) = 2**128
Q96: constant(uint256) = 2**96

#### SqrtPriceMath ####
@internal
@pure
def getNextSqrtPriceFromAmount0(
    sqrtprice: decimal,
    liquidity: decimal,
    amount: decimal
) -> decimal:

    result: decimal = liquidity * sqrtprice
    d:decimal = liquidity + amount * sqrtprice

    return result / d

@internal
@pure
def getNextSqrtPriceFromAmount1(
    sqrtprice: decimal,
    liquidity: decimal,
    amount: decimal
    ) -> decimal:

    result: decimal = amount / liquidity
    return result + sqrtprice

@internal
@view
def getNextSqrtPriceFromInput(
    sqrtprice: decimal,
    liquidity: decimal,
    amount: decimal,
    zero_or_one: bool
) -> decimal:
    assert sqrtprice > 0.0
    assert liquidity > 0.0

    if zero_or_one:
        return self.getNextSqrtPriceFromAmount0(sqrtprice, liquidity, amount)
    else:
        return self.getNextSqrtPriceFromAmount1(sqrtprice, liquidity, amount)

@internal
@view
def getNextSqrtPriceFromOutput(
    sqrtprice: decimal,
    liquidity: decimal,
    amount: decimal,
    zero_or_one: bool
) -> decimal:

    assert sqrtprice > 0.0
    assert liquidity > 0.0

    if zero_or_one:
        return self.getNextSqrtPriceFromAmount0(sqrtprice,  liquidity, amount)
    else:
        return self.getNextSqrtPriceFromAmount1(sqrtprice,  liquidity, amount)

@internal
@pure
def getAmount0Delta(
    sqrt_ratio1: decimal,
    sqrt_ratio2: decimal,
    liquidity: decimal,
) -> decimal:
#  liquidity * (sqrt(upper) - sqrt(lower)) / (sqrt(upper) * sqrt(lower))

    result: decimal = 0.0 
    if sqrt_ratio1>sqrt_ratio2:
        result = sqrt_ratio1 - sqrt_ratio2
    else:
        result = sqrt_ratio2 - sqrt_ratio1

    return liquidity * result / sqrt_ratio1 / sqrt_ratio2

@internal
@pure
def getAmount1Delta(
    sqrt_ratio1: decimal,
    sqrt_ratio2: decimal,
    liquidity: decimal,
) -> decimal:
#  liquidity * (sqrt(upper) - sqrt(lower))
    result: decimal = 0.0
    if sqrt_ratio1>sqrt_ratio2:
        result = sqrt_ratio1 - sqrt_ratio2
    else:
        result = sqrt_ratio2 - sqrt_ratio1
    return liquidity * result

#### LiguidityMath ####
@internal
@pure
def addDelta(x: uint256, d: int256) -> uint256:
    """
    @notice Add a signed liquidity delta to liquidity and revert if it overflows or underflows
    @param x The liquidity before change
    @param y The delta by which liquidity should be changed
    @return z The liquidity delta
    """

    if d < 0:
        return x - convert(abs(d), uint256)
    else:
        return x + convert(abs(d), uint256)


#### UnsafeMath ####
@internal
@pure
def divRoundingUp(a: uint256, denominator: uint256) -> uint256:
    tmp: uint256 = a % denominator
    result: uint256 = a/denominator

    if tmp > 0:
        return result+1
    return result

#### FullMath ####
@internal
@pure
def mulDiv(a: uint256, b: uint256, denominator: uint256) -> uint256:
    """
    @notice Calculates floor(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
    @param a The multiplicand
    @param b The multiplier
    @param denominator The divisor
    @return result The 256-bit result
    @dev Credit to Remco Bloemen under MIT license https://xn--2-umb.com/21/muldiv
    """

    if a == denominator:
        return b
    elif b == denominator:
        return a

    return a * b / denominator

@internal
@view
def mulDivRoundingUp(a: uint256, b: uint256, denominator: uint256) -> uint256:
    """
    @notice Calculates ceil(a×b÷denominator) with full precision. Throws if result overflows a uint256 or denominator == 0
    @param a The multiplicand
    @param b The multiplier
    @param denominator The divisor
    @return result The 256-bit result
    """

    if a == denominator:
        return b
    elif b == denominator:
        return a

    result: uint256 = a*b
    tmp: uint256 = result % denominator
    result = result/denominator

    if tmp > 0:
        assert result < MAX_UINT256
        result += 1

    return result

#### BitMath ####
@internal
@pure
def mostSignificantBit(x: uint256) -> uint8:
    """ 
    @notice Returns the index of the most significant bit of the number, where the least significant bit is at index 0 and the most significant bit is at index 255
    @dev The function satisfies the property:x >= 2**mostSignificantBit(x) and x < 2**(mostSignificantBit(x)+1)
    @param x the value for which to compute the most significant bit, must be greater than 0
    @return r the index of the most significant bit
    """

    assert x > 0
    r: uint8 = 0
    t: uint256 = x

    if t >= 2**128:
        t = shift(t,-128)
        r += 128
    if t >= 2**64:
        t = shift(t,-64)
        r += 64
    if t >= 2**32:
        t = shift(t,-32)
        r += 32
    if t >= 2**16:
        t = shift(t,-16)
        r += 16 
    if t >= 2**8:
        t = shift(t,-8)
        r += 8
    if t >= 2**4:
        t = shift(t,-4)
        r += 4
    if t >= 4:
        t = shift(t,-2)
        r += 2 
    if t >= 2:
        r += 1 
    return r

@internal
@pure
def leastSignificantBit(x: uint256) -> uint8:
    """ 
    @notice Returns the index of the least significant bit of the number, where the least significant bit is at index 0 and the most significant bit is at index 255
    @dev The function satisfies the property: (x & 2**leastSignificantBit(x)) != 0 and (x & (2**(leastSignificantBit(x)) - 1)) == 0)
    @param x the value for which to compute the least significant bit, must be greater than 0
    @return r the index of the least significant bit
    """

    assert x > 0
    r: uint8 = 255
    t: uint256 = x

    if bitwise_and(t,convert(MAX_UINT128, uint256)) > 0:
        r -= 128
    else:
        t = shift(t, -128)
    if bitwise_and(t,convert(MAX_UINT64, uint256)) > 0:
        r -= 64
    else:
        t = shift(t, -64)
    if bitwise_and(t,convert(MAX_UINT32, uint256)) > 0:
        r -= 32
    else:
        t = shift(t, -32)
    if bitwise_and(t,convert(MAX_UINT16, uint256)) > 0:
        r -= 16
    else:
        t = shift(t, -16)
    if bitwise_and(t,convert(MAX_UINT8, uint256)) > 0:
        r -= 8
    else:
        t = shift(t, -8)
    if bitwise_and(t, 15) > 0:
        r -= 4
    else:
        t = shift(t, -4)
    if bitwise_and(t, 3) > 0:
        r -= 2
    else:
        t = shift(t, -2)
    if bitwise_and(t, 1) > 0:
        r -= 1
    
    return r


#### SwapMath ####
@internal
@view
def computeSwapStep(
    current_sqrt_price: decimal,
    target_sqrt_price: decimal,
    liquidity: decimal,
    amount_remaining: decimal,
    fee_pips: decimal
) -> (decimal, decimal, decimal, decimal):
    zero_for_one: bool = current_sqrt_price >= target_sqrt_price
    is_enough: bool = amount_remaining >= 0.0

    next_sqrt_price: decimal = 0.0
    amount_in: decimal = 0.0
    amount_out: decimal = 0.0

    if is_enough:
        amount_remaining_less_fee: decimal = amount_remaining * (1.0-fee_pips)

        if zero_for_one:
            amount_in = self.getAmount0Delta(target_sqrt_price, current_sqrt_price, liquidity)
        else:
            amount_in = self.getAmount1Delta(current_sqrt_price, target_sqrt_price, liquidity)

        if amount_remaining_less_fee >= amount_in:
            next_sqrt_price = target_sqrt_price
        else:
            next_sqrt_price = self.getNextSqrtPriceFromInput(
                current_sqrt_price,
                liquidity,
                amount_remaining_less_fee,
                zero_for_one
            )
    else:
        if zero_for_one:
            amount_out = self.getAmount1Delta(target_sqrt_price, current_sqrt_price, liquidity)
        else:
            amount_out = self.getAmount0Delta(target_sqrt_price, current_sqrt_price, liquidity)

        if -amount_remaining >= amount_out:
            next_sqrt_price = target_sqrt_price
        else:
            next_sqrt_price = self.getNextSqrtPriceFromOutput(
                current_sqrt_price,
                liquidity,
                -amount_remaining,
                zero_for_one
            )
    
    is_exceed_max: bool = next_sqrt_price == target_sqrt_price

    # get the input/output amounts
    if zero_for_one:
        if not (is_exceed_max and is_enough):
            amount_in = self.getAmount0Delta(current_sqrt_price, next_sqrt_price, liquidity)
        if not (is_exceed_max and (not is_enough)):
            amount_out = self.getAmount1Delta(current_sqrt_price, next_sqrt_price, liquidity)
    else:
        if not (is_exceed_max and is_enough):
            amount_in = self.getAmount1Delta(current_sqrt_price, next_sqrt_price, liquidity)
        if not (is_exceed_max and (not is_enough)):
            amount_out = self.getAmount0Delta(current_sqrt_price, next_sqrt_price, liquidity)


    # cap the output amount to not exceed the remaining output amount
    if (not is_enough) and (amount_out > -amount_remaining):
        amount_out = -amount_remaining

    fee_amount: decimal = 0.0
    if is_enough and (next_sqrt_price != target_sqrt_price):
        fee_amount = amount_remaining - amount_in
    else:
        fee_amount = amount_in * fee_pips / (1.0 - fee_pips)

    return (next_sqrt_price, amount_in, amount_out, fee_amount)

#### TickMath ####
# MAX_DECIMAL (2**127 - 1)
# MIN_DECIMAL (-2**127)
# 1.0001 ^ (-887272) - 2^(-128)
# 1.0001 ^ (-887272) - 2^(-128)
MIN_TICK: constant(int24) = -887272
MAX_TICK: constant(int24) = 887272

@internal
@pure
def getSqrtRatioAtTick(tick: int24) -> decimal:
    # Calculates sqrt(1.0001^tick)
    result: decimal = 1.0

    if tick == 0:
        return result
    elif tick > 0:
        for i in range(MAX_TICK):
            result = result * 1.0001
            if tick < i:
                return result
    else:
        for i in range(MAX_TICK):
            result = result / 1.0001
            if -tick < i:
                return result
    return 1.0

################# Test Area #################
#### BitMath ####
@external
@view
def mostSignificantBitTest(x: uint256) -> uint8:
    return self.mostSignificantBit(x)

@external
@view
def getGasCostOfMostSignificantBit(x: uint256) -> uint256:
    gasBefore: uint256 = msg.gas
    self.mostSignificantBit(x)
    gasAfter: uint256 = msg.gas
    return gasBefore - gasAfter

@external
@view
def leastSignificantBitTest(x: uint256) -> uint8:
    return self.leastSignificantBit(x)

@external
@view
def getGasCostOfleastSignificantBit(x: uint256) -> uint256:
    gasBefore: uint256 = msg.gas
    self.leastSignificantBit(x)
    gasAfter: uint256 = msg.gas

    return gasBefore - gasAfter

@external
@view
def mulDivTest(a: uint256, b: uint256, denominator: uint256) -> uint256:
    return self.mulDiv(a, b, denominator)

@external
@view
def mulDivRoundingUpTest(a: uint256, b: uint256, denominator: uint256) -> uint256:
    return self.mulDivRoundingUp(a, b, denominator)

@external
@view
def getNextSqrtPriceFromInputTest(
    sqrt_price: decimal,
    liquidity: decimal,
    amount: decimal,
    zero_or_one: bool
) -> decimal:
    return self.getNextSqrtPriceFromInput(
        sqrt_price, 
        liquidity,
        amount,
        zero_or_one
        )

@external
@view
def getNextSqrtPriceFromOutputTest(
    sqrt_price: decimal,
    liquidity: decimal,
    amount: decimal,
    zero_or_one: bool
) -> decimal:
    return self.getNextSqrtPriceFromOutput(
        sqrt_price, 
        liquidity,
        amount,
        zero_or_one
        )

@external
@view
def getAmount0DeltaTest(
    sqrt_ratio1: decimal,
    sqrt_ratio2: decimal,
    liquidity: decimal,
) -> decimal:
    return self.getAmount0Delta(sqrt_ratio1, sqrt_ratio2, liquidity)

@external
@view
def getAmount1DeltaTest(
    sqrt_ratio1: decimal,
    sqrt_ratio2: decimal,
    liquidity: decimal,
) -> decimal:
    return self.getAmount1Delta(sqrt_ratio1, sqrt_ratio2, liquidity)

@external
@view
def computeSwapStepTest(
    current_sqrt_price: decimal,
    target_sqrt_price: decimal,
    liquidity: decimal,
    amount_remaining: decimal,
    fee_pips: decimal
) -> (decimal, decimal, decimal, decimal):

    t1: decimal = 0.0
    t2: decimal = 0.0 
    t3: decimal = 0.0
    t4: decimal = 0.0

    t1, t2, t3, t4 = self.computeSwapStep(
        current_sqrt_price,
        target_sqrt_price,
        liquidity,
        amount_remaining,
        fee_pips
    )

    return (t1,t2,t3,t4)