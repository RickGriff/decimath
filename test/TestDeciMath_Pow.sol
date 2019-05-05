pragma solidity ^0.5.0;

import "../contracts/DeciMath.sol";
import "truffle/DeployedAddresses.sol";
import "truffle/Assert.sol";

contract TestDeciMath {

  DeciMath decimath = DeciMath(DeployedAddresses.DeciMath());

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

  function test_pow_base_To_0() public {
    Assert.equal(decimath.pow(1 ether, 0), 1 ether, "failed");
    Assert.equal(decimath.pow(9892731231312312321121, 0), 1 ether, "failed");
  }

  function test_pow_base_To_1() public {
    Assert.equal(decimath.pow(1 ether, 1 ether), 1 ether, "failed");
    /* Assert.equal(decimath.pow(2 ether, 1 ether), 2 ether, "failed"); */
    Assert.equal(decimath.pow(2.5 ether, 1 ether), 2.5 ether, "failed");
    /* Assert.equal(decimath.pow(92989099879884234324234, 1 ether), 92989099879884234324234, "failed"); */
  }

  function test_pow_1_to_n() public {
    Assert.equal(decimath.pow(1 ether, 56), 1 ether, "failed");
    Assert.equal(decimath.pow(1 ether, 75778819191911020302021), 1 ether, "failed");
  }

  function test_pow_less_than_one() public {
    Assert.equal(decimath.pow(0.5 ether, 1.0000000 ether ), 0.5 ether, "failed");
    Assert.equal(decimath.pow(0.5 ether, 2 ether ), 0.25 ether, "failed");
    Assert.equal(decimath.pow(0.00345 ether, 1.5678 ether ), 0.000137972577412087 ether, "failed");
    Assert.equal(decimath.pow(0.000640003 ether, 5.1 ether ), 0.000000000000000051 ether, "failed");
    Assert.equal(decimath.pow(0.000000000000000001 ether, 2 ether ), 0 ether, "failed");
  }

  function test_pow_small_base_small_exp() public {
    Assert.equal(decimath.pow(1.00000001 ether, 1.00000001 ether ), 1.0000000100000001 ether, "failed");
    Assert.equal(decimath.pow(1.5678 ether, 4.8 ether ), 8.657553191960168159 ether, "failed");
    Assert.equal(decimath.pow(4100000295000034987, 1.5678 ether ), 9.135295068536720592 ether, "failed");
  }

  function test_pow_small_base_large_exp() public {
    Assert.equal(decimath.pow(1.00000001 ether, 2093.456 ether ), 1.000020934779024755 ether, "failed");
    Assert.equal(decimath.pow(1.178 ether, 39.00454007 ether ), 595.647512139092756693 ether, "failed");
    Assert.equal(decimath.pow(4.10000029 ether, 27.009 ether ), 35536938918666035.64019280415190173 ether, "failed");
  }

  function test_pow_large_base_small_exp() public {
    Assert.equal(decimath.pow(203663.456 ether, 1.00000121 ether), 203666.468471849926898724 ether, "failed");
    Assert.equal(decimath.pow(3346.0003491 ether, 4.0000000065112 ether ), 125344115686423.141228754097402565 ether, "failed");
    Assert.equal(decimath.pow(7224.653 ether, 1.0943 ether  ), 16699.498733571170979571 ether, "failed");
  }

  function test_pow_large_base_large_exp() public {
    Assert.equal(decimath.pow(15 ether, 30 ether ), 191751059232884086668491363525390625 ether, "failed");
    Assert.equal(decimath.pow(22.0000345 ether, 28.9140023121213 ether), 652878232459044821325695473631728268234.394688863849159897 ether, "failed");
    Assert.equal(decimath.pow(41.0000029 ether, 17.211 ether ), 5722996584199937376505598250.040909270199848259 ether, "failed");
  }
}
