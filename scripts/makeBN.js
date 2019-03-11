const BN = require('bn.js');

/* makeBN18 converts a stringified 18DP number to its integer representation, in BN form. All in base 10.
Example usage:
Input: '999.123456789987654321'  ---->  Output: new BN('999123456789987654321', 10)
Input: '1.000000000000000001'  ---->  Output: new BN('1000000000000000001', 10) */

const makeBN18 = (num) => {
  if (typeof num !== "number" ) {throw "makeBN18 input must be type Number"}
  const stringNum = num.toString();

  const intPart = stringNum.split(".")[0]
  const fractionPart = stringNum.includes(".") ? stringNum.split(".")[1] : ""

  if (fractionPart.length > 18) throw "makeBigNum18 argument must have <= 18 decimal places"

  const trailingZeros = "0".repeat(18 - fractionPart.length)
  const bigNumArg = intPart + fractionPart + trailingZeros

  return new BN(bigNumArg, 10)
}

module.exports = { makeBN18: makeBN18}
