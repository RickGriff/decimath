pragma solidity ^0.5.0;
import './DeciMath.sol';

// Proxy contract, used in tests to call DeciMath funcs.
// Allows us to calculate actual gas used in DeciMath 'view' functions.
// Local calls to view functions use 0 gas, so to check gas we call them as part of a transaction, via a proxy contract.

// Example usage:
// An EOA sends tx to DeciMathCaller.callExp(n), which in turn calls exp(n) on deployed DeciMath instance.
// As the latter func is called within a tx, it uses gas.

contract DeciMathCaller {
  DeciMath decimath;

  function setDeciMath(address _decimathAddr) public {
    decimath = DeciMath(_decimathAddr);
  }

  function callExp(uint n) public returns (uint) {
    decimath.exp(n);
  }

  function callExp18(uint x, uint n) public returns (uint) {
    decimath.exp18(x, n);
  }

  function callLog2(uint x, uint accuracy) public returns (uint) {
    decimath.log2(x, accuracy);
  }
}
