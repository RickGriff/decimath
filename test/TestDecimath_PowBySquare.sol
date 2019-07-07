pragma solidity ^0.5.0;

import "../contracts/DeciMath.sol";
import "truffle/DeployedAddresses.sol";
import "truffle/Assert.sol";

contract TestDeciMath {

  // initialize contract representations
  DeciMath decimath = DeciMath(DeployedAddresses.DeciMath());

  // break up LUT setters into two groups - avoids the *test setup* hitting gas limit
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

  /*****  EXPONENTIATION-BY-SQUARING FOR INTEGER BASE, INTEGER EXPONENT *****/
  
  function test_powBySquare_xRaisedToZero() public {
    Assert.equal(decimath.powBySquare(0, 0), 1, "failed");
    Assert.equal(decimath.powBySquare(1 , 0), 1, "failed");
    Assert.equal(decimath.powBySquare(3  , 0), 1, "failed");
    Assert.equal(decimath.powBySquare(123456, 0), 1, "failed");
  }

  function test_powBySquare_OneRaisedToN() public {
    Assert.equal(decimath.powBySquare(1, 2), 1, "failed");
    Assert.equal(decimath.powBySquare(1, 456), 1, "failed");
  }

  function test_powBySquare_xRaisedToOne() public {
    Assert.equal(decimath.powBySquare(1, 1), 1, "failed");
    Assert.equal(decimath.powBySquare(3, 1), 3, "failed");
    Assert.equal(decimath.powBySquare(123456789123456789, 1), 123456789123456789, "failed");
  }

  function test_powBySquare() public {
    Assert.equal(decimath.powBySquare(2, 2), 4, "failed");
    Assert.equal(decimath.powBySquare(3, 5), 243 , "failed");
    Assert.equal(decimath.powBySquare(13, 11), 1792160394037, "failed");
    Assert.equal(decimath.powBySquare(34, 26), 6583424253569334549714045134721532297216, "failed");
  }

  /*****EXPONENTIATION-BY-SQUARING FOR 18DP BASE, INTEGER EXPONENT *****/

 function test_powBySquare18_xRaisedToZero() public {
    Assert.equal(decimath.powBySquare18(0, 0), 1 ether, "failed");
    Assert.equal(decimath.powBySquare18(1 ether, 0), 1 ether, "failed");
    Assert.equal(decimath.powBySquare18(3  ether, 0), 1 ether, "failed");
    Assert.equal(decimath.powBySquare18(123456789123456789, 0), 1 ether, "failed");
  }

  function test_powBySquare18_OneRaisedToN() public {
    Assert.equal(decimath.powBySquare18(1 ether ,2), 1 ether, "failed");
    Assert.equal(decimath.powBySquare18(1 ether , 456), 1 ether, "failed");
  }

  function test_powBySquare18_xRaisedToOne() public {
    Assert.equal(decimath.powBySquare18(1 ether, 1), 1 ether, "failed");
    Assert.equal(decimath.powBySquare18(3 ether, 1), 3 ether, "failed");
    Assert.equal(decimath.powBySquare18(123456789123456789, 1), 123456789123456789, "failed");
  }

  function test_powBySquare18_intBase() public {
    Assert.equal(decimath.powBySquare18(2000000000000000000, 2), 4000000000000000000, "failed");
    Assert.equal(decimath.powBySquare18(2000000000000000000, 5), 32000000000000000000, "failed");
    Assert.equal(decimath.powBySquare18(13000000000000000000, 11), 1792160394037000000000000000000, "failed");
    Assert.equal(decimath.powBySquare18(34000000000000000000, 26), 6583424253569334549714045134721532297216000000000000000000, "failed");
  }

  function test_powBySquare18_decBase() public {
    Assert.equal(decimath.powBySquare18(2979798700909879990, 2), 8879200297944208424, "failed");
    Assert.equal(decimath.powBySquare18(2009797000000989080, 5), 32791476202131049772, "failed");
    Assert.equal(decimath.powBySquare18(7300038383900000123, 7), 1104780514135769123208134, "failed");
    Assert.equal(decimath.powBySquare18(3400000000098787000, 26), 65834242585426507353941738055626, "failed");
  } 

  /***** EXPONENTIATION-BY-SQUARING FOR 38DP BASE, INTEGER EXPONENT  *****/

   function test_powBySquare38_xRaisedToZero() public {
    Assert.equal(decimath.powBySquare38(0, 0), 100000000000000000000000000000000000000, "failed");
    Assert.equal(decimath.powBySquare38(100000000000000000000000000000000000000, 0), 100000000000000000000000000000000000000, "failed");
    Assert.equal(decimath.powBySquare38(200000000000000000000000000000000000000, 0), 100000000000000000000000000000000000000, "failed");
    Assert.equal(decimath.powBySquare38(123456789123456789123193483298438948849, 0), 100000000000000000000000000000000000000, "failed");
  }

  function test_powBySquare38_OneRaisedToN() public {
    Assert.equal(decimath.powBySquare38(100000000000000000000000000000000000000, 2), 100000000000000000000000000000000000000, "failed");
    Assert.equal(decimath.powBySquare38(100000000000000000000000000000000000000, 456), 100000000000000000000000000000000000000, "failed");
  }

  function test_powBySquare38_xRaisedToOne() public {
    Assert.equal(decimath.powBySquare38(100000000000000000000000000000000000000, 1), 100000000000000000000000000000000000000, "failed");
    Assert.equal(decimath.powBySquare38(300000000000000000000000000000000000000, 1), 300000000000000000000000000000000000000, "failed");
    Assert.equal(decimath.powBySquare38(123456789123456789000000000000000000000, 1), 123456789123456789000000000000000000000, "failed");
  }

  function test_powBySquare38_intBase() public {
    Assert.equal(decimath.powBySquare38(200000000000000000000000000000000000000, 2), 400000000000000000000000000000000000000, "failed");
    Assert.equal(decimath.powBySquare38(200000000000000000000000000000000000000, 3), 800000000000000000000000000000000000000, "failed");
  }

  function test_powBySquare38_decBase() public {
    Assert.equal(decimath.powBySquare38(297979870090987991312312323249890890855, 2), 887920029794420796538867255258503531540, "failed");
    Assert.equal(decimath.powBySquare38(100979700003993933000000098908000004453, 7), 107062784149734217627561839413537452094, "failed");
  } 
}