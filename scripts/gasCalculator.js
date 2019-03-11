

// Script calculates actual gas used (not just gas estimates) in calls to DeciMath functions.
// Uses a proxy 'caller' contract to call math functions as part of a transaction, and thus use gas.

const BN = require('bn.js');
const makeBN = require('./makeBN.js');

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

    // Grab DeciMath instance
    const decimath = await DeciMath.deployed()
    const decimathAddr = decimath.address

    // Instantiate a Decimath caller, in order to send transactions to deployed DeciMath contract,
    // and cause functions to use gas.
    const caller = await DeciMathCaller.deployed()
    caller.setDeciMath(decimathAddr)

    //print gas used in successive exp(i) calls, up to i = n
    const printGas_exp = async (n) => {
      for (let i = 1; i <= n; i++) {
        let exponent = makeBN.makeBN18(i)
        console.log("exponent is: " + exponent)
        const tx = await caller.callExp(exponent)
        console.log("Gas used in exp(" + i.toString() + "): " +  tx.receipt.gasUsed)
      }
    }

    const printGas_exp18 = async (x, n) => {
      const base = makeBN.makeBN18(x)
      console.log("base is: " + base)

      for (let i = 1; i <= n; i++) {
        // const exponent = makeBN.makeBN18(i.toString())
        console.log("exponent is: " + i)
        const tx = await caller.callExp18(base, i)

        console.log("Gas used in exp18(" + x.toString()+ ", " + i.toString() + "): " +  tx.receipt.gasUsed)
      }
    }

    printGas_exp(100)

    //

    //estimate gas for e^n
    // const expGasEstimate = await decimath.exp.estimateGas(ten_ether, {from: accounts[0]})
    // console.log("Gas Estimate for exp(ten ether) is: " + expGasEstimate)

    // makeBigNum18 Tests
    // TODO: convert to asserts in mocha
    // const logBN18 = (n) => {
    //   const bigNum = makeBN.makeBN18(n);
    //   console.log("Make bigNum from input " + n.toString() + ": " + bigNum.toString() + " Total digits: " + bigNum.toString().length )
    // }
    // logBN18("4.0")
    // logBN18("12")
    // logBN18("3.456")
    // logBN18("1.123456789123456789")
    // logBN18("999.123456789123456789")
    // logBN18("999.1234567891234567810")

  } catch (err) {
    console.log(err)
  }
}

// TESTING ACTUAL GAS USAGE
// Decimath funtions are pure, thus don't cost gas unless called as part of a transaction.
// A direct func call from an EOA is performed locally -
// the func doesn't write data / require network verification, so is computed with zero gas cost.

// To test actual gas usage - not just estimate - Use proxy "DeciMathCaller" contract.
// It's funcs receive txs and in turn calls respective Decimath func.

// Thus, the math function call will be inside a transaction, and we can measure actual gas usage.
