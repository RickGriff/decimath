// Script calculates actual gas used (not just gas estimates) in calls to DeciMath functions.

/* TESTING ACTUAL GAS USAGE

DeciMath functions are pure - they don't cost gas, unless called as part of a transaction.
A direct function call from an EOA is performed locally - the func doesn't write data / require network verification, so is computed with zero gas cost.

To test actual gas usage - not just estimate - we use a proxy "DeciMathCaller" contract.
It's functions receive txs, and in turn call the respective DeciMath function.

Therefore, the math function call will be inside a transaction, and we can measure actual gas usage.

*/


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

    // set all Lookup tables
    await decimath.setLUT1();
    await decimath.setLUT2();
    await decimath.setLUT3_1();
    await decimath.setLUT3_2();
    await decimath.setLUT3_3();
    await decimath.setLUT3_4();

    // ***** HELPER FUNCS ***** //

      const calcErrorPercent = (tested, actual) => {
        let diff = tested.minus(actual)
        errorPercent = (diff.mul(100).div(actual))
        console.log("error is " + errorPercent.toString() + "%")
      }

    // ***** ITERATIVE ERROR & GAS CALCULATORS ***** //

      //print gas used in successive exp(i) calls, up to i = n
      const printGas_expUpTo = async (n, increment) => {
        for (let i = 1; i <= n; i+= increment) {
          printGas_exp(i.toFixed(2))
        }
      }

      const printGas_expTaylorUpTo = async (n, increment) => {
        for (let i = 1; i <= n; i+= increment) {
          printGas_exp_taylor(i.toFixed(2))
        }
      }

      const printGas_expBySquare18UpTo = async (base, n, increment) => {
        for (let i = 1; i <= n; i+= increment) {
          printGas_expBySquare18(base.toString(), i)
        }
      }

      const printGas_expBySquare38UpTo = async (base, n, increment) => {
        for (let i = 1; i <= n; i+= increment) {
          printGas_expBySquare38(base.toString(), i)
        }
      }

      const printGas_two_x_UpTo = async (n, increment) => {
        for (let i = 1; i <= n; i+= increment) {
          printGas_two_x(i.toFixed(2))
        }
      }

      const printGas_log2UpTo = async (n, acc, increment) => {
        for (let i = 1; i <= n; i+= increment) {
          printGas_log2(i.toFixed(2), acc)
        }
      }

      const printGas_lnUpTo = async (n, acc, increment) => {
        for (let i = 1; i <= n; i+= increment) {
          printGas_ln(i.toFixed(2), acc)
        }
      }

      const printGas_powUpTo = async (base, n, increment) => {
        for (let i = 0; i <= n; i+= increment) {
          printGas_pow(base.toString(), i.toFixed(2))
        }
      }

      /***** INDIVIDUAL GAS AND ERROR CALCULATORS *****/

      const printGas_decMul18 = async (x, y) => {
        const a = makeBN.makeBN18(x)
        const b = makeBN.makeBN18(y)

        const tx = await caller.callDecMul18(a, b)
        const res = await decimath.decMul18(a, b)

        console.log("x is " + a + ", y is "+ b)

        const res18DP = makeBN.makeDecimal18(res)
        const actual = Decimal.mul(x, y).toFixed(18)

        console.log("decMul18(" + x + ", " + y + ") is: " + res18DP)
        console.log("JS Decimal mul(" + x + ", " + y + ") is: " + actual)

        console.log("Gas used: " +  (tx.receipt.gasUsed))
        calcErrorPercent (res18DP, actual)
      }

      const printGas_expBySquare18 = async (b, x) => {
        const base = makeBN.makeBN18(b)

        const tx = await caller.callExpBySquare18(base, x)
        const res = await decimath.expBySquare18(base, x)

        console.log("base is " + base + ", exponent is "+ x)

        const res18DP = makeBN.makeDecimal18(res)
        const actual = Decimal.pow(b, x).toFixed(18)

        console.log("expBySquare18(" + b + ", " + x + ") is: " + res18DP)
        console.log("JS Decimal pow(" + b + ", " + x + ") is: " + actual)

        console.log("Gas used: " +  tx.receipt.gasUsed)
        calcErrorPercent (res18DP, actual)
      }

      const printGas_expBySquare38 = async (b, x) => {
        const base = makeBN.makeBN38(b)

        const tx = await caller.callExpBySquare38(base, x)
        const res = await decimath.expBySquare38(base, x)

        console.log("base is " + base + ", exponent is "+ x)

        const res38DP = makeBN.makeDecimal38(res)
        const actual = Decimal.pow(b, x).toFixed(38)

        console.log("expBySquare38(" + b + ", " + x + ") is: " + res38DP)
        console.log("JS Decimal pow(" + b + ", " + x + ") is: " + actual)

        console.log("Gas used: " +  tx.receipt.gasUsed)
        calcErrorPercent (res38DP, actual)
      }

      const printGas_exp_taylor = async(x) => {
        const exponent = makeBN.makeBN18(x)
        const tx = await caller.callExpTaylor(exponent) // send tx via proxy, to force gas usage

        const res = await decimath.exp_taylor(exponent) // grab the returned BN
        console.log("argument is " + exponent)

        const res18DP = makeBN.makeDecimal18(res)
        const actual = Decimal.exp(x).toFixed(18)

        console.log("exp_taylor(" + x + ") is: " + res18DP)
        console.log("JS Decimal exp("+ x + ") is: " + actual)

        console.log("Gas used: " +  tx.receipt.gasUsed)
        calcErrorPercent (res18DP, actual)
      }

    const printGas_log2 = async(x, acc) => {
      const arg = makeBN.makeBN18(x)
      const tx = await caller.callLog2(arg, acc) // send tx via proxy, to force gas usage
      const res = await decimath.log2(arg, acc) // grab the returned BN
      console.log("argument is " + arg + ", accuracy is " + acc)

      const res30DP = makeBN.makeDecimal30(res)
      const actual = Decimal.log2(x).toFixed(30)

      console.log("log2(" + x + ") is: " + res30DP)
      console.log("JS Decimal log2("+ x + ") is: " + actual)

      console.log("Gas used: " +  tx.receipt.gasUsed)
      calcErrorPercent (res30DP, actual)
    }

    const printGas_ln = async(x, acc) => {
      const arg = makeBN.makeBN18(x)

        const tx = await caller.callLn(arg, acc) // send tx via proxy, to force gas usage
        const res = await decimath.ln(arg, acc) // grab the returned BN

        console.log("argument is " + arg + ", accuracy is " + acc)

        const res18DP = makeBN.makeDecimal18(res)
        const actual = Decimal.ln(x).toFixed(18)

        console.log("ln(" + x + ") is: " + res18DP)
        console.log("JS Decimal ln("+ x + ") is: " + actual)

        console.log("Gas used: " +  tx.receipt.gasUsed)
        calcErrorPercent (res18DP, actual)
      }


    const printGas_exp = async (x) => {
      const exponent = makeBN.makeBN18(x)

      const tx = await caller.callExp(exponent)
      const res = await decimath.exp(exponent)
      console.log("exponent is: " + x)

      const res18DP = makeBN.makeDecimal18(res)
      const actual = Decimal.exp(x).toFixed(18)

      console.log("exp(" + x + ") is: " + res18DP)
      console.log("JS Decimal exp("+ x + ") is: " + actual)

      console.log("Gas used in exp(" + x + "): " +  tx.receipt.gasUsed)
      calcErrorPercent(res18DP, actual)
    }

    const printGas_two_x = async(x) => {
      const exponent = makeBN.makeBN20(x)

      const tx = await caller.callTwoX(exponent)
      const res = await decimath.two_x(exponent)
      console.log("exponent is: " + x)

      const res38DP = makeBN.makeDecimal38(res)
      const actual = Decimal(2).pow(x).toFixed(38)

      console.log("two_x(" + x + ") is: " + res38DP)
      console.log("JS Decimal 2^x("+ x + ") is: " + actual)

      console.log("Gas used: " +  tx.receipt.gasUsed)
      calcErrorPercent(res38DP, actual)
    }

    const printGas_pow = async(b, x) => {
      const exponent = makeBN.makeBN18(x)
      const base = makeBN.makeBN18(b)

      const tx = await caller.callPow(base, exponent)
      const res = await decimath.pow(base, exponent)
      console.log("base is: " + base)
      console.log("exponent is: " + exponent)

      const res18DP = makeBN.makeDecimal18(res) // exp(x) returns 38DP
      const actual = Decimal.pow(b, x).toFixed(18)

      console.log("pow(" + b +", " + x + ") is: " + res18DP)
      console.log("JS Decimal b^x("+ x + ") is: " + actual)

      console.log("Gas used: " +  tx.receipt.gasUsed)
      calcErrorPercent(res18DP, actual)
    }

  // ***** FUNCTION CALLS ***** //

    // printGas_decMul18('10', '30')

    // calcError(70, 60)
    printGas_expUpTo(100, 2.444500006443)
    // printGas_exp('0.000000000000001')

    // printGas_expBySquare18('1.0001552242434989', 11)
     // printGas_expBySquare18UpTo(2.234235454, 80, 3)

      // printGas_expBySquare38('3', 3)
      // printGas_expBySquare38UpTo(1.234235454, 80, 1)


    // printGas_lnUpTo(900, 70, 10)

    // '2.00979700003993933000000098908000004453'

    // printGas_ln('98788978989789789789232978978978978998122', 70)
    // printGas_ln('98788978989789789789232978978978978998122', 99)
    // printGas_pow('15.897897', '12.674456454')

    // printGas_powUpTo(7.1, 90, 4.567)


    // printGas_ln('1.43235', 99)

    // printGas_two_x('1.9')
    // printGas_two_x('1.998787987879870896')

    // printGas_two_x('1.111111111111111111')
    // printGas_two_x('1.118789864342423212')

    // printGas_two_x_UpTo('1.9', 0.05)

    // printGas_expUpTo(100, 5)
    // printGas_expTaylorUpTo(100, 5)
    // printGas_exp('1.4989890797422')

    // printGas_exp_taylor('20.518686786786878765')
    // printGas_exp('20.518686786786878765')

    // printGas_log2UpTo(2, 99, 0.1)



    // printGas_log2('1', 70)
    // printGas_log2('1.012352343248782332', 70)
    // printGas_log2('1.9', 1)
    // printGas_log2('1.998990890809801878', 1)

  } catch (err) {
    console.log(err)
  }
}
