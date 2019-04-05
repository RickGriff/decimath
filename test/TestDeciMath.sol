pragma solidity ^0.5.0;

import "../contracts/DeciMath.sol";
import "truffle/DeployedAddresses.sol";
import "truffle/Assert.sol";

contract TestDeciMath {

 // initialize contract representations
  DeciMath decimath = DeciMath(DeployedAddresses.DeciMath());
  WrappedDeciMath wrappedDeciMath = new WrappedDeciMath();

  uint TEN20 = 10**20;
  uint TEN30 = 10**30;
  uint TEN38 = 10**38;

  function setLookupTables() internal {
    decimath.setLUT1();
    decimath.setLUT2();
    decimath.setLUT3();
  }

  /* ***** BASIC OPERATIONS ***** */

   function test_decMul18_basic() public {
    Assert.equal(decimath.decMul18(0,0), 0, "failed");
    Assert.equal(decimath.decMul18(0, 1 ether), 0, "failed");
    Assert.equal(decimath.decMul18(1 ether, 0 ), 0, "failed");
    Assert.equal(decimath.decMul18(1 ether, 1 ether), 1 ether, "failed");
  }

  function test_decMul18_fractions() public {
    Assert.equal(decimath.decMul18(1 ether, 4.5 ether), 4.5 ether, "failed");
    Assert.equal(decimath.decMul18(1 ether, 4.123456789123456789 ether ), 4.123456789123456789 ether, "failed");

    Assert.equal(decimath.decMul18(4.00 ether, 1.111111111111111111 ether), 4.444444444444444444 ether, "failed");
    Assert.equal(decimath.decMul18(3.00 ether, 0.5 ether), 1.50 ether, "failed");
    Assert.equal(decimath.decMul18(5.555555555555555555 ether, 0.2 ether), 1.111111111111111111 ether, "failed");

    Assert.equal(decimath.decMul18(439.453 ether, 0.23 ether), 101.07419 ether, "failed");
  }

  function test_decMul18_rounding() public {
    // Should round up -  the output's digit after cutoff is >= 5
    Assert.equal(decimath.decMul18(1.000000000000000005 ether, 0.1 ether), 0.100000000000000001 ether, "failed");
    Assert.equal(decimath.decMul18(9.999999999999999999 ether, 0.1 ether), 1 ether, "failed");
    Assert.equal(decimath.decMul18(999.999999999999999999 ether, 0.1 ether), 100 ether, "failed");
    Assert.equal(decimath.decMul18(0.0000000007 ether, 0.0000000008 ether), 0.000000000000000001 ether, "failed");
    // Should round down - the output's digit after cutoff is < 5
    Assert.equal(decimath.decMul18(1.000000000000000004 ether, 0.1 ether), 0.1 ether, "failed");
    Assert.equal(decimath.decMul18(4.444444444444444444 ether, 0.1 ether), 0.444444444444444444 ether, "failed");
    Assert.equal(decimath.decMul18(444.444444444444444444 ether, 0.1 ether), 44.444444444444444444 ether, "failed");
    Assert.equal(decimath.decMul18(0.0000000007 ether, 0.0000000007 ether), 0, "failed");
  }

  function test_decDiv18_basic() public {
    Assert.equal(decimath.decDiv18(0, 1 ether), 0, "failed");
    Assert.equal(decimath.decDiv18(1 ether, 1 ether), 1 ether, "failed");
  }

  function test_decDiv18_fractions() public {
    Assert.equal(decimath.decDiv18(4.5 ether, 1.00 ether), 4.5 ether, "failed");
    Assert.equal(decimath.decDiv18(4.123456789123456789 ether, 1 ether), 4.123456789123456789 ether, "failed");

    Assert.equal(decimath.decDiv18(6.666666666666666666 ether, 6 ether), 1.111111111111111111 ether, "failed");

    Assert.equal(decimath.decDiv18(6 ether, 4 ether), 1.5 ether, "failed");
    Assert.equal(decimath.decDiv18(5.555555555555555555 ether, 1.25 ether), 4.444444444444444444 ether, "failed");

    Assert.equal(decimath.decDiv18(6 ether, 0.2 ether), 30 ether, "failed");
    Assert.equal(decimath.decDiv18(19110.56 ether, 22.6 ether ), 845.60 ether, "failed");
  }

  function test_decDiv18_rounding() public {
    // Should round up - the output's digit after cutoff is >= 5
    Assert.equal(decimath.decDiv18(0.000000000000000005 ether, 10 ether), 0.000000000000000001 ether, "failed");
    Assert.equal(decimath.decDiv18(9.999999999999999999 ether, 10 ether), 1 ether, "failed");
    Assert.equal(decimath.decDiv18(999.999999999999999999 ether, 10 ether), 100 ether, "failed");
    Assert.equal(decimath.decDiv18(0.000000002 ether, 4000000000 ether), 0.000000000000000001 ether, "failed");
    // Should round down - the output's digit after cutoff is < 5
    Assert.equal(decimath.decDiv18(1.000000000000000004 ether, 10 ether), 0.1 ether, "failed");
    Assert.equal(decimath.decDiv18(4.444444444444444444 ether, 10 ether), 0.444444444444444444 ether, "failed");
    Assert.equal(decimath.decDiv18(444.444444444444444444 ether, 10 ether), 44.444444444444444444 ether, "failed");
    Assert.equal(decimath.decDiv18(0.0000000016 ether, 4000000000 ether), 0, "failed");
  }

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

   /* ***** EXP(X) FOR INTEGER EXPONENT - EXPONENTIATION-BY-SQUARING ALGORITHM ***** */

  //Test expBySquare18 function
  // Integer tests

   function test_expBySquare18_basics() public {
    // x^0 --> 0
    Assert.equal(decimath.expBySquare18(0, 0), 1 ether, "failed");
    Assert.equal(decimath.expBySquare18(1 ether, 0), 1 ether, "failed");
    Assert.equal(decimath.expBySquare18(3  ether, 0), 1 ether, "failed");
    Assert.equal(decimath.expBySquare18(123456789123456789, 0), 1 ether, "failed");
    // 1^n --> 1
    Assert.equal(decimath.expBySquare18(1 ether ,2), 1 ether, "failed");
    Assert.equal(decimath.expBySquare18(1 ether , 456), 1 ether, "failed");
    // x^1 --> x
    Assert.equal(decimath.expBySquare18(1 ether, 1), 1 ether, "failed");
    Assert.equal(decimath.expBySquare18(3 ether, 1), 3 ether, "failed");
    Assert.equal(decimath.expBySquare18(123456789123456789, 1), 123456789123456789, "failed");
  }

  // expBySquare18 func with an integer base

  function test_expBySquare18_intBase() public {
    Assert.equal(decimath.expBySquare18(2000000000000000000, 2), 4000000000000000000, "failed");
    Assert.equal(decimath.expBySquare18(2000000000000000000, 5), 32000000000000000000, "failed");
    Assert.equal(decimath.expBySquare18(3000000000000000000, 3), 27000000000000000000, "failed");
    Assert.equal(decimath.expBySquare18(13000000000000000000, 11), 1792160394037000000000000000000, "failed");
    Assert.equal(decimath.expBySquare18(34000000000000000000, 26), 6583424253569334549714045134721532297216000000000000000000, "failed");
  }


   /* ***** EXP(X) FOR FIXED-POINT EXPONENT  ***** */

  function test_exp_basics() public {
    Assert.equal(decimath.exp(0), 1 ether, "failed");
    Assert.equal(decimath.exp(1 ether), 2.718281828459045234 ether, "failed");
  }

  function test_exp_smallestPositive() public {
    Assert.equal(decimath.exp(0.000000000000000001 ether), 1.000000000000000001 ether, "failed");

  }

  function test_exp_lessThanOne() public {
    Assert.equal(decimath.exp(0.1 ether), 1.105170918075647626 ether, "failed");
    Assert.equal(decimath.exp(0.5 ether), 1.648721270700128148 ether, "failed");
    Assert.equal(decimath.exp(0.9 ether), 2.459603111156949665 ether, "failed");
  }

   function test_exp_greaterThanOne() public {
    setLookupTables();
    Assert.equal(decimath.exp(2900000000000000000), 18.174145369443060943 ether, "failed");
    Assert.equal(decimath.exp(10 ether), 22026.465794806716516958 ether, "failed");
    Assert.equal(decimath.exp(1.5 ether), 4.481689070338064823 ether, "failed");
    Assert.equal(decimath.exp(55.34 ether), 1081077.001816552122952189 ether, "failed");
  Assert.equal(decimath.exp(80.987 ether), 148664476502354283.725299215705723399 ether, "failed");
  }


 /* ***** HELPER FUNCTIONS  ***** */

  function test_countDigits() public {
   Assert.equal(decimath.countDigits(7), 1, "failed");
   Assert.equal(decimath.countDigits(123456789), 9, "failed");
   Assert.equal(decimath.countDigits(1234567891234567891234567891234567890000), 40, "failed");
 }

  function test_convert38To18DP_basic() public {
  //converts 38DP Num to 18DP num
  Assert.equal(decimath.convert38To18DP(1 ether * TEN20),  1 ether, "failed");
  Assert.equal(decimath.convert38To18DP(0),  0, "failed");

  }

  function test_convert38To18DP_roundDown() public {
    // Round down when 20th digit from the right  < 5
  Assert.equal(decimath.convert38To18DP(100000000000000000040000000000000000000),  1 ether, "failed");
  Assert.equal(decimath.convert38To18DP(90000000012345000000000000000000939648390485092893288),  900000000123450000000000000000009, "failed");
  }

  function test_convert38To18DP_roundUp() public {
    //Round up when 20th digit from right >= 5
  Assert.equal(decimath.convert38To18DP(5000000000000000000000000009999974974545353448935455),  50000000000000000000000000100000, "failed");
  Assert.equal(decimath.convert38To18DP(100000000000000000050000000000000000000), 1000000000000000001, "failed" );
  }


   function test_convert30To20DP_basic() public {
  //converts 38DP Num to 20DP num
  Assert.equal(decimath.convert30To20DP(TEN30), 100 ether, "failed");
  Assert.equal(decimath.convert30To20DP(0),  0, "failed");

  }

  function test_convert30To20DP_roundDown() public {
    // Round down when 10th digit from the right  < 5
  Assert.equal(decimath.convert30To20DP(1000000000000000000004000000000),  100 ether, "failed");
  Assert.equal(decimath.convert30To20DP(900000000123450000000000000000000093964839042),  90000000012345000000000000000000009, "failed");
  }

  function test_convert30To20DP_roundUp() public {
    //Round up when 18th digit from right >= 5
  Assert.equal(decimath.convert30To20DP(500000000000000000000000000999996497412383),  50000000000000000000000000100000, "failed");
  Assert.equal(decimath.convert30To20DP(10000000000000000005000000000), 1000000000000000001, "failed" );
  }

  // floor(x) tests
    function test_floor() public {
   Assert.equal(decimath.floor(150000000000000000000), 100000000000000000000, "failed");
   Assert.equal(decimath.floor(55512345678900000000000), 55500000000000000000000, "failed");
  }

  function test_floor_lessThan1() public {
    Assert.equal(decimath.floor(12345), 0, "failed");
    Assert.equal(decimath.floor(9999999999999999999), 0, "failed");
  }



 /* ***** LOOKUP TABLE SETTERS  ***** */

 function test_LookupTable1() public {
    setLookupTables();
    Assert.equal(decimath.ith_term(0), 0, "failed");
    Assert.equal(decimath.ith_term(1), 70710678118654752440084436210484903927, "failed");
    Assert.equal(decimath.ith_term(99), 99999999999999999999999999999890640660, "failed");
  }

  function test_LookupTable2() public {
    setLookupTables();
    Assert.equal(decimath.powersOfTwo(0), 200000000000000000000000000000000000000, "failed");
    Assert.equal(decimath.powersOfTwo(1), 50000000000000000000000000000000000000, "failed");
    Assert.equal(decimath.powersOfTwo(99), 157772181, "failed");
  }

   function test_LookupTable3() public {
    setLookupTables();
    Assert.equal(decimath.term_2_x(0), 10717734625362931642130063250233420229, "failed");
    Assert.equal(decimath.term_2_x(1), 10069555500567188088326982141132397855, "failed");
    Assert.equal(decimath.term_2_x(36), 10000000000000000000000000000000000001, "failed");
  }



/* ***** LOG2(x) - BASE-2 LOGARITHM ALGO  ***** */

function test_log2_upperEdge() public {
  setLookupTables();
    Assert.equal(decimath.log2(1999999999999999999, 99), 999999999999999999, "failed");
}

function test_log2_lowerEdge() public {
  setLookupTables();
    Assert.equal(decimath.log2(1 ether, 99), 0, "failed");
}

  // Log2 out-of-bounds tests
  function test_log2_lessThan1() public {
    TestRawCaller TestRawCaller = new TestRawCaller(address(wrappedDeciMath));
    WrappedDeciMath(address(TestRawCaller)).callLog2(0.9 ether, 99);
    bool r = TestRawCaller.execute.gas(200000)();
    Assert.isFalse(r, "Should be false - func should revert");
  }

  function test_log2_2orGreater() public {
    TestRawCaller TestRawCaller = new TestRawCaller(address(wrappedDeciMath));
    WrappedDeciMath(address(TestRawCaller)).callLog2(2 ether, 99);
    bool r = TestRawCaller.execute.gas(200000)();
    Assert.isFalse(r, "Should be false - func should revert");
  }

 function test_log2() public {
    Assert.equal(decimath.log2(1100000000000000000, 99), 137503523749934908, "failed");
    Assert.equal(decimath.log2(1234512345123451234, 99), 303941263503238937, "failed");
    Assert.equal(decimath.log2(1987654321987654321, 99), 991066875955820194, "failed");
    Assert.equal(decimath.log2(1995000000000000000, 99), 996388746447621087, "failed");
 }



/* ***** 2^x ALGORIHTM  ***** */

function test_two_x_lowerEdge() public {
  setLookupTables();
    Assert.equal(decimath.two_x(100000000000000000000), 200000000000000000000000000000000000000, "failed");
}

function test_two_x() public {
  setLookupTables();
    Assert.equal(decimath.two_x(150000000000000000000), 282842712474619009760337744841939615714, "failed");

    Assert.equal(decimath.two_x(112345678912345678912), 217868374088380437351296077755627369930, "failed");

    Assert.equal(decimath.two_x(147522374589375956105), 278026759471356790224589509222216482784, "failed");
}

function test_two_x_upperEdge() public {
  setLookupTables();
    Assert.equal(decimath.two_x(199999999999999999999), 399999999999999999997227411277760218762, "failed");
}

// out-of-bounds tests
 function test_two_x_lessThan1() public {
  TestRawCaller TestRawCaller = new TestRawCaller(address(wrappedDeciMath));
  WrappedDeciMath(address(TestRawCaller)).callTwoX(0.9 ether);
  bool r = TestRawCaller.execute.gas(200000)();
  Assert.isFalse(r, "Should be false - func should revert");
}

function test_two_x_2orGreater() public {
  TestRawCaller TestRawCaller = new TestRawCaller(address(wrappedDeciMath));
  WrappedDeciMath(address(TestRawCaller)).callTwoX(2 ether);
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
