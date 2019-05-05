pragma solidity ^0.5.0;

import "../contracts/DeciMath.sol";
import "truffle/DeployedAddresses.sol";
import "truffle/Assert.sol";

contract TestDeciMath {

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

/* ***** Ln(x) - NATURAL LOGARITHM ALGO  ***** */

function test_ln_basics() public {
  Assert.equal(decimath.ln(2718281828459045235, 99), 1000000000000000000, "failed");
}

function test_ln_edge() public {
  Assert.equal(decimath.ln(1000000000000000001, 99), 1, "failed");
}

function test_ln() public {
  Assert.equal(decimath.ln(1234512345123451234, 99), 210676029853097475, "failed");
  Assert.equal(decimath.ln(1987654321987654321, 99), 686955210815129821, "failed");
}

function test_ln_large_input() public {
  Assert.equal(decimath.ln(87897878977971234512345123451234, 99), 32107196790385103322, "failed");
  Assert.equal(decimath.ln(100000000000000000000000000000000000000000000000, 99), 66774967696827324837, "failed");
}
}
