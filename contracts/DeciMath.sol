pragma solidity ^0.5.0;

import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
contract DeciMath {
  using SafeMath for uint;

  uint constant QUINT = 10**18;

  // 2 DP functions
  function decMul2(uint x, uint y) public pure returns (uint decProduct) {
    uint prod_xy = x.mul(y);
    decProduct = prod_xy.add(100 / 2) / 100;
  }
  function decDiv2(uint x, uint y) public pure returns (uint decQuotient) {
    uint prod_100x = x.mul(100);
    decQuotient = prod_100x.add(y / 2) / y;
  }

  // 18 DP Functions
  function decMul18(uint x, uint y) public pure returns (uint decProd) {
    uint prod_xy = x.mul(y);
    decProd = prod_xy.add(QUINT / 2) / QUINT;
  }

  function decDiv18(uint x, uint y) public pure returns (uint decQuotient) {
    uint prod_xQuint = x.mul(QUINT);
    decQuotient = prod_xQuint.add(y / 2) / y;
  }

  //integer base, integer exponent
  function expNoDec(uint x, uint n) public pure returns (uint) {
    if (n == 0)
      return 1;

    uint y = 1;

    while (n > 1)
      if (n % 2 == 0) {
        x = x.mul(x);
        n = n / 2;
      } else if (n % 2 != 0) {
        y = x.mul(y);
        x = x.mul(x);
        n = (n - 1)/2;
      }
    return x.mul(y);
  }

  //2DP base, positive integer exponent n
  function exp2(uint x, uint n) public pure returns (uint) {
    if (n == 0)
      return 100;

    uint y = 100;

    while (n > 1)
      if (n % 2 == 0) {
        x = decMul2(x, x);
        n = n / 2;
      } else if (n % 2 != 0) {
        y = decMul2(x, y);
        x = decMul2(x, x);
        n = (n - 1)/2;
      }
    return decMul2(x, y);
  }

  //18DP base, positive integer exponent n
  function exp18(uint base, uint n) public pure returns (uint) {
    if (n == 0)
      return QUINT;

    uint y = QUINT;

    while (n > 1)
      if (n % 2 == 0) {
        base = decMul18(base, base);
        n = n / 2;
      } else if (n % 2 != 0) {
        y = decMul18(base, y);
        base = decMul18(base, base);
        n = (n - 1)/2;
      }
    return decMul18(base, y);
  }

  // e^n for natural exponent.
  // Exponent 'n' is  fixed point 18DP, represented by a uint.
  function exp(uint n) public pure returns (uint) {
    uint tolerance = 1;
    uint term = QUINT;
    uint sum = QUINT;
    uint i = 0;

    while (term > tolerance) { // stop computing terms when smallest term reaches 10^-18 in size
       i += QUINT;
      term = decDiv18( decMul18(term, n), i );
      sum += term;
    }
    return sum;
  }
}
