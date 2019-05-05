pragma solidity ^0.5.0;

import "../contracts/DeciMath.sol";
import "truffle/DeployedAddresses.sol";
import "truffle/Assert.sol";

contract TestDeciMath {

 // initialize contract representations
  DeciMath decimath = DeciMath(DeployedAddresses.DeciMath());
  WrappedDeciMath wrappedDeciMath = new WrappedDeciMath();

  function beforeAll_setLookupTables_chunk1() public {
    decimath.setLUT1();
    decimath.setLUT2();
  }

  function beforeAll_setLookupTables_chunk2() public {
   decimath.setLUT3_1();
   decimath.setLUT3_2();
  }

  function beforeAll_setLookupTables_chunk3() public {
    decimath.setLUT3_3();
    decimath.setLUT3_4();
  }


/* ***** 2^x ALGORITHM  ***** */

function test_pow2_lowerEdge() public {
    Assert.equal(decimath.pow2(100000000000000000000), 200000000000000000000000000000000000000, "failed");
}

function test_pow2() public {
    Assert.equal(decimath.pow2(114426950408889634074), 221034183615129524962955556139274136635, "failed");
    Assert.equal(decimath.pow2(150000000000000000000), 282842712474619009760337744841939615714, "failed");
    Assert.equal(decimath.pow2(112345678912345678912), 217868374088380437351296077755627369930, "failed");
    Assert.equal(decimath.pow2(147522374589375956105), 278026759471356790224589509222216482784, "failed");
}

function test_pow2_upperEdge() public {
    Assert.equal(decimath.pow2(199999999999999999999), 399999999999999999997227411277760218762, "failed");
}

// out-of-bounds tests
 function test_pow2_lessThan1() public {
  TestRawCaller TestRawCaller = new TestRawCaller(address(wrappedDeciMath));
  WrappedDeciMath(address(TestRawCaller)).callPow2(0.9 ether);
  bool r = TestRawCaller.execute.gas(200000)();
  Assert.isFalse(r, "Should be false - func should revert");
}

function test_pow2_2orGreater() public {
  TestRawCaller TestRawCaller = new TestRawCaller(address(wrappedDeciMath));
  WrappedDeciMath(address(TestRawCaller)).callPow2(2 ether);
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

  function callPowBySquare18 (uint x, uint n) public {
    powBySquare18(x, n);
  }

  function callLog2 (uint x, uint precision) public {
    log_2(x, precision);
  }

  function callPow2 (uint x) public {
    pow2(x);
  }
}
