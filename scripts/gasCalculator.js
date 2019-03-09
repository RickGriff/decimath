
const BN = require('bn.js');

module.exports = async () => {
  try {
    var DeciMath = artifacts.require("./DeciMath.sol");
    var DeciMathCaller = artifacts.require("./DeciMathCaller.sol");

    //declare a quintillion constant - 10**18
    const QUINT = new BN('1000000000000000000', 10)
    const FIFTY_QUINT = new BN('50000000000000000000', 10)
    const gasPrice = await DeciMath.web3.eth.getGasPrice()
    const accounts = await web3.eth.getAccounts()
    console.log("Gas price is: " + gasPrice)

    const decimath = await DeciMath.deployed()
    const decimathAddr = decimath.address

    const caller = await DeciMathCaller.deployed()
    caller.setDeciMath(decimathAddr)

    const tx = await caller.callExp(FIFTY_QUINT)
    console.log("tx receipt is: " + tx)

    // Estimate gas  for decMul2(x,y)
    const decMul2GasEstimate = await decimath.decMul2.estimateGas(200,345)
    console.log("Gas Estimate for decMul2(x,y) is: " + decMul2GasEstimate)

    // call exp(n) with n=10
    const ten_ether = new BN((QUINT * 50).toString(), 10)
    console.log("Ten ether is: " + ten_ether.toString())

    const res_exp = await decimath.exp(ten_ether, {from: accounts[0]})
    console.log( (res_exp ).toString() )

    //estimate gas for e^n
    const expGasEstimate = await decimath.exp.estimateGas(ten_ether, {from: accounts[0]})
    console.log("Gas Estimate for exp(ten ether) is: " + expGasEstimate)

  } catch (err) {
    console.log(err)
  }
}

// // Get actual gas used for exp(n) from tx receipt
// tx2 = await decimath.exp(10**15, {from: accounts[0]})
// console.log(tx2)
// console.log("Gas used in exp(1000) call: " +  tx2.receipt.gasUsed)
// console.log(tx2.logs)
// }

// These func calls don't cost gas, as they are local calls,
// and the func is pure.
// The func doesn't write data, so doesnt receive transactions.

// Way to test actual gas usage - not just estimate - even though local calls cost 0.
// Ideas:
// --Intermediate contract, that calls this one, and writes some arb data e.g. x=1 in it's own storage.
//-- Edit / wrap DeciMath so these funcs receive transactions
