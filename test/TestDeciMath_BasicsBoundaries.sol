pragma solidity ^0.5.0;

import "../contracts/DeciMath.sol";
import "truffle/DeployedAddresses.sol";
import "truffle/Assert.sol";

contract TestDeciMath {
DeciMath decimath = DeciMath(DeployedAddresses.DeciMath());
WrappedDeciMath wrappedDeciMath = new WrappedDeciMath();

uint TEN20 = 10**20;
uint TEN30 = 10**30;
uint TEN38 = 10**38;


   // 18DP Reversion tests - Overflow, Boundary & divByZero
   function test_decMul18_overflow() public {
    // instantiate a TestRawCaller that points to a wrapped DeciMath contract
    TestRawCaller TestRawCaller = new TestRawCaller(address(wrappedDeciMath));
    // Prime the proxy: call the DeciMath func 'add', on the TestRawCaller instance
    WrappedDeciMath(address(TestRawCaller)).calldecMul18(2**128, 2**128);
    //execute the raw call - r is false if it reverts.
    bool r = TestRawCaller.execute.gas(200000)();
    Assert.isFalse(r, "Should be false - func should revert");
  }

  function test_decMul18_overflow_boundary() public {
    TestRawCaller TestRawCaller = new TestRawCaller(address(wrappedDeciMath));
    WrappedDeciMath(address(TestRawCaller)).calldecMul18(2**256 - 0.5 ether, 1);
    bool r = TestRawCaller.execute.gas(200000)();
    Assert.isFalse(r, "Should be false - func should revert");
  }

  function test_decMul18_under_boundary() public {
    TestRawCaller TestRawCaller = new TestRawCaller(address(wrappedDeciMath));
    WrappedDeciMath(address(TestRawCaller)).calldecMul18(2**256 - 0.5 ether - 1, 1);
    bool r = TestRawCaller.execute.gas(200000)();
    Assert.isTrue(r, "Should be true - func should execute successfully");
  }

  function test_decDiv18_divByZero() public {
    TestRawCaller TestRawCaller = new TestRawCaller(address(wrappedDeciMath));
    WrappedDeciMath(address(TestRawCaller)).calldecDiv18(5 ether, 0);
    bool r = TestRawCaller.execute.gas(200000)();
    Assert.isFalse(r, "Should be false - func should revert");
  }

  function test_decDiv18_overflow() public {
    TestRawCaller TestRawCaller = new TestRawCaller(address(wrappedDeciMath));
    WrappedDeciMath(address(TestRawCaller)).calldecDiv18(2**197, 1);
    bool r = TestRawCaller.execute.gas(200000)();
    Assert.isFalse(r, "Should be false - func should revert");
  }

  function test_decDiv18_underBoundary() public {
    TestRawCaller TestRawCaller = new TestRawCaller(address(wrappedDeciMath));
    WrappedDeciMath(address(TestRawCaller)).calldecDiv18(2**196, 1);
    bool r = TestRawCaller.execute.gas(200000)();
    Assert.isTrue(r, "Should be true - func should execute successfully");
   }
}
/* ***** TEST HELPER CONTRACTS  ***** */

/* TestRawCaller is a proxy contract, used to test for reversion.
Raw calls in Solidity return a boolean -- true if successful execution, false if the call reverts.

Usage in tests:
-A TestRawCaller instance R points to a target contract A.
-Calling A's function 'someFunc' on R triggers R's fallback function, which stores the someFunc call data in R's storage.
-R.execute() executes the raw call A.someFunc, which returns a boolean. */
 contract TestRawCaller {
   address public target;
  bytes data;

  constructor (address _target) public {
    target = _target;
  }

  //fallback function - stores the target's func call data
  function() external {
    data = msg.data;
  }

  // execute the raw call to target's func
  function execute() public returns (bool success) {
    bytes memory val;
    (success, val) =  target.call(data);
    // target.call(data) returns a tuple. Better way to just grab the first elem of the tuple in Solidity ...?
    return success;
  }
}

/* A wrapper contract is also needed for the reversion tests.
The Wrapper contract inherits from the target contract.
The TestRawCaller must point to an instance of the Wrapper contract, with funcs that call the target's funcs.

Reason: https://github.com/trufflesuite/truffle/issues/1001 */
 contract WrappedDeciMath is DeciMath {

    function calldecMul18 (uint x, uint y) public {
      decMul18(x, y);
    }

    function calldecDiv18 (uint x, uint y) public {
      decDiv18(x, y);
    }

  function callExp (uint n) public {
      exp(n);
  }
  function callexpBySquare18 (uint x, uint n) public {
    expBySquare18(x, n);
  }

  function callLog2 (uint x, uint precision) public {
    log2(x, precision);
  }

  function callTwoX (uint x) public {
    two_x(x);
  }
}
