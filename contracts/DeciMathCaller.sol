pragma solidity ^0.5.0;
import './DeciMath.sol';

// Proxy contract, used in tests to call DeciMath funcs.
// Allows us to calculate actual gas used in DeciMath 'view' functions.
// Local calls to view functions use 0 gas, so to check gas we call them as part of a transaction, via this proxy contract.

// Example usage:
// An EOA sends tx to DeciMathCaller.callExp(n), which in turn calls exp(n) on deployed DeciMath instance.
// As the latter func is called within a tx, it uses gas.

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
