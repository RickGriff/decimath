pragma solidity ^0.5.0;

import "../contracts/DeciMath.sol";
import "truffle/DeployedAddresses.sol";
import "truffle/Assert.sol";

contract TestDeciMath {

  // initialize contract representations
  DeciMath decimath = DeciMath(DeployedAddresses.DeciMath());

  function setLookupTables() internal {
    decimath.setAllLUTs();

  }

  /*  ***** EXP(X) FOR INTEGER EXPONENT - EXPONENTIATION-BY-SQUARING ALGORITHM ***** */
/*
  function test_expBySquare18_xRaisedToZero() public {
    Assert.equal(decimath.expBySquare18(0, 0), 1 ether, "failed");
    Assert.equal(decimath.expBySquare18(1 ether, 0), 1 ether, "failed");
    Assert.equal(decimath.expBySquare18(3  ether, 0), 1 ether, "failed");
    Assert.equal(decimath.expBySquare18(123456789123456789, 0), 1 ether, "failed");
  }

  function test_expBySquare18_OneRaisedToN() public {
    Assert.equal(decimath.expBySquare18(1 ether ,2), 1 ether, "failed");
    Assert.equal(decimath.expBySquare18(1 ether , 456), 1 ether, "failed");
  }

  function test_expBySquare18_xRaisedToOne() public {
    Assert.equal(decimath.expBySquare18(1 ether, 1), 1 ether, "failed");
    Assert.equal(decimath.expBySquare18(3 ether, 1), 3 ether, "failed");
    Assert.equal(decimath.expBySquare18(123456789123456789, 1), 123456789123456789, "failed");
  }

  function test_expBySquare18_intBase() public {
    Assert.equal(decimath.expBySquare18(2000000000000000000, 2), 4000000000000000000, "failed");
    Assert.equal(decimath.expBySquare18(2000000000000000000, 5), 32000000000000000000, "failed");
    Assert.equal(decimath.expBySquare18(3000000000000000000, 3), 27000000000000000000, "failed");
    Assert.equal(decimath.expBySquare18(13000000000000000000, 11), 1792160394037000000000000000000, "failed");
    Assert.equal(decimath.expBySquare18(34000000000000000000, 26), 6583424253569334549714045134721532297216000000000000000000, "failed");
  } */

  //TODO - expBySquare18 Decimal Base


  /* ***** EXP(X) FOR FIXED-POINT EXPONENT  ***** */

  function test_exp_basics() public {
    setLookupTables();
    Assert.equal(decimath.exp(0), 1 ether, "failed");
    Assert.equal(decimath.exp(1 ether), 2.718281828459045234 ether, "failed");
  }

  function test_exp_smallestPositive() public {
    setLookupTables();
    Assert.equal(decimath.exp(0.000000000000000001 ether), 1.000000000000000001 ether, "failed");
  }

  function test_exp_lessThanOne() public {
    setLookupTables();
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
}
