// Script calculates actual gas used (not just gas estimates) in calls to DeciMath functions.
// Uses a proxy 'caller' contract to call math functions as part of a transaction, and thus use gas.

const BN = require('bn.js');
const makeBN = require('./makeBN.js');
const Decimal = require('decimal.js');

Decimal.set({ precision: 50})

module.exports = async () => {
  try {
    var DeciMath = artifacts.require("./DeciMath.sol");
    var DeciMathCaller = artifacts.require("./DeciMathCaller.sol");

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

    // ***** HELPER FUNCS ***** //

      const calcErrorPercent = (tested, actual) => {
        let diff = tested.minus(actual)
        errorPercent = (diff.mul(100).div(actual))
        console.log("error is " + errorPercent.toString() + "%")
      }

    // ***** ITERATIVE ERROR & GAS CALCULATORS ***** //

      //print gas used in successive exp(i) calls, up to i = n

      const printGas_expUpTo = async (n) => {
        await decimath.setAllLUTs()
        for (let i = 1; i <= n; i++) {
        printGas_exp(i.toString())
        }
      }

      // print log2(i) for i in range [1,2[
      const printGas_log2UpTo = async (n, acc, increment) => {
        await decimath.setAllLUTs()
        for (let i = 1; i <= n; i+= increment) {
          printGas_log2(i.toFixed(2), acc)
        }
      }

      const printGas_exp18 = async (x, n) => {
        const base = makeBN.makeBN18(x.toString())
        console.log("base is: " + x)

        for (let i = 1; i <= n; i++) {
          // const exponent = makeBN.makeBN18(i.toString())
          console.log("exponent is: " + i)
          const tx = await caller.callExp18(base, i)
          console.log("Gas used in exp18(" + x.toString()+ ", " + i.toString() + "): " +  tx.receipt.gasUsed)
        }
      }

    const printGas_log2 = async(x, acc) => {
      const arg = makeBN.makeBN18(x)

        const tx = await caller.callLog2(arg, acc) // send tx via proxy, to force gas usage
        const res = await decimath.log2(arg, acc) // grab the returned BN
        console.log("argument is " + arg + " accuracy is " + acc)

        const res18DP = makeBN.makeDecimal18(res)
        const actual = Decimal.log2(x).toPrecision(18)

        console.log("log2(" + x + ") is: " + res18DP)
        console.log("JS Decimal log2("+ x + ") is: " + actual)

        console.log("Gas used: " +  tx.receipt.gasUsed)
        calcErrorPercent (res18DP, actual)
      }


    const printGas_exp = async (x) => {
      const exponent = makeBN.makeBN18(x)

      const tx = await caller.callExp(exponent)
      const res = await decimath.exp(exponent)
      console.log("exponent is: " + x)

      const res38DP = makeBN.makeDecimal38(res)
      const actual = Decimal.exp(x)

      console.log("exp(" + x + ") is: " + res38DP)
      console.log("JS Decimal exp("+ x + ") is: " + actual)

      console.log("Gas used in exp(" + x + "): " +  tx.receipt.gasUsed)
      calcErrorPercent(res38DP, actual)
    }

    const printGas_two_x = async(x) => {
      await decimath.setAllLUTs()
      const exponent = makeBN.makeBN20(x)

      const tx = await caller.callTwoX(exponent)
      const res = await decimath.two_x(exponent)
      console.log("exponent is: " + x)

      const res38DP = makeBN.makeDecimal38(res)
      const actual = Decimal(2).pow(x)

      console.log("two_x(" + x + ") is: " + res38DP)
      console.log("JS Decimal 2^x("+ x + ") is: " + actual)

      console.log("Gas used: " +  tx.receipt.gasUsed)
      calcErrorPercent(res38DP, actual)
    }

  // ***** FUNCTION CALLS ***** //

    // calcError(70, 60)
    // printGas_expUpTo(100)
    // printGas_exp('0.000000000000001')

    printGas_two_x('1.92345678912345678912')
    // printGas_expUpTo(100)
    // printGas_log2UpTo(2, 70, 0.1)

    // printGas_log2('1.143219897889701121', 40)
    // console.log(makeBN.makeBN38('1.000000000000000001').toString())
    // printGas_log2(printGas_log2(1999999999999999999, 99), 99)
    // 100000000000000000100000000000000000000
    //

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
