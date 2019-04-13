const BN = require('bn.js');
const Decimal = require('decimal.js');

/* Functions for converting stringified decimal numbers to integer representations, in BN form.

Why? Decimath contract functions require 'uint' representations of fixed-point decimals.
Since inputs can exceed the maximum safe integer in JS (~ 9e15), we use BigNums (BNs).

Example usage:
Input: makeBN18('999.123456789987654321') ---->  Output: new BN('999123456789987654321', 10)
Input: makeBN18('1.000000000000000001')  ---->  Output: new BN('1000000000000000001', 10) */

// convert a stringified decimal to a BN of arbitrary significant figures after the decimal point
const makeBN = (strNum, sigFigures) => {
  if (typeof strNum !== "string" ) { throw "input must be type String" }

  const intPart = strNum.split(".")[0]
  const fractionPart = strNum.includes(".") ? strNum.split(".")[1] : ""

  if (fractionPart.length > sigFigures) throw "argument must have <= " + sigFigures + " decimal places"

  const trailingZeros = "0".repeat(sigFigures - fractionPart.length)
  const bigNumArg = intPart + fractionPart + trailingZeros
  return new BN(bigNumArg, 10)
}

const makeBN18 = (strNum) => {
return makeBN(strNum, 18)
}

const makeBN20 = (strNum) => {
return makeBN(strNum, 20)
}

const makeBN38 = (strNum) => {
return makeBN(strNum, 38)
}

// convert a BN uint representation to a  Decimal object  with the same number of significant figures
const makeDecimal = (num, digits) => {
  let strBN = num.toString();
  let fractPart;
  let intPart;
  let resNum;

  if (strBN.length <= digits) {
    const fractPartZeros = "0".repeat(digits - strBN.length)
    fractPart = fractPartZeros  + strBN
    resNum = new Decimal ("0." + fractPart)

  } else if (strBN.length > digits) {
    fractPart = strBN.slice(-digits) // grab last 38 digits, after decimal point
    intPart = strBN.slice(0, strBN.length - digits) // grab digits preceding decimal point
    resNum = new Decimal (intPart + "." + fractPart)
  }
  return resNum
}

const makeDecimal38 = (num) => {
  return makeDecimal(num, 38)
}

const makeDecimal18 = (num) => {
  return makeDecimal(num, 18)
}

module.exports = {
  makeBN: makeBN,
  makeBN18: makeBN18,
  makeBN20: makeBN20,
  makeBN38: makeBN38,
  makeDecimal: makeDecimal,
  makeDecimal18: makeDecimal18,
  makeDecimal38: makeDecimal38
}
