const BN = require('bn.js');
/* Convert a stringified 18DP number to its integer representation, in BN form.
 e.g.
 Input: "1.123456789987654321"  ---->  Output:  BN(1123456789987654321, 10) */

const makeBN18 = (stringNum) => {
  if (typeof stringNum !== String ) throw "makeBN18 input must be type string"

  const intPart = stringNum.split(".")[0]
  const fractionPart = stringNum.includes(".") ? stringNum.split(".")[1] : ""

  if (fractionPart.length > 18) throw "makeBigNum18 argument must have <= 18 decimal places"

  const trailingZeros = "0".repeat(18 - fractionPart.length)
  const bigNumArg = intPart + fractionPart + trailingZeros

  return new BN(bigNumArg, 10)
}

module.exports = { makeBN18: makeBN18 }
