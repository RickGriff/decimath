pragma solidity ^0.5.0;
import './DeciMath.sol';

/* Proxy contract. ONLY NEEDED FOR TESTS. Used to call DeciMath functions.

The Proxy allows us to calculate actual gas used in DeciMath 'view' functions.
Local calls to view functions use 0 gas, so to check gas we call them as part of a transaction, via this proxy contract.

Example usage:
An EOA sends a tx to DeciMathCaller.callExp(n), which in turn calls exp(n) on the deployed DeciMath instance.
As the latter function is called from within a tx, it uses gas.  We can grab the gas used from the tx receipt.

See scripts/gasCalculator.js for gas and error tests.
*/

contract DeciMathCaller {
  DeciMath decimath;

  function setDeciMath(address _decimathAddr) public {
    decimath = DeciMath(_decimathAddr);
  }

  function callDecMul18(uint x, uint y) public returns (uint) {
    decimath.decMul18(x, y);
  }

  function callExp(uint n) public returns (uint) {
    decimath.exp(n);
  }

  function callExpBySquare18(uint b, uint x) public returns (uint) {
    decimath.expBySquare18(b, x);
  }

  function callExpBySquare38(uint b, uint x) public returns (uint) {
    decimath.expBySquare38(b, x);
  }

  function callExpTaylor(uint n) public returns (uint) {
    decimath.exp_taylor(n);
  }

  function callExp18(uint x, uint n) public returns (uint) {
    decimath.expBySquare18(x, n);
  }

  function callLog2(uint x, uint accuracy) public returns (uint) {
    decimath.log2(x, accuracy);
  }

  function callLn(uint x, uint accuracy) public returns (uint) {
    decimath.ln(x, accuracy);
  }

  function callTwoX(uint x) public returns (uint) {
    decimath.two_x(x);
  }

  function callPow(uint base, uint x) public returns (uint) {
    decimath.pow(base, x);
  }
}
