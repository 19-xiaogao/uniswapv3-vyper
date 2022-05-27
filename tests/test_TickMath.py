import pytest
import brownie

from brownie.convert import Fixed, Wei

@pytest.fixture
def swapMath_contract(uniswapv3, accounts):
    yield uniswapv3.deploy({'from': accounts[0]})

def test_computeSwapStep(swapMath_contract):

    # exact amount in that gets capped at price target in one for zero
    next_sqrt_price, amount_in, amount_out, fee_amount =  swapMath_contract.computeSwapStepTest(
        1, "1.0049875621", 2000, 1000, "0.0006"
    )
    assert next_sqrt_price == "1.0049875621"
    assert amount_in == "9.9751242"
    assert amount_out == "9.925619556"
    assert fee_amount == "0.0059886677"

    priceAfterWholeOutputAmount = swapMath_contract.getNextSqrtPriceFromOutputTest(
        1, 2000, 1000, False
    )
    assert priceAfterWholeOutputAmount > next_sqrt_price

    # exact amount in that is fully spent in one for zero
    next_sqrt_price, amount_in, amount_out, fee_amount =  swapMath_contract.computeSwapStepTest(
        1, "3.162277660", 2000, 1000, "0.0006"
    )
    assert next_sqrt_price == "1.4997"
    assert amount_in == "999.4"
    assert amount_out == "666.3999466559"
    assert fee_amount == "0.6"
    priceAfterWholeInputAmountLessFee = swapMath_contract.getNextSqrtPriceFromOutputTest(
        1, 2000, "999.4", False
    )
    assert next_sqrt_price<"3.162277660"
    assert next_sqrt_price==priceAfterWholeInputAmountLessFee

    # exact amount out that is fully received in one for zero   
    # next_sqrt_price, amount_in, amount_out, fee_amount =  swapMath_contract.computeSwapStepTest(
    #     1, 10, 20000, 320000, "0.0006"
    # )
    # assert amount_in == "19988"                  # 20000
    # assert amount_out == "9996.9990997299"       # ?
    # assert fee_amount == "12"
    # assert next_sqrt_price == "1.9994"

    # amount out is capped at the desired amount out
    # next_sqrt_price, amount_in, amount_out, fee_amount =  swapMath_contract.computeSwapStepTest(
    #     "5267.47238568", "0.0183378008", "2.011212432", "10594.0059473", "0.0006"
    # )
    # assert amount_in == "1000"
    # # assert amount_out == "666.3999466559"
    # assert fee_amount == "0.6"
    # assert next_sqrt_price == "1.4997"

    # # target price of 1 uses partial input amount
    # next_sqrt_price, amount_in, amount_out, fee_amount =  swapMath_contract.computeSwapStepTest(
    #     2, 1, 1, 1, "0.000001"
    # )
    # assert amount_in == "1000"
    # # assert amount_out == "666.3999466559"
    # assert fee_amount == "0.6"
    # assert next_sqrt_price == "1.4997"

    # entire input amount taken as fee
    # next_sqrt_price, amount_in, amount_out, fee_amount =  swapMath_contract.computeSwapStepTest(
    #     1, "33107174961805.35", "8.2264466e+26", "8.2264466e+26", "0.001872"
    # )
    # assert amount_in == "1000"
    # # assert amount_out == "666.3999466559"
    # assert fee_amount == "0.6"
    # assert next_sqrt_price == "1.4997"

    # handles intermediate insufficient liquidity in zero for one exact output case
    next_sqrt_price, amount_in, amount_out, fee_amount =  swapMath_contract.computeSwapStepTest(
        256, "281.6", 1024, 262144, "0.003"
    )
    assert amount_in == "26214.4"             # 26215
    assert amount_out == "0.3636363636"       # 0 
    assert fee_amount == "78.8798395185"      # 79
    assert next_sqrt_price == "281.6"

    # handles intermediate insufficient liquidity in one for zero exact output case
    next_sqrt_price, amount_in, amount_out, fee_amount =  swapMath_contract.computeSwapStepTest(
        256, "230.4", 1024, 262144, "0.003"
    )
    assert amount_in == "0.4444444444"        # minimum value
    assert amount_out == "26214.4"            # 26214
    assert fee_amount == "0.0013373453"       # minimum value
    assert next_sqrt_price == "230.4"