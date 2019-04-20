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

  /***** EXP(X) FOR INTEGER BASE, INTEGER EXPONENT - EXPONENTIATION-BY-SQUARING *****/
/*
  function test_expBySquare_xRaisedToZero() public {
    Assert.equal(decimath.expBySquare(0, 0), 1, "failed");
    Assert.equal(decimath.expBySquare(1 , 0), 1, "failed");
    Assert.equal(decimath.expBySquare(3  , 0), 1, "failed");
    Assert.equal(decimath.expBySquare(123456, 0), 1, "failed");
  }

  function test_expBySquare_OneRaisedToN() public {
    Assert.equal(decimath.expBySquare(1, 2), 1, "failed");
    Assert.equal(decimath.expBySquare(1, 456), 1, "failed");
  }

  function test_expBySquare_xRaisedToOne() public {
    Assert.equal(decimath.expBySquare(1, 1), 1, "failed");
    Assert.equal(decimath.expBySquare(3, 1), 3, "failed");
    Assert.equal(decimath.expBySquare(123456789123456789, 1), 123456789123456789, "failed");
  }

  function test_expBySquare() public {
    Assert.equal(decimath.expBySquare(2, 2), 4, "failed");
    Assert.equal(decimath.expBySquare(3, 5), 243 , "failed");
    Assert.equal(decimath.expBySquare(13, 11), 1792160394037, "failed");
    Assert.equal(decimath.expBySquare(34, 26), 6583424253569334549714045134721532297216, "failed");
  }


  /***** EXP(X) FOR 18DP BASE, INTEGER EXPONENT - EXPONENTIATION-BY-SQUARING *****/
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
    Assert.equal(decimath.expBySquare18(13000000000000000000, 11), 1792160394037000000000000000000, "failed");
    Assert.equal(decimath.expBySquare18(34000000000000000000, 26), 6583424253569334549714045134721532297216000000000000000000, "failed");
  }

  function test_exBySquare18_decBase() public {
    Assert.equal(decimath.expBySquare18(2979798700909879990, 2), 8879200297944208424, "failed");
    Assert.equal(decimath.expBySquare18(2009797000000989080, 5), 32791476202131049772, "failed");
    Assert.equal(decimath.expBySquare18(7300038383900000123, 7), 1104780514135769123208134, "failed");
    Assert.equal(decimath.expBySquare18(3400000000098787000, 26), 65834242585426507353941738055626, "failed");
  } */

  /***** EXP(X) FOR 38DP BASE, INTEGER EXPONENT - EXPONENTIATION-BY-SQUARING *****/
/*
  function test_expBySquare38_xRaisedToZero() public {
    Assert.equal(decimath.expBySquare38(0, 0), 100000000000000000000000000000000000000, "failed");
    Assert.equal(decimath.expBySquare38(100000000000000000000000000000000000000, 0), 100000000000000000000000000000000000000, "failed");
    Assert.equal(decimath.expBySquare38(200000000000000000000000000000000000000, 0), 100000000000000000000000000000000000000, "failed");
    Assert.equal(decimath.expBySquare38(123456789123456789123193483298438948849, 0), 100000000000000000000000000000000000000, "failed");
  }

  function test_expBySquare38_OneRaisedToN() public {
    Assert.equal(decimath.expBySquare38(100000000000000000000000000000000000000, 2), 100000000000000000000000000000000000000, "failed");
    Assert.equal(decimath.expBySquare38(100000000000000000000000000000000000000, 456), 100000000000000000000000000000000000000, "failed");
  }

  function test_expBySquare38_xRaisedToOne() public {
    Assert.equal(decimath.expBySquare38(100000000000000000000000000000000000000, 1), 100000000000000000000000000000000000000, "failed");
    Assert.equal(decimath.expBySquare38(300000000000000000000000000000000000000, 1), 300000000000000000000000000000000000000, "failed");
    Assert.equal(decimath.expBySquare38(123456789123456789000000000000000000000, 1), 123456789123456789000000000000000000000, "failed");
  }

  function test_expBySquare38_intBase() public {
    Assert.equal(decimath.expBySquare38(200000000000000000000000000000000000000, 2), 400000000000000000000000000000000000000, "failed");
    Assert.equal(decimath.expBySquare38(200000000000000000000000000000000000000, 3), 800000000000000000000000000000000000000, "failed");
  }

  function test_exBySquare38_decBase() public {
    Assert.equal(decimath.expBySquare38(297979870090987991312312323249890890855, 2), 887920029794420796538867255258503531540, "failed");
    Assert.equal(decimath.expBySquare38(100979700003993933000000098908000004453, 7), 107062784149734217627561839413537452094, "failed");
  } */

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
    /* Assert.equal(decimath.exp(0.1 ether), 1.105170918075647626 ether, "failed"); */
    Assert.equal(decimath.exp(0.5 ether), 1.648721270700128148 ether, "failed");
    Assert.equal(decimath.exp(0.9 ether), 2.459603111156949665 ether, "failed");
  }

  function test_exp_greaterThanOne() public {
    setLookupTables();
    Assert.equal(decimath.exp(2900000000000000000), 18.174145369443060943 ether, "failed");
    Assert.equal(decimath.exp(10 ether), 22026.465794806716516958 ether, "failed");
    Assert.equal(decimath.exp(1.5 ether), 4.481689070338064823 ether, "failed");
    Assert.equal(decimath.exp(55.34 ether), 1081077001816552122952189.288600113363186441 ether, "failed");
    Assert.equal(decimath.exp(80.987 ether), 148664476502354283725299215705723398.909785147302930507 ether, "failed");
  }
}
