
const BN = require('bn.js');
const makeBN = require('./makeBN.js');
const Decimal = require('decimal.js');
const BigNumber = require('bignumber.js');

const setLUTs = async (decimathInstance) => {
  // set LUT1 & LUT2
  const tx_setLUT1 = await decimathInstance.setLUT1();
  const tx_setLUT2 = await decimathInstance.setLUT2();
  //set LUT 3
  const tx_setLUT3_1 = await decimathInstance.setLUT3_1();
  const tx_setLUT3_2 = await decimathInstance.setLUT3_2();
  const tx_setLUT3_3 = await decimathInstance.setLUT3_3();
  const tx_setLUT3_4 = await decimathInstance.setLUT3_4();

  console.log(`tx_setLUT1 gas used is: ${tx_setLUT1.receipt.gasUsed}`)
  console.log(`tx_setLUT2 gas used is: ${tx_setLUT2.receipt.gasUsed}`)
  console.log(`tx_setLUT3_1 gas used is: ${tx_setLUT3_1.receipt.gasUsed}`)
  console.log(`tx_setLUT3_2 gas used is: ${tx_setLUT3_2.receipt.gasUsed}`)
  console.log(`tx_setLUT3_3 gas used is: ${tx_setLUT3_3.receipt.gasUsed}`)
  console.log(`tx_setLUT3_4 gas used is: ${tx_setLUT3_4.receipt.gasUsed}`)
}

const calcErrorPercent = (tested, actual) => {
  let diff = tested.minus(actual)
  errorPercent = (diff.mul(100).div(actual))
  return errorPercent.isNaN() ? new Decimal(0) : errorPercent  // return 0 if computation was a division by 0
}

const avgDecimal = (decArray) => { // calculate the mean from an array of Decimal objects
  let sum = Decimal(0)
  for (let dec of decArray) sum = sum.add(dec)
  return sum.div(decArray.length)
}

const gasAndError = (tx, res, actual) => {
  const gas = tx.receipt.gasUsed
  const errorPercent = calcErrorPercent(res, actual)
  console.log(`Gas used: ${gas}`)
  console.log(`Error: ${errorPercent}`)
  return {gas, errorPercent}
}

const formatName = (name) => {
  return name.replace("_callback", "").replace("bound ", "")
}

// Custom max and min for Decimals, since Decimal.js built-in max/min methods won't take an array argument
const maxDecimal = (decArray) => {
  return decArray.reduce((maximum, current) => { return current.greaterThan(maximum) ? current : maximum })
}

const minDecimal = (decArray) => {
  return decArray.reduce((minimum, current) => { return current.lessThan(minimum) ? current : minimum })
}

const randomBigNum = (min, max) => {
  min = new BigNumber(min)
  max = new BigNumber(max)
  const rand = BigNumber.random(100)  // random BigNumber to 100 DP precision

  const num = rand.multipliedBy(max.minus(min)).plus(min) // random BigNumber between min and max
  return num.toFixed(18)
}

module.exports = { 
  setLUTs,
  gasAndError,
  minDecimal, 
  maxDecimal, 
  avgDecimal, 
  randomBigNum,
  formatName
}
