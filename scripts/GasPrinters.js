
const BN = require('bn.js');
const makeBN = require('./makeBN.js');
const Decimal = require('decimal.js');
const BigNumber = require('bignumber.js');
const { gasAndError, minDecimal, maxDecimal, avgDecimal, randomBigNum, formatName } = require('./gasCalcTools.js');

class GasPrinter {
  constructor(decimath, caller) {
    this.decimath = decimath
    this.caller = caller
    this.printer = this;
  }

  /***** INDIVIDUAL GAS AND ERROR PRINTER METHODS *****/

  async decMul18(x, y) {
    const a = makeBN.makeBN18(x)
    const b = makeBN.makeBN18(y)

    const tx = await this.caller.callDecMul18(a, b)
    const res = await this.decimath.decMul18(a, b)

    console.log(`x is ${a}, y is ${b}`)

    const res18DP = makeBN.makeDecimal18(res)
    const actual = Decimal.mul(x, y).toFixed(18)

    console.log(`decMul18(${x}, ${y}) is:  ${res18DP}`)
    console.log(`JS Decimal mul(${x}, ${y}) is: ${actual}`)

    return gasAndError(tx, res18DP, actual)
  }

  async powBySquare18(b, x) {
    const base = makeBN.makeBN18(b)

    const tx = await this.caller.callPowBySquare18(base, x)
    const res = await this.decimath.powBySquare18(base, x)

    console.log(`base is ${base}, exponent is ${x}`)

    const res18DP = makeBN.makeDecimal18(res)
    const actual = Decimal.pow(b, x).toFixed(18)

    console.log(`powBySquare18(${b}, ${x}) is: ${res18DP}`)
    console.log(`JS Decimal pow(${b}, ${x}) is: ${actual}`)

    return gasAndError(tx, res18DP, actual)
  }

  async powBySquare38(b, x) {
    const base = makeBN.makeBN38(b)

    const tx = await this.caller.callPowBySquare38(base, x)
    const res = await this.decimath.powBySquare38(base, x)

    console.log(`base is ${base}, exponent is ${x}`)

    const res38DP = makeBN.makeDecimal38(res)
    const actual = Decimal.pow(b, x).toFixed(38)

    console.log(`powBySquare38(${b}, ${x}) is: ${res38DP}`)
    console.log(`JS Decimal pow(${b}, ${x}) is: ${actual}`)

    return gasAndError(tx, res38DP, actual)
  }

  async expTaylor(x) {
    const exponent = makeBN.makeBN18(x)
    const tx = await this.caller.callExpTaylor(exponent) // send tx via proxy, to force gas usage

    const res = await this.decimath.exp_taylor(exponent) // grab the returned BN
    console.log(`argument is ${exponent}`)

    const res18DP = makeBN.makeDecimal18(res)
    const actual = Decimal.exp(x).toFixed(18)

    console.log(`expTaylor(${x}) is: ${res18DP}`)
    console.log(`JS Decimal exp(${x}) is: ${actual}`)

    return gasAndError(tx, res18DP, actual)
  }

  async log2(x, acc) {
    const arg = makeBN.makeBN18(x)
    const tx = await this.caller.callLog2(arg, acc)
    const res = await this.decimath.log_2(arg, acc)

    console.log(`argument is ${arg}, accuracy is ${acc}`)

    const res30DP = makeBN.makeDecimal30(res)
    const actual = Decimal.log2(x).toFixed(30)

    console.log(`log2(${x}) is: ${res30DP}`)
    console.log(`JS Decimal log2(${x}) is: ${actual}`)

    const gas = tx.receipt.gasUsed

    return gasAndError(tx, res30DP, actual)
  }

  async ln(x, acc) {
    const arg = makeBN.makeBN18(x)

    const tx = await this.caller.callLn(arg, acc)
    const res = await this.decimath.ln(arg, acc)

    console.log(`argument is ${arg}, accuracy is ${acc}`)

    const res18DP = makeBN.makeDecimal18(res)
    const actual = Decimal.ln(x).toFixed(18)

    console.log(`ln(${x}) is: ${res18DP}`)
    console.log(`JS Decimal ln(${x}) is: ${actual}`)

    return gasAndError(tx, res18DP, actual)
  }

  async exp(x) {
    const exponent = makeBN.makeBN18(x)

    const tx = await this.caller.callExp(exponent)
    const res = await this.decimath.exp(exponent)
    console.log(`exponent is: ${x}`)

    const res18DP = makeBN.makeDecimal18(res)
    const actual = Decimal.exp(x).toFixed(18)

    console.log(`exp(${x}) is: ${res18DP}`)
    console.log(`JS Decimal exp(${x}) is: ${actual}`)

    return gasAndError(tx, res18DP, actual)
  }

  async pow2(x) {
    const exponent = makeBN.makeBN20(x)

    const tx = await this.caller.callPow2(exponent)
    const res = await this.decimath.pow2(exponent)
    console.log(`exponent is: ${x}`)

    const res38DP = makeBN.makeDecimal38(res)
    const actual = Decimal(2).pow(x).toFixed(38)

    console.log(`pow2(${x}) is: ${res38DP}`)
    console.log(`JS Decimal pow2(${x}) is: ${actual}`)

    return gasAndError(tx, res38DP, actual)
  }

  async pow(b, x) {
    console.log(`base is: ${b}`)
    console.log(`exponent is: ${x}`)
    const exponent = makeBN.makeBN18(x)
    const base = makeBN.makeBN18(b)

    const tx = await this.caller.callPow(base, exponent)
    const res = await this.decimath.pow(base, exponent)

    const res18DP = makeBN.makeDecimal18(res) // exp(x) returns 38DP
    const actual = Decimal.pow(b, x).toFixed(18)

    console.log(`pow(${x}) is: ${res18DP}`)
    console.log(`JS Decimal pow(${x}) is: ${actual}`)

    return gasAndError(tx, res18DP, actual)
  }
}

// class LoopGasPrinter extends GasPrinter {

//   constructor(decimath, caller) {
//     super(decimath, caller)
//   }
 
// }

class AvgGasPrinter extends GasPrinter {

  constructor(decimath, caller) {
    super(decimath, caller)

    // Set the 'this' keyword in callbacks to the current class instance
    this.log2_callback = this.log2_callback.bind(this);
    this.ln_callback = this.ln_callback.bind(this);
    this.exp_callback = this.exp_callback.bind(this);
    this.expTaylor_callback = this.expTaylor_callback.bind(this);
    this.pow2_callback = this.pow2_callback.bind(this);
  }

  // Call the contract function repeatedly with random argument, and compute the average gas and error per call.
  async avgGasAndError(contractCallback, minArg, maxArg, timesToCall, intArgument = false) {
    let rawResults = await this.getRawGasAndErrorResults(contractCallback, minArg, maxArg, timesToCall, intArgument);

    let gasCosts = rawResults.gasCosts
    let errors = rawResults.errors
    let argsList = rawResults.argsList

    const minErrorPercent = minDecimal(errors)
    const maxErrorPercent = maxDecimal(errors)
    const minArgUsed = BigNumber.minimum(...argsList).toString()
    const maxArgUsed = BigNumber.maximum(...argsList).toString()
    const minGas = Math.min(...gasCosts)
    const maxGas = Math.max(...gasCosts)

    // calculate averages
    const avgGas = gasCosts.reduce((sum, current) => sum + current, 0) / gasCosts.length
    const avgErrorPercent = avgDecimal(errors)

    const functionName = formatName(contractCallback.name)

    const results = {
      functionTested: functionName,
      minimumArg: minArgUsed,
      maximumArg: maxArgUsed,
      minErrorPercent: minErrorPercent.valueOf(),
      maxErrorPercent: maxErrorPercent.valueOf(),
      avgErrorPercent: avgErrorPercent.valueOf(),
      minGas,
      maxGas,
      avgGas
    }
    console.log(results)
    return results
  }

  async getRawGasAndErrorResults(contractCallback, minArg, maxArg, timesToCall, intArgument) {
    const gasCosts = [];
    const errors = [];
    const argsList = [];

    for (let i = 0; i < timesToCall; i++) {
      let gas;
      let errorPercent;
      console.log(`step ${i}`)
      let randArg = randomBigNum(minArg, maxArg)
      randArg = intArgument ? Math.floor(randArg) : randArg

      try {
        let res = await contractCallback(randArg)  // not working...
        gas = res.gas
        errorPercent = res.errorPercent
      } catch (err) {
        console.log(
          `For arg = ${randArg}, contract function reverted.`
        )
        continue // if this contract call reverts, skip to the next one 
      }

      argsList.push(randArg)
      errorPercent = errorPercent.abs() // get the error magnitude
      gasCosts.push(gas)
      errors.push(errorPercent)

    }
    return { gasCosts, errors, argsList }
  }

  /// ***** AVERAGE ERROR & GAS PRINTER METHODS ***** //

  // callbacks
  async log2_callback(n) { return this.log2(n, 70) }
  async ln_callback(n) { return this.ln(n, 70) }
  async exp_callback(n) { return this.exp(n) }
  async expTaylor_callback(n) { return this.expTaylor(n) }
  async pow2_callback(n) { return this.pow2(n) }

  /* These printers call their respective contract functions with randomized argument(s)
   multiple times, and output the average gas and error. */

  // Single parameter functions
  async log2_mean(minArg, maxArg, timesToCall) {
    return this.avgGasAndError(this.log2_callback, minArg, maxArg, timesToCall)
  }

  async ln_mean(minArg, maxArg, timesToCall) {
    return this.avgGasAndError(this.ln_callback, minArg, maxArg, timesToCall);
  }

  async exp_mean(minArg, maxArg, timesToCall) {
    return this.avgGasAndError(this.exp_callback, minArg, maxArg, timesToCall);
  }

  async expTaylor_mean(minArg, maxArg, timesToCall) {
    return this.avgGasAndError(this.expTaylor_callback, minArg, maxArg, timesToCall);
  }

  async pow2_mean(minArg, maxArg, timesToCall) {
    return this.avgGasAndError(this.pow2_callback, minArg, maxArg, timesToCall);
  }

  // Two-parameter functions (base and exponent)
  async powBySquare18_mean(base, minArg, maxArg, timesToCall) {
    function powBySquare18_callback (n) { return this.powBySquare18(base, n) }
    const boundCallback = powBySquare18_callback.bind(this);

    return this.avgGasAndError(boundCallback, minArg, maxArg, timesToCall, true);
  }

  async powBySquare38_mean(base, minArg, maxArg, timesToCall) {
    function powBySquare38_callback (n) { return this.powBySquare38(base, n) }
    const boundCallback =  powBySquare38_callback.bind(this);

    return this.avgGasAndError(boundCallback, minArg, maxArg, timesToCall,  true);
  }

  async pow_mean(base, minArg, maxArg, timesToCall) {
    function pow_callback (n) { return this.pow(base, n) }
    const boundCallback = pow_callback.bind(this);

    return this.avgGasAndError(boundCallback, minArg, maxArg, timesToCall)
  }

   // ***** ITERATIVE ERROR & GAS PRINTER METHODS ***** //

  /* Print gas and error from successive calls, up to i = n. Used to see how gas & error vary
   with argument. */

   async exp_upTo(n, increment) {
    for (let i = 1; i <= n; i += increment) {
      await this.exp(i.toFixed(2))
    }
  }

  async expTaylor_upTo(n, increment) {
    for (let i = 1; i <= n; i += increment) {
      await this.expTaylor(i.toFixed(2))
    }
  }

  async powBySquare18_upTo(base, n, increment) {
    for (let i = 1; i <= n; i += increment) {
      await this.powBySquare18(base.toString(), i)
    }
  }

  async powBySquare38_upTo(base, n, increment) {
    for (let i = 1; i <= n; i += increment) {
      await this.powBySquare38(base.toString(), i)
    }
  }

  async pow2_upTo(n, increment) {
    for (let i = 1; i <= n; i += increment) {
      await this.pow2(i.toFixed(2))
    }
  }

  async log2_upTo(n, acc, increment) {
    for (let i = 1; i <= n; i += increment) {
      await this.log2(i.toFixed(2), acc)
    }
  }

  async ln_upTo(n, acc, increment) {
    for (let i = 1; i <= n; i += increment) {
      await this.ln(i.toFixed(2), acc)
    }
  }

  async pow_upTo(base, n, increment) {
    for (let i = 0; i <= n; i += increment) {
      await this.pow(base.toString(), i.toFixed(2))
    }
  }
}

module.exports = {
  GasPrinter,
  AvgGasPrinter
}