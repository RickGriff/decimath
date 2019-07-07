/* Script calculates actual gas used (not just gas estimates) in calls to DeciMath functions.

TESTING ACTUAL GAS USAGE
DeciMath functions are pure - they don't cost gas, unless called as part of a transaction.
On Ethereum, a direct function call from an EOA is performed locally. The function doesn't write data
or require network verification, so its computation costs zero gas. 

To test actual gas usage - not just estimate it - we use a proxy "DeciMathCaller" contract.
Its functions receive transactions, and in turn call the respective DeciMath function.

Therefore: the math function call will be inside a transaction, and we can measure actual gas usage.  */


const Decimal = require('decimal.js');
const { setLUTs } = require('./gasCalcTools.js');
const { AvgGasPrinter } = require('./GasPrinters.js');

Decimal.set({ precision: 50 })

module.exports = async () => {
  try {
    const decimath = await getDecimath();
    const caller = await getCaller(decimath);
    await setLUTs(decimath)
    gasPrinter = new AvgGasPrinter(decimath, caller)
    makeContractCalls(gasPrinter)

  } catch (err) {
    console.log(err)
  }
}

const getDecimath = async () => {
  const DeciMath = artifacts.require("./DeciMath.sol");

  const gasPrice = await DeciMath.web3.eth.getGasPrice()
  console.log(`Network gas price is: ${gasPrice} \n`)
  const decimath = await DeciMath.deployed()

  return decimath
}

getCaller = async (decimath) => {
  // Instantiate a Decimath caller & connect it to DeciMath instance
  const DeciMathCaller = artifacts.require("./DeciMathCaller.sol");
  const decimathAddr = decimath.address

  const caller = await DeciMathCaller.deployed()
  caller.setDeciMath(decimathAddr)

  return caller
}

const makeContractCalls = async (gasPrinter) => {

 // ***** FUNCTION CALLS GO HERE *****

// e.g:

// await gasPrinter.exp(40.094)    // return gas & error of exp(40.094)

// await gasPrinter.ln('137.654', 70)   // return gas & error of ln(137.654) for accuracy = 70 iterations

// await gasPrinter.exp_upTo(10,2)         // return gas & error of exp(n), for n = 1 to 10, in increments of 2

// await gasPrinter.exp_mean(3, 60, 10 )   // return average gas & error from 10 calls to exp(n), for randomized n in range [3,60]

}
