pragma solidity ^0.5.0;

import "../contracts/DeciMath.sol";
import "truffle/DeployedAddresses.sol";
import "truffle/Assert.sol";

contract TestDeciMath {

  DeciMath decimath = DeciMath(DeployedAddresses.DeciMath());

  function setLookupTables() internal {
    decimath.setAllLUTs();
  }

/* ***** Ln(x) - NATURAL LOGARITHM ALGO  ***** */

function test_ln_basics() public {
  setLookupTables();
  Assert.equal(decimath.ln(1000000000000000000, 99), 0, "failed");
  Assert.equal(decimath.ln(2718281828459045235, 99), 1000000000000000000, "failed");
}

function test_ln_edges() public {
  setLookupTables();
  Assert.equal(decimath.ln(1000000000000000001, 99), 1, "failed");
  /* Assert.equal(decimath.ln(2^255-1, 99), 10, "failed"); */
}

function test_ln() public {
  setLookupTables();
  Assert.equal(decimath.ln(1234512345123451234, 99), 210676029853097475, "failed");
  Assert.equal(decimath.ln(1987654321987654321, 99), 686955210815129821, "failed");
}

function test_ln_large_input() public {
  setLookupTables();
  Assert.equal(decimath.ln(87897878977971234512345123451234, 99), 32107196790385103322, "failed");
  Assert.equal(decimath.ln(100000000000000000000000000000000000000000000000, 99), 66774967696827324837, "failed");
}
}
