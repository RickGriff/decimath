pragma solidity ^0.5.0;

import "../contracts/DeciMath.sol";
import "truffle/DeployedAddresses.sol";
import "truffle/Assert.sol";

contract TestDeciMath {

  DeciMath decimath = DeciMath(DeployedAddresses.DeciMath());

  function setLookupTables() internal {
    decimath.setLUT1();
    decimath.setLUT2();
    decimath.setLUT3();
  }

/* ***** Ln(x) - NATURAL LOGARITHM ALGO  ***** */

function test_ln_basics() public {
  Assert.equal(decimath.ln(1000000000000000000), 99), 0, "failed");
  Assert.equal(decimath.ln(2718281828459045235), 99), 1000000000000000000ish, "failed");
}

function test_ln_edges() public {
  Assert.equal(decimath.ln(1000000000000000001), 99), , "failed");
  Assert.equal(decimath.ln(2^255-1), 99), , "failed");
}

function test_ln() public {
  Assert.equal(decimath.ln(1234512345123451234, 99), 21067602985309747475472684418770452558, "failed");
  Assert.equal(decimath.ln(1987654321987654321, 99), 68695521081512982027288999159318282946, "failed");
}

function test_ln_large_input() public {
  Assert.equal(decimath.ln(87897878977971234512345123451234, 99), 3210719679038510332184777126248737822592, "failed");
  Assert.equal(decimath.ln(100000000000000000000000000000.000000000000000000, 99), 66.77496769682732483652175218584656202043, "failed");
}

}

}
