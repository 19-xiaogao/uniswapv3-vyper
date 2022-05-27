import pytest
import brownie
from brownie.convert import Fixed

import logging
logging.basicConfig(level=logging.DEBUG)

# decimal_max = Fixed("18707220957835557353007165858768422651595.9365500927")
decimal_max = Fixed("187072209578355573530071658587595")
deciaml_min = Fixed("-18707220957835557353007165858768422651595.9365500928")

@pytest.fixture
def sqrtPriceMath_contract(uniswapv3, accounts):
    yield uniswapv3.deploy({'from': accounts[0]})

def test_getNextSqrtPriceFromInput(sqrtPriceMath_contract):
    # fails if price is zero
    with brownie.reverts():
         sqrtPriceMath_contract.getNextSqrtPriceFromInputTest(
             0,0,
             100, False
         )
    
    # fails if liquidity is zero
    with brownie.reverts():
         sqrtPriceMath_contract.getNextSqrtPriceFromInputTest(
             1,0,
             100, False
         )

    # returns input price if amount in is zero and zeroForOne = true
    assert sqrtPriceMath_contract.getNextSqrtPriceFromInputTest(
             1,1,
             0, True
         ) == 1

    # returns input price if amount in is zero and zeroForOne = false
    assert sqrtPriceMath_contract.getNextSqrtPriceFromInputTest(
             1,1,
             0, False
         ) == 1

    # returns the minimum price for large inputs
    assert sqrtPriceMath_contract.getNextSqrtPriceFromInputTest(
            1,1,
            2**96-1, True
        ) == 0

    # input amount of 1/10 token0
    assert sqrtPriceMath_contract.getNextSqrtPriceFromInputTest(
            1,10,
            1, True
        ) == "0.909090909"

    # input amount of 1/10 token1
    assert sqrtPriceMath_contract.getNextSqrtPriceFromInputTest(
            1,10,
            1, False
        ) == "1.1"

def test_getNextSqrtPriceFromOutput(sqrtPriceMath_contract):

    # fails if price is zero
    with brownie.reverts():
         sqrtPriceMath_contract.getNextSqrtPriceFromOutputTest(
             0,1,
             100, False
         )
    
    # fails if liquidity is zero
    with brownie.reverts():
         sqrtPriceMath_contract.getNextSqrtPriceFromOutputTest(
             1,0,
             100, False
         )

    # returns input price if amount in is zero 
    assert sqrtPriceMath_contract.getNextSqrtPriceFromOutputTest(
        1,1024,
        0, False
    ) == 1
    assert sqrtPriceMath_contract.getNextSqrtPriceFromOutputTest(
        1,1024,
        0, True
    ) == 1

    # output amount of 1/10 token 
    assert sqrtPriceMath_contract.getNextSqrtPriceFromOutputTest(
        1,1000,
        100, True
    ) == "0.909090909"
    assert sqrtPriceMath_contract.getNextSqrtPriceFromOutputTest(
        1,1000,
        100, False
    ) == "1.1"

    assert sqrtPriceMath_contract.getNextSqrtPriceFromOutputTest(
        10,10,
        1, True
    ) == "5"
   
def test_getAmount0Delta(sqrtPriceMath_contract):
    # returns 0 if liquidity is 0
    assert sqrtPriceMath_contract.getAmount0DeltaTest(
        1,1000,0
    ) == 0

    # returns 0 if prices are equal
    assert sqrtPriceMath_contract.getAmount0DeltaTest(
        1000,1000,1000000
    ) == 0

    # returns 1/10 liquidity if prices: 1 -> 1.21
    assert sqrtPriceMath_contract.getAmount0DeltaTest(
        "1.1", 1, 10
    ) == "0.909090909"

    assert sqrtPriceMath_contract.getAmount0DeltaTest(
        5, 10, 10
    ) == 1

def test_getAmount1Delta(sqrtPriceMath_contract):
    # returns 0 if liquidity is 0
    assert sqrtPriceMath_contract.getAmount1DeltaTest(
        1,1000,0
    ) == 0

    # returns 0 if prices are equal
    assert sqrtPriceMath_contract.getAmount1DeltaTest(
        1000,1000,1000000
    ) == 0

    # returns 1/10 liquidity if prices: 1 -> 1.21
    assert sqrtPriceMath_contract.getAmount1DeltaTest(
        "1.1", 1, 10
    ) == 1

    assert sqrtPriceMath_contract.getAmount1DeltaTest(
        5, 10, 1
    ) == 5