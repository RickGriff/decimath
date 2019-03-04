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
}
