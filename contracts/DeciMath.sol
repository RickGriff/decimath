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

  function exp18(uint x, uint n) public pure returns (uint) {
    if (n == 0)
      return QUINT;

    uint y = QUINT;

    while (n > 1)
      if (n % 2 == 0) {
        x = decMul18(x, x);
        n = n / 2;
      } else if (n % 2 != 0) {
        y = decMul18(x, y);
        x = decMul18(x, x);
        n = (n - 1)/2;
      }
    return decMul18(x, y);
  }
}
