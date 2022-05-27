import pytest
import brownie

Q128 = 2**128
MaxUint256 = 2**256-1

@pytest.fixture
def fullMath_contract(uniswapv3, accounts):
    yield uniswapv3.deploy({'from': accounts[0]})


def test_mulDiv(fullMath_contract):
    with brownie.reverts():
        fullMath_contract.mulDivTest(Q128, 5, 0)
    with brownie.reverts():
        fullMath_contract.mulDivTest(Q128, Q128, 0)
    with brownie.reverts():
        fullMath_contract.mulDivTest(Q128, Q128, 1)
    with brownie.reverts():
        fullMath_contract.mulDivTest(MaxUint256, MaxUint256, MaxUint256-1)
    assert fullMath_contract.mulDivTest(MaxUint256, MaxUint256, MaxUint256) == MaxUint256
    assert fullMath_contract.mulDivTest(Q128, 50*Q128//100, 150*Q128//100) == Q128//3
    # assert fullMath_contract.mulDivTest(Q128, 35*Q128, 8*Q128) == 4375 * Q128 // 1000
    # assert fullMath_contract.mulDivTest(Q128, 1000*Q128, 3000*Q128) == Q128 // 3
    with brownie.reverts():
        fullMath_contract.mulDivRoundingUpTest(Q128, 5, 0)
    with brownie.reverts():
        fullMath_contract.mulDivRoundingUpTest(Q128, Q128, 0)
    with brownie.reverts():
        fullMath_contract.mulDivRoundingUpTest(Q128, Q128, 1)
    with brownie.reverts():
        fullMath_contract.mulDivRoundingUpTest(MaxUint256, MaxUint256, MaxUint256-1)
    with brownie.reverts():
        fullMath_contract.mulDivRoundingUpTest(535006138814359, 432862656469423142931042426214547535783388063929571229938474969, 2)
    with brownie.reverts():
        fullMath_contract.mulDivRoundingUpTest(115792089237316195423570985008687907853269984659341747863450311749907997002549, 115792089237316195423570985008687907853269984659341747863450311749907997002550, 115792089237316195423570985008687907853269984653042931687443039491902864365164)
    assert fullMath_contract.mulDivRoundingUpTest(MaxUint256, MaxUint256, MaxUint256) == MaxUint256
    assert fullMath_contract.mulDivRoundingUpTest(Q128, 50*Q128//100, 150*Q128//100) == Q128//3+1
    # assert fullMath_contract.mulDivRoundingUpTest(Q128, 35*Q128, 8*Q128) == 4375*Q128//1000  
    # assert fullMath_contract.mulDivRoundingUpTest(Q128, 1000*Q128, 3000*Q128) == Q128//3+1 
    
    # random data test



