pragma solidity ^0.5.0;

import "../contracts/DeciMath.sol";
import "truffle/DeployedAddresses.sol";
import "truffle/Assert.sol";

contract TestDeciMath {

 // initialize contract representations
  DeciMath decimath = DeciMath(DeployedAddresses.DeciMath());

  uint TEN20 = 10**20;
  uint TEN30 = 10**30;

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

 /* ***** DECIMATH HELPER FUNCTIONS  ***** */

//   function test_countDigits() public {
//    Assert.equal(decimath.countDigits(7), 1, "failed");
//    Assert.equal(decimath.countDigits(123456789), 9, "failed");
//    Assert.equal(decimath.countDigits(1234567891234567891234567891234567890000), 40, "failed");
//  }

//   function test_convert38To18DP_basic() public {
//   //converts 38DP Num to 18DP num
//   Assert.equal(decimath.convert38To18DP(1 ether * TEN20),  1 ether, "failed");
//   Assert.equal(decimath.convert38To18DP(0),  0, "failed");

//   }

//   function test_convert38To18DP_roundDown() public {
//     // Round down when 20th digit from the right  < 5
//   Assert.equal(decimath.convert38To18DP(100000000000000000040000000000000000000),  1 ether, "failed");
//   Assert.equal(decimath.convert38To18DP(90000000012345000000000000000000939648390485092893288),  900000000123450000000000000000009, "failed");
//   }

//   function test_convert38To18DP_roundUp() public {
//     //Round up when 20th digit from right >= 5
//   Assert.equal(decimath.convert38To18DP(5000000000000000000000000009999974974545353448935455),  50000000000000000000000000100000, "failed");
//   Assert.equal(decimath.convert38To18DP(100000000000000000050000000000000000000), 1000000000000000001, "failed" );
//   }

//    function test_convert30To20DP_basic() public {
//   //converts 38DP Num to 20DP num
//   Assert.equal(decimath.convert30To20DP(TEN30), 100 ether, "failed");
//   Assert.equal(decimath.convert30To20DP(0),  0, "failed");
//   }

//   function test_convert30To20DP_roundDown() public {
//     // Round down when 10th digit from the right  < 5
//   Assert.equal(decimath.convert30To20DP(1000000000000000000004000000000),  100 ether, "failed");
//   Assert.equal(decimath.convert30To20DP(900000000123450000000000000000000093964839042),  90000000012345000000000000000000009, "failed");
//   }

//   function test_convert30To20DP_roundUp() public {
//     //Round up when 18th digit from right >= 5
//   Assert.equal(decimath.convert30To20DP(500000000000000000000000000999996497412383),  50000000000000000000000000100000, "failed");
//   Assert.equal(decimath.convert30To20DP(10000000000000000005000000000), 1000000000000000001, "failed" );
//   }

//   // floor(x) tests
//     function test_floor() public {
//    Assert.equal(decimath.floor(150000000000000000000), 100000000000000000000, "failed");
//    Assert.equal(decimath.floor(55512345678900000000000), 55500000000000000000000, "failed");
//   }

//   function test_floor_lessThan1() public {
//     Assert.equal(decimath.floor(12345), 0, "failed");
//     Assert.equal(decimath.floor(9999999999999999999), 0, "failed");
//   }

   /* ***** LOOKUP TABLE SETTERS  ***** */

   function test_Log2_LookupTable1() public {
      Assert.equal(decimath.table_log_2(0), 0, "failed");
      Assert.equal(decimath.table_log_2(1), 70710678118654752440084436210484903928, "failed");
      Assert.equal(decimath.table_log_2(99), 99999999999999999999999999999890640658, "failed");
    }

    function test_Log2_LookupTable2() public {
      Assert.equal(decimath.table2_log_2(0), 200000000000000000000000000000000000000, "failed");
      Assert.equal(decimath.table2_log_2(1), 50000000000000000000000000000000000000, "failed");
      Assert.equal(decimath.table2_log_2(99), 157772181, "failed");
    }

    function test_Pow2_LookupTable() public {
    // test one value from each LUT3 setter
     Assert.equal (decimath.table_pow2(0,1), 107177346253629316421300632502334202291, "failed");  
     Assert.equal (decimath.table_pow2(20,9), 100000000000000000000623832462503950778, "failed"); 
     Assert.equal (decimath.table_pow2(27,7), 100000000000000000000000000048520302639, "failed"); 
     Assert.equal (decimath.table_pow2(36,4), 100000000000000000000000000000000000028, "failed");

    }
}
