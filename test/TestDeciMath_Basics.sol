pragma solidity ^0.5.0;


import "../contracts/DeciMath.sol";
import "truffle/DeployedAddresses.sol";
import "truffle/Assert.sol";


contract TestDeciMath {

 // initialize contract representations
  DeciMath decimath = DeciMath(DeployedAddresses.DeciMath());

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
}
