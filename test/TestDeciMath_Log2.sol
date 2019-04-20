pragma solidity ^0.5.0;

import "../contracts/DeciMath.sol";
import "truffle/DeployedAddresses.sol";
import "truffle/Assert.sol";

contract TestDeciMath {

 // initialize contract representations
  DeciMath decimath = DeciMath(DeployedAddresses.DeciMath());
  WrappedDeciMath wrappedDeciMath = new WrappedDeciMath();

  function setLookupTables() internal {
    decimath.setAllLUTs();
  }

/* ***** LOG2(x) - BASE-2 LOGARITHM ALGO  ***** */

function test_log2_upperEdge() public {
  setLookupTables();
    Assert.equal(decimath.log2(1999999999999999999, 99), 999999999999999999278652479556, "failed");
}

function test_log2_lowerEdge() public {
  setLookupTables();
    Assert.equal(decimath.log2(1 ether, 99), 0, "failed");
}

 function test_log2() public {
    setLookupTables();
    Assert.equal(decimath.log2(1100000000000000000, 99), 137503523749934908329043617236, "failed");
    Assert.equal(decimath.log2(1234512345123451234, 99), 303941263503238936812440378165, "failed");
    Assert.equal(decimath.log2(1987654321987654321, 99), 991066875955820193573663024629, "failed");
    Assert.equal(decimath.log2(1395000000123400000, 99), 480265122182081921161366921555, "failed");
 }

 // Log2 out-of-bounds tests
  function test_log2_lessThan1() public {
  setLookupTables();
   TestRawCaller TestRawCaller = new TestRawCaller(address(wrappedDeciMath));
   WrappedDeciMath(address(TestRawCaller)).callLog2(0.9 ether, 99);
   bool r = TestRawCaller.execute.gas(200000)();
   Assert.isFalse(r, "Should be false - func should revert");
 }

 function test_log2_2orGreater() public {
   setLookupTables();
   TestRawCaller TestRawCaller = new TestRawCaller(address(wrappedDeciMath));
   WrappedDeciMath(address(TestRawCaller)).callLog2(2 ether, 99);
   bool r = TestRawCaller.execute.gas(200000)();
   Assert.isFalse(r, "Should be false - func should revert");
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
