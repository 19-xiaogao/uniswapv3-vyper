import pytest
import brownie

@pytest.fixture
def bitMath_contract(uniswapv3, accounts):
    yield uniswapv3.deploy({'from': accounts[0]})

def test_mostSignificantBit(bitMath_contract):
    with brownie.reverts():
        bitMath_contract.mostSignificantBitTest(0)

    assert bitMath_contract.mostSignificantBitTest(1) == 0
    assert bitMath_contract.mostSignificantBitTest(2) == 1
    for i in range(255):
        assert bitMath_contract.mostSignificantBitTest(2**i) == i

    assert bitMath_contract.mostSignificantBitTest(2**256-1) == 255
    assert bitMath_contract.getGasCostOfMostSignificantBit(3568)
    assert bitMath_contract.getGasCostOfMostSignificantBit(2**128-1)
    assert bitMath_contract.getGasCostOfMostSignificantBit(2**256-1)

def test_leastSignificantBit(bitMath_contract):
    with brownie.reverts():
        bitMath_contract.leastSignificantBitTest(0)

    assert bitMath_contract.leastSignificantBitTest(1) == 0
    assert bitMath_contract.leastSignificantBitTest(2) == 1
    
    for i in range(255):
        assert bitMath_contract.leastSignificantBitTest(2**i) == i

    assert bitMath_contract.leastSignificantBitTest(2**256-1) == 0
    assert bitMath_contract.getGasCostOfleastSignificantBit(3568)
    assert bitMath_contract.getGasCostOfleastSignificantBit(2**128-1)
    assert bitMath_contract.getGasCostOfleastSignificantBit(2**256-1)
    