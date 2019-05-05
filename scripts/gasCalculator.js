// Script calculates actual gas used (not just gas estimates) in calls to DeciMath functions.

/*  TESTING ACTUAL GAS USAGE
DeciMath functions are pure - they don't cost gas, unless called as part of a transaction.
On Ethereum, a direct function call from an EOA is performed locally - the function doesn't write data
or require network verification, so is computed with zero gas cost.

To test actual gas usage - not just estimate it - we use a proxy "DeciMathCaller" contract.
Its functions receive txs, and in turn call the respective DeciMath function.

Therefore: the math function call will be inside a transaction, and we can measure actual gas usage.  */


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

    // Instantiate a Decimath caller & connect it to DeciMath instance
    const caller = await DeciMathCaller.deployed()
    caller.setDeciMath(decimathAddr)

    // set LUT1 & LUT2
    const tx_setlut1 = await decimath.setLUT1();
    const tx_setlut2 = await decimath.setLUT2();
    //set LUT 3
   const tx_setlut3_1 = await decimath.setLUT3_1();
   const tx_setlut3_2 = await decimath.setLUT3_2();
   const tx_setlut3_3 = await decimath.setLUT3_3();
   const tx_setlut3_4 = await decimath.setLUT3_4();


    console.log("tx_setlut1 gas used is: " + tx_setlut1.receipt.gasUsed )
    console.log("tx_setlut2 gas used is: " + tx_setlut2.receipt.gasUsed )
    console.log("tx_setlut3_1 gas used is: " + tx_setlut3_1.receipt.gasUsed )
    console.log("tx_setlut3_2 gas used is: " + tx_setlut3_2.receipt.gasUsed )
    console.log("tx_setlut3_3 gas used is: " + tx_setlut3_3.receipt.gasUsed )
    console.log("tx_setlut3_4 gas used is: " + tx_setlut3_4.receipt.gasUsed )


    // ***** HELPER FUNCS ***** //

      const calcErrorPercent = (tested, actual) => {
        let diff = tested.minus(actual)
        errorPercent = (diff.mul(100).div(actual))
        return errorPercent
      }

      const avgDecimal = (decArray) => { // calculate the mean from an array of Decimal objects
        let sum = Decimal(0)
        for (let dec of decArray) sum = sum.add(dec)
        return sum.div(decArray.length)
      }

      const gasAndError = (tx, res, actual) => {
        const gas = tx.receipt.gasUsed
        const errorPercent = calcErrorPercent (res, actual)
        console.log("Gas used: " + gas )
        console.log("Error: " + errorPercent )
        return [gas, errorPercent]
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

      const printGas_powBySquare18UpTo = async (base, n, increment) => {
        for (let i = 1; i <= n; i+= increment) {
          printGas_powBySquare18(base.toString(), i)
        }
      }

      const printGas_powBySquare38UpTo = async (base, n, increment) => {
        for (let i = 1; i <= n; i+= increment) {
          printGas_powBySquare38(base.toString(), i)
        }
      }

      const printGas_pow2_UpTo = async (n, increment) => {
        for (let i = 1; i <= n; i+= increment) {
          printGas_pow2(i.toFixed(2))
        }
      }

      const printGas_log_2_UpTo = async (n, acc, increment) => {
        for (let i = 1; i <= n; i+= increment) {
          printGas_log_2(i.toFixed(2), acc)
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

        return gasAndError(tx, res18DP, actual)
      }

      const printGas_powBySquare18 = async (b, x) => {
        const base = makeBN.makeBN18(b)

        const tx = await caller.callPowBySquare18(base, x)
        const res = await decimath.powBySquare18(base, x)

        console.log("base is " + base + ", exponent is "+ x)

        const res18DP = makeBN.makeDecimal18(res)
        const actual = Decimal.pow(b, x).toFixed(18)

        console.log("powBySquare18(" + b + ", " + x + ") is: " + res18DP)
        console.log("JS Decimal pow(" + b + ", " + x + ") is: " + actual)

        return gasAndError(tx, res18DP, actual)
      }

      const printGas_powBySquare38 = async (b, x) => {
        const base = makeBN.makeBN38(b)

        const tx = await caller.callPowBySquare38(base, x)
        const res = await decimath.powBySquare38(base, x)

        console.log("base is " + base + ", exponent is "+ x)

        const res38DP = makeBN.makeDecimal38(res)
        const actual = Decimal.pow(b, x).toFixed(38)

        console.log("powBySquare38(" + b + ", " + x + ") is: " + res38DP)
        console.log("JS Decimal pow(" + b + ", " + x + ") is: " + actual)

        return gasAndError(tx, res38DP, actual)
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

      return gasAndError(tx, res18DP, actual)
      }

    const printGas_log_2 = async (x, acc) => {
      const arg = makeBN.makeBN18(x)
      const tx = await caller.callLog2(arg, acc) // send tx via proxy, to force gas usage
      const res = await decimath.log_2(arg, acc) // grab the returned BN

      console.log("argument is " + arg + ", accuracy is " + acc)

      const res30DP = makeBN.makeDecimal30(res)
      const actual = Decimal.log2(x).toFixed(30)

      console.log("log_2(" + x + ") is: " + res30DP)
      console.log("JS Decimal log_2("+ x + ") is: " + actual)

      const gas = tx.receipt.gasUsed
      console.log("Gas used: " + gas )

     return gasAndError(tx, res30DP, actual)
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

        return gasAndError(tx, res18DP, actual)
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

      return gasAndError(tx, res18DP, actual)
    }

    const printGas_pow2 = async(x) => {
      const exponent = makeBN.makeBN20(x)

      const tx = await caller.callPow2(exponent)
      const res = await decimath.pow2(exponent)
      console.log("exponent is: " + x)

      const res38DP = makeBN.makeDecimal38(res)
      const actual = Decimal(2).pow(x).toFixed(38)

      console.log("pow2(" + x + ") is: " + res38DP)
      console.log("JS Decimal 2^x("+ x + ") is: " + actual)

    return gasAndError(tx, res38DP, actual)
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
      console.log("JS Decimal pow(" + b +", " + x + ") is: " + actual)

      return gasAndError(tx, res18DP, actual)
    }

    const randomNum = (min, max) => {
      num =  Math.random() * (max - min) + min
      return num
    }

    // Call the contract function repeatedly, and computes the average gas and error per call.
    const avgGasAndError = async (contractCallback, min, max, timesToCall) => {
      let gasCosts = [];
      let errors = [];
      let avgGas;

      let minErrorPercent = (100); // start at 100%
      let maxErrorPercent = new Decimal(0);

      let minGas = 10*7; // start at 10 million gas
      let maxGas = 0;

      for (i = 0; i < timesToCall; i++) {
        num = randomNum(min, max)
        let [gas, errorPercent] = await contractCallback(num.toString())
        errorPercent = errorPercent.abs() // get the error magnitude

        gasCosts.push(gas)
        errors.push(errorPercent)

        // update min and max gas and error
        minErrorPercent =  errorPercent.lessThan(minErrorPercent) ? errorPercent : minErrorPercent
        maxErrorPercent =  errorPercent.greaterThan(maxErrorPercent) ? errorPercent : maxErrorPercent
        console.log("step: " + i)
        console.log("minErrorPercent is:" + minErrorPercent)
        console.log("maxErrorPercent is:" + maxErrorPercent)
        minGas =  gas < maxGas ? gas : minGas
        maxGas =  gas > maxGas ? gas : maxGas
      }
      // calculate averages
      avgGas = gasCosts.reduce( (sum, current ) => sum + current, 0 ) / gasCosts.length
      avgErrorPercent = avgDecimal(errors)

      console.log("FINAL RESULTS:")
      console.log("function tested: " + contractCallback.name)
      console.log("min gas: " + minGas)
      console.log("max gas: " + maxGas)
      console.log("Average gas:" + avgGas)
      console.log("min error: " + minErrorPercent)
      console.log("max error: " + maxErrorPercent)
      console.log("Average error:" + avgErrorPercent)
      return [avgGas, avgErrorPercent, minGas, maxGas, minErrorPercent, maxErrorPercent]
    }

  // ***** FUNCTION CALLS GO HERE ***** //

    // await avgGasAndError((n) => {return printGas_exp(n)}, 1, 89, 1000)
    // await avgGasAndError((n) => {return printGas_exp_taylor(n)}, 1, 89, 1000)
    // await avgGasAndError((n) => {return printGas_ln(n, 70)}, 1, 9**15, 1000)
    // await avgGasAndError((n) => {return printGas_pow(randomNum(1,10).toString(), n)}, 1, 25, 500)
    // await avgGasAndError((n) => {return printGas_pow(randomNum(10,100).toString(), n)}, 1, 10, 500)

    //GAS AND ERROR RANGES and AVG
    //func                   gas range       gas avg         error range         error avg
    //ln(1 to 9e15, 70)      81k-84k         80789          0 to 3.62e-18          6.72e-19
    // pow(1-10, 1-25)       109k-112k       108214         0 to 1.1e-15           3.32e-16
    // pow(10-100, 1-10)     106-113k        108346         4.87e-19 to 7.13e-16   1.67e-16
    // exp_taylor(1 to 89)   82-218k         133557         0 to 9.45e-17          9.83e-19
    // exp(1 to 89)          52-55k          53089          0 to 2.26e-17         1.85e-19

    //LIMITS

    // func          limit
    // exp(x)         ~exp(89)
    // ln(x)          ~ln(1.1e+41 to 1.2e+41)

    // printGas_decMul18('10', '30')

    // printGas_expUpTo(100, 1)
    // printGas_exp('0.000000000000001')

    // printGas_powBySquare18('1.0001552242434989', 11)

    // printGas_powBySquare18UpTo(2.234235454, 10, 3)

    // ((num) => {log2(num, acc)},  val1, val2)

      // printGas_powBySquare38('1.34234', 3)
      // printGas_powBySquare38UpTo('1.234235454', 80, 1)

    // printGas_lnUpTo(317, 70, 10.45600021324)

    // '2.00979700003993933000000098908000004453'
    // Limit finders
    // printGas_ln('110000000000000000000000000000000000000000', 70)
    // printGas_ln('1200000000000000000000000000000000000000000', 70)

    // printGas_pow('20.897897', '22.674456454')

    // printGas_powUpTo(7.1, 90, 4.567)

    // printGas_ln('1.43235', 99)

    // printGas_pow2('1.9')
    // printGas_pow2('1.998787987879870896')

    // printGas_pow2('1.111111111111111111')
    // printGas_pow2('1.118789864342423212')

    // printGas_pow2_UpTo('1.9', 0.05)

    // printGas_expUpTo(100, 5)
    // printGas_expTaylorUpTo(100, 5)
    // printGas_exp('1.4989890797422')

    // printGas_exp_taylor('0')
    // printGas_exp_taylor('1')
      // printGas_exp('1')
    // printGas_exp('20.518686786786878765')

    // printGas_log_2_UpTo(2, 80, 0.1)

    // printGas_log_2('1.5', 70)
    // printGas_log_2('1.012352343248782332', 75)
    // printGas_log_2('1.9', 1)
    // printGas_log_2('1.998990890809801878', 1)

  } catch (err) {
    console.log(err)
  }
}
