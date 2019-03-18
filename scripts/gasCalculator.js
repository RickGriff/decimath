

// Script calculates actual gas used (not just gas estimates) in calls to DeciMath functions.
// Uses a proxy 'caller' contract to call math functions as part of a transaction, and thus use gas.

const BN = require('bn.js');
const makeBN = require('./makeBN.js');
const Decimal = require('decimal.js');

Decimal.set({ precision: 18})

module.exports = async () => {
  try {
    var DeciMath = artifacts.require("./DeciMath.sol");
    var DeciMathCaller = artifacts.require("./DeciMathCaller.sol");

    //declare a quintillion constant - 10**18
    const QUINT = new BN('1000000000000000000', 10)
    const FIFTY_QUINT = new BN('50000000000000000000', 10)

    const gasPrice = await DeciMath.web3.eth.getGasPrice()
    const accounts = await web3.eth.getAccounts()

    console.log("Network gas price is: " + gasPrice + "\n")

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
        console.log("exponent is: " + i)

        const tx = await caller.callExp(i)
        const res = await decimath.exp(exponent)

        console.log("exp("+ i.toString() + ") is: " + res.toString())
        console.log("JS Decimal exp("+ i.toString() + ") is: " + Decimal.exp(i))

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

    const printGas_log2 = async(x, accuracy) => {
      const arg = makeBN.makeBN38(x.toString())

      //set lookup tables in contract
      await decimath.setLUT1()
      await decimath.setLUT2()

      for (let i = 1; i <= accuracy; i++) {
        console.log("\n")
        console.log("accuracy is " + i)
        const tx = await caller.callLog2(arg, i) // send tx via proxy, to force gas usage
        const res = await decimath.log2(arg, i) // grab the returned BN

        console.log("log2("+ x.toString() + ") is: " + res.toString())

        // convert returned 38DP BN back to 18DP string / Decimal, for comparison with 'actual'
        const strBN = res.toString()
        const fractPartZeros = "0".repeat(38 - strBN.length)
        const resNum = new Decimal ("0." + fractPartZeros  + strBN)

        // const resNumDec = new Decimal(resNum)
        console.log("resNum is " + resNum.toPrecision(18))
        //TODO - strip / round resnum to 18DP, convert to Dec, compare to actual

        const actual = Decimal.log2(x)
        console.log("JS Decimal log2("+ x.toString() + ") is: " + actual)

        console.log("Gas used in log2(" + x.toString() + ", " + i.toString() + "): " +  tx.receipt.gasUsed)


        calcError (resNum, actual)
      }
    }

    const calcError = (tested, actual) => {
      errorPercent = Decimal((tested - actual) * 100  / actual)
      console.log("error is " + errorPercent.toString() + "%")
    }



    // calcError(70, 60)
    // printGas_exp(100)
    // printGas_exp18(2,30)

    printGas_log2(1.56, 100)



    //estimate gas for e^n
    // const expGasEstimate = await decimath.exp.estimateGas(ten_ether, {from: accounts[0]})
    // console.log("Gas Estimate for exp(ten ether) is: " + expGasEstimate)

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

// Thus, the math function call will be inside a transaction, and we can measure actual gas usage
// -- subtract 21k for transaction cost.
