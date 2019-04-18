pragma solidity ^0.5.0;

contract DeciMath {
  uint constant TEN38 = 10**38;
  uint constant TEN30 = 10**30;
  uint constant TEN20 = 10**20;
  uint constant TEN19 = 10**19;
  uint constant TEN18 = 10**18;
  uint constant TEN17 = 10**17;
  uint constant TEN12 = 10**12;
  uint constant TEN11 = 10**11;
  uint constant TEN10 = 10**10;
  uint constant TEN9 = 10**9;
  uint constant TEN8 = 10**8;
  uint constant TEN7 = 10**7;

  // ln(2) - used in ln(x)
  uint constant LN2 = 693147180559945309417232121458; // to 30 DP
  //17656808;

  //  1/ln(2) - used in exp(x)
  uint constant ONE_OVER_LN2 = 1442695040888963407359924681002; // to 30 DP

  //Lookup table arrays for log2(x)
  uint[100] public table_log2;
  uint[100] public powersOfTwo;

  // Lookup table for two_x(x)
  uint[39] public table_2_x;

  bool tablesAreSet = false;

  // Basic math operators. Identical to Zeppelin's SafeMath
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
        return 0;
    }
    uint256 c = a * b;
    require(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0);
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;
    return c;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }

  //Basic decimal math operators. Inputs and output are uint representations of fixed-point decimals.


  // 18 Decimal places
  function decMul18(uint x, uint y) public pure returns (uint decProd) {
    uint prod_xy = mul(x, y);
    decProd = add(prod_xy, TEN18 / 2) / TEN18;
  }

  function decDiv18(uint x, uint y) public pure returns (uint decQuotient) {
    uint prod_xTEN18 = mul(x, TEN18);
    decQuotient = add(prod_xTEN18, y / 2) / y;
  }
  // 30 Decimal places
  function decMul30(uint x, uint y) public pure returns (uint decProd) {
    uint prod_xy = mul(x, y);
    decProd = add(prod_xy, TEN30 / 2) / TEN30;
  }

  // 38 Decimal places
  function decMul38(uint x, uint y) public pure returns (uint decProd) {
    uint prod_xy = mul(x, y);
    decProd = add(prod_xy, TEN38 / 2) / TEN38;
  }

  /****** HELPER FUNCTIONS ******/

  // Precision conversion. Chop the last digits, and round the resulting number
  function chopAndRound(uint num, uint digit, uint posOfChop) public pure returns (uint chopped) {
    if  ( digit < 5 ) { // round down - chop off the last digits
      chopped = div(num, 10**posOfChop);
    } else if ( digit >= 5 ) { // round up - chop off last digits, and increment new last digit by 1
      chopped = div(num, 10**posOfChop) + 1;
    }
    return chopped;
  }

  /* 'Convert' functions are repetitive - but explicit naming vastly improves
  readability of the algorithms that use them */

  // convert 38DP fixed-point to 18DP fixed-point
  function convert38To18DP(uint x) public pure returns ( uint y ) {
    uint digit = ( x % TEN20 ) / TEN19; // grab 20th digit from-the-right
    return chopAndRound(x, digit, 20);
  }

  function convert38To30DP(uint x) public pure returns ( uint y ) {
    uint digit = ( x % TEN8 ) / TEN7;
    return chopAndRound(x, digit, 8);
  }

  function convert30To20DP(uint x) public pure returns ( uint y ) {
    uint digit = ( x % TEN10) / TEN9;
    return chopAndRound(x, digit, 10);
  }

  function convert30To18DP(uint x) public pure returns ( uint y ) {
    uint digit = ( x % TEN12) / TEN11;
    return chopAndRound(x, digit, 12);
  }

  // return the floor of a fixed-point 20DP number
  function floor(uint x) public pure returns (uint num) {
    num = x - (x % TEN20);
    return num;
  }

  function countDigits(uint num) public view returns (uint) {
    uint digits = 0;

    while (num != 0) {
      num /= 10;  // When num <10, yields 0 due to EVM floor division
      digits++;
    }
    return digits;
  }

    /* b^x functions for integer exponent. Use  highly performant 'exponetiation-by-squaring' algorithm
     - O(log(n)) operations. */

    // Integer base, integer exponent
  function expBySquare(uint x, uint n) public pure returns (uint) {
    if (n == 0)
      return 1;

    uint y = 1;

    while (n > 1)
    if (n % 2 == 0) {
      x = mul(x, x);
      n = n / 2;
    } else if (n % 2 != 0) {
      y = mul(x, y);
      x = mul(x, x);
      n = (n - 1)/2;
    }
    return mul(x, y);
  }

      //Fixed-point 18DP base, integer exponent n
  function expBySquare18(uint base, uint n) public pure returns (uint) {
    if (n == 0)
    return TEN18;

    uint y = TEN18;

    while (n > 1) {
      if (n % 2 == 0) {
        base = decMul18(base, base);
        n = n / 2;
      } else if (n % 2 != 0) {
        y = decMul18(base, y);
        base = decMul18(base, base);
        n = (n - 1)/2;
      }
    }
    return decMul18(base, y);
  }

        //Fixed-point 38DP base,integer exponent n
  function expBySquare38(uint base, uint n) public pure returns (uint) {
    if (n == 0)
    return TEN38;

    uint y = TEN38;

    while (n > 1) {
      if (n % 2 == 0) {
        base = decMul38(base, base);
        n = n / 2;
      } else if (n % 2 != 0) {
        y = decMul38(base, y);
        base = decMul38(base, base);
        n = (n - 1)/2;
      }
    }
    return decMul38(base, y);
  }
  /* EXP(x). Use identities:

  A) e^x = 2^(x / ln(2))
  and
  B) 2^y = (2^r) * 2^(x - r); where r = floor(x) - 1
  Input 18 DP, output 18 DP.
  */
  function exp(uint x) public view returns (uint num) {
    uint intExponent;  // 20 DP
    uint decExponent;  // 20 DP
    uint coefficient;  // 38P

    x = mul(x, TEN12); // make x 30DP
    x = decMul30( ONE_OVER_LN2, x);
    x = convert30To20DP(x);  //back to 20 DP

    // if x < 1, do: (2^-1) * 2^(1 + x)
    if (x < TEN20 && x >= 0) {
      decExponent = add(TEN20, x);
      coefficient = TEN38 / 2; // 0.5, as 38DP
      num = decMul38(coefficient, two_x(decExponent));  // return 2^r * 2^(x - r)
    } else {
      intExponent = floor(x) - TEN20;
      decExponent = x - intExponent; // decimal exponent in range [1,2[
      coefficient =  expBySquare(2, div(intExponent, TEN20));
      num = mul(coefficient, two_x(decExponent)); //  use normal mul to avoid overflow, as coeff. is an int
    }

    return convert38To18DP(num);
  }

  // Taylor series implementation of e^x - lower accuracy and higher gas cost than exp(x). 18DP Input.
  function exp_taylor(uint x) public pure returns (uint) {
    uint tolerance = 1;
    uint term = TEN18;
    uint sum = TEN18;
    uint i = 0;

    while (term > tolerance) { // stop computing terms when smallest term reaches 10^-18 in size
      i += TEN18;
      term = decDiv18( decMul18(term, x), i );
      sum += term;
    }
    return sum;
  }

  // Base-2 logarithm function, for x in range [1,2[.  Input 18DP, output 30DP (for use in ln(x) ) .
  function log2(uint x, uint accuracy) public view returns (uint) {
    require(tablesAreSet, 'Lookup tables must be set');
    require(x >= TEN18 && x < 2 * TEN18, 'input x must be within range [1,2[');
    uint prod = mul(x, TEN20);  // make x 38 DP
    uint newProd = TEN38;
    uint output = 0;

    for (uint i = 1; i <= accuracy; i++) {
      newProd = decMul38(table_log2[i], prod);

      if (newProd >= TEN38) {
        prod = newProd;
        output += powersOfTwo[i];
      }
    }
    return convert38To30DP(output);
  }

  // 2^x function, for x in range [1,2[. Input 20DP, output 30DP ( for use in exp(x) )
  function two_x(uint x) public view returns (uint) {
    require (tablesAreSet, 'Lookup tables must be set');
    require(x >= TEN20 && x < 2 * TEN20, 'input x must be within range [1,2[');
    uint x_38dp = x * TEN18;
    uint prod = 2 * TEN38;
    uint fractPart = x_38dp % TEN38;
    uint digitsLength = countDigits(fractPart);

    // loop backwards through mantissa digits. Multiply each by the Lookup-table value
    for (uint i = 0; i < digitsLength; i++) {
      uint digit  = ( fractPart % (10 ** (i + 1))) / (10 ** i); // grab the i'th digit from right

      // computer i'th term, and new product
      uint term = expBySquare38(table_2_x[37 - i], digit);
      prod = decMul38(prod, term);
    }
    return prod;
  }

  /* natural log function ln(x).
  Uses identities:
  A) ln(x) = log2(x) * ln(2)
  and
  B) log2(x) = log2(2^q * y)           y in range [1,2[
  = log2(2^q) + log2(y)
  = q + log2(y)

  The algorithm finds q and y by repeated division by powers-of-two.
  Input 18 DP, output 18 DP.
  */
  function ln(uint x, uint accuracy) public view returns (uint) {
    require(x >= TEN18, "input must be >= 1");
    uint count = 0; // track
    uint TWO = mul(TEN18, 2);

    /* Calculate q.

    Use branches to divide by powers-of-two, until output is in [1,2[.
    Branch approach is performant than simple successive division by 2.
    As max input of ln(x) is ~10^40 ~= 2^132, starting division at 2^30 yields sufficiently few operations for large x. */
    while (x >= 2 * TEN18 ) { // Conditionals need primary expressions - can't use "mul". No risk of overflow.
      if (x >= 1073741824 * TEN18) {
        x = decDiv18(x, 1073741824 * TEN18);
        count += 30;
      } else if (x >= 1048576 * TEN18) {
        x = decDiv18(x, 1048576 * TEN18);
        count += 20;
      } else if (x >= 32768 * TEN18) {
        x = decDiv18(x, 32768 * TEN18);
        count += 15;
      } else if (x >= 1024 * TEN18) {
      x = decDiv18(x, 1024 * TEN18);
      count += 10;
      } else if (x >= 512 * TEN18) {
        x = decDiv18(x, 512 * TEN18);
        count += 9;
      } else if (x >= 256 * TEN18) {
        x = decDiv18(x, 256 * TEN18);
        count += 8;
      } else if (x >= 128 * TEN18) {
        x = decDiv18(x, 128 * TEN18);
        count += 7;
      } else if (x >= 64 * TEN18) {
        x = decDiv18(x, 64 * TEN18);
        count += 6;
      } else if (x >= 32 * TEN18) {
        x = decDiv18(x, 32 * TEN18);
        count += 5;
      }  else if (x >= 16 * TEN18) {
        x = decDiv18(x, 16 * TEN18);
        count += 4;
      } else if (x >= 8 * TEN18) {
        x = decDiv18(x, 8 * TEN18);
        count += 3;
      } else if (x >= 4 * TEN18) {
        x = decDiv18(x, 4 * TEN18);
        count += 2;
      } else if (x >= 2 * TEN18) {
        x = decDiv18(x, 2 * TEN18);
        count += 1;
      }
    }
    uint q =  count * TEN30;
    uint output = decMul30(LN2, add(q, log2(x, accuracy)));

    return convert30To18DP(output);
  }

  /* pow(b, x) for 18 DP base and exponent. Uses identity:  b^x = exp (x * ln(b))
  Output 18 DP. */
  function pow(uint base, uint x) public view returns (uint power) {
  return exp(decMul18(x, ln(base, 70)));
  }

  /// Lookup Tables (LUTs). 38 DP fixed-point numbers.

  // LUT1 for log2(x). The i'th term is 1/(2^(1/2^i))
  function setLUT1() public {
    table_log2[0] = 0;
    table_log2[1] = 70710678118654752440084436210484903927;
    table_log2[2] = 84089641525371454303112547623321489504;
    table_log2[3] = 91700404320467123174354159479414442803;
    table_log2[4] = 95760328069857364693630563514791544391;
    table_log2[5] = 97857206208770013450916112581343574558;
    table_log2[6] = 98922801319397548412912495906558366776;
    table_log2[7] = 99459942348363317565247768622216631446;
    table_log2[8] = 99729605608547012625765991384792260110;
    table_log2[9] = 99864711289097017358812131808592040801;
    table_log2[10] = 99932332750265075236028365984373804110;
    table_log2[11] = 99966160649624368394219686876281565555;
    table_log2[12] = 99983078893192906311748078019767389870;
    table_log2[13] = 99991539088661349753372497156418872729;
    table_log2[14] = 99995769454843113254396753730099797523;
    table_log2[15] = 99997884705049192982650067113039327478;
    table_log2[16] = 99998942346931446424221059225315431669;
    table_log2[17] = 99999471172067428300770241277030532524;
    table_log2[18] = 99999735585684139498225234636504270994;
    table_log2[19] = 99999867792754675970531776759801063701;
    table_log2[20] = 99999933896355489526178052900624509793;
    table_log2[21] = 99999966948172282646511738368820575116;
    table_log2[22] = 99999983474084775793885880947314828005;
    table_log2[23] = 99999991737042046514572235133214264693;
    table_log2[24] = 99999995868520937911689915196095249004;
    table_log2[25] = 99999997934260447619445466250978583191;
    table_log2[26] = 99999998967130218475622805194415901617;
    table_log2[27] = 99999999483565107904286413727651274869;
    table_log2[28] = 99999999741782553618761958785587923501;
    table_log2[29] = 99999999870891276726035667265628464908;
    table_log2[30] = 99999999935445638342181505587572099685;
    table_log2[31] = 99999999967722819165881670780794171831;
    table_log2[32] = 99999999983861409581638564886938948308;
    table_log2[33] = 99999999991930704790493714817578668744;
    table_log2[34] = 99999999995965352395165465502313349144;
    table_log2[35] = 99999999997982676197562384774537267783;
    table_log2[36] = 99999999998991338098776105393113730878;
    table_log2[37] = 99999999999495669049386780948018133270;
    table_log2[38] = 99999999999747834524693072536874382790;
    table_log2[39] = 99999999999873917262346456784153520332;
    table_log2[40] = 99999999999936958631173208521005842391;
    table_log2[41] = 99999999999968479315586599292735191745;
    table_log2[42] = 99999999999984239657793298404425663514;
    table_log2[43] = 99999999999992119828896648891727348671;
    table_log2[44] = 99999999999996059914448324368242303565;
    table_log2[45] = 99999999999998029957224162164715809086;
    table_log2[46] = 99999999999999014978612081077506568867;
    table_log2[47] = 99999999999999507489306040537540450517;
    table_log2[48] = 99999999999999753744653020268467016779;
    table_log2[49] = 99999999999999876872326510134157706270;
    table_log2[50] = 99999999999999938436163255067059902600;
    table_log2[51] = 99999999999999969218081627533525213665;
    table_log2[52] = 99999999999999984609040813766761422426;
    table_log2[53] = 99999999999999992304520406883380415114;
    table_log2[54] = 99999999999999996152260203441690133531;
    table_log2[55] = 99999999999999998076130101720845048263;
    table_log2[56] = 99999999999999999038065050860422519503;
    table_log2[57] = 99999999999999999519032525430211258593;
    table_log2[58] = 99999999999999999759516262715105629008;
    table_log2[59] = 99999999999999999879758131357552814435;
    table_log2[60] = 99999999999999999939879065678776407196;
    table_log2[61] = 99999999999999999969939532839388203589;
    table_log2[62] = 99999999999999999984969766419694101792;
    table_log2[63] = 99999999999999999992484883209847050901;
    table_log2[64] = 99999999999999999996242441604923525450;
    table_log2[65] = 99999999999999999998121220802461762730;
    table_log2[66] = 99999999999999999999060610401230881370;
    table_log2[67] = 99999999999999999999530305200615440690;
    table_log2[68] = 99999999999999999999765152600307720350;
    table_log2[69] = 99999999999999999999882576300153860180;
    table_log2[70] = 99999999999999999999941288150076930090;
    table_log2[71] = 99999999999999999999970644075038465050;
    table_log2[72] = 99999999999999999999985322037519232530;
    table_log2[73] = 99999999999999999999992661018759616270;
    table_log2[74] = 99999999999999999999996330509379808140;
    table_log2[75] = 99999999999999999999998165254689904070;
    table_log2[76] = 99999999999999999999999082627344952040;
    table_log2[77] = 99999999999999999999999541313672476020;
    table_log2[78] = 99999999999999999999999770656836238010;
    table_log2[79] = 99999999999999999999999885328418119010;
    table_log2[80] = 99999999999999999999999942664209059510;
    table_log2[81] = 99999999999999999999999971332104529760;
    table_log2[82] = 99999999999999999999999985666052264880;
    table_log2[83] = 99999999999999999999999992833026132440;
    table_log2[84] = 99999999999999999999999996416513066220;
    table_log2[85] = 99999999999999999999999998208256533110;
    table_log2[86] = 99999999999999999999999999104128266560;
    table_log2[87] = 99999999999999999999999999552064133280;
    table_log2[88] = 99999999999999999999999999776032066640;
    table_log2[89] = 99999999999999999999999999888016033320;
    table_log2[90] = 99999999999999999999999999944008016660;
    table_log2[91] = 99999999999999999999999999972004008330;
    table_log2[92] = 99999999999999999999999999986002004170;
    table_log2[93] = 99999999999999999999999999993001002090;
    table_log2[94] = 99999999999999999999999999996500501050;
    table_log2[95] = 99999999999999999999999999998250250530;
    table_log2[96] = 99999999999999999999999999999125125270;
    table_log2[97] = 99999999999999999999999999999562562640;
    table_log2[98] = 99999999999999999999999999999781281320;
    table_log2[99] = 99999999999999999999999999999890640660;
  }

  //LUT2 for log2(x). The i'th term is 2^((1/i))
  function setLUT2() public {
    powersOfTwo[0] = 200000000000000000000000000000000000000;
    powersOfTwo[1] = 50000000000000000000000000000000000000;
    powersOfTwo[2] = 25000000000000000000000000000000000000;
    powersOfTwo[3] = 12500000000000000000000000000000000000;
    powersOfTwo[4] = 6250000000000000000000000000000000000;
    powersOfTwo[5] = 3125000000000000000000000000000000000;
    powersOfTwo[6] = 1562500000000000000000000000000000000;
    powersOfTwo[7] = 781250000000000000000000000000000000;
    powersOfTwo[8] = 390625000000000000000000000000000000;
    powersOfTwo[9] = 195312500000000000000000000000000000;
    powersOfTwo[10] = 97656250000000000000000000000000000;
    powersOfTwo[11] = 48828125000000000000000000000000000;
    powersOfTwo[12] = 24414062500000000000000000000000000;
    powersOfTwo[13] = 12207031250000000000000000000000000;
    powersOfTwo[14] = 6103515625000000000000000000000000;
    powersOfTwo[15] = 3051757812500000000000000000000000;
    powersOfTwo[16] = 1525878906250000000000000000000000;
    powersOfTwo[17] = 762939453125000000000000000000000;
    powersOfTwo[18] = 381469726562500000000000000000000;
    powersOfTwo[19] = 190734863281250000000000000000000;
    powersOfTwo[20] = 95367431640625000000000000000000;
    powersOfTwo[21] = 47683715820312500000000000000000;
    powersOfTwo[22] = 23841857910156250000000000000000;
    powersOfTwo[23] = 11920928955078125000000000000000;
    powersOfTwo[24] = 5960464477539062500000000000000;
    powersOfTwo[25] = 2980232238769531250000000000000;
    powersOfTwo[26] = 1490116119384765625000000000000;
    powersOfTwo[27] = 745058059692382812500000000000;
    powersOfTwo[28] = 372529029846191406250000000000;
    powersOfTwo[29] = 186264514923095703125000000000;
    powersOfTwo[30] = 93132257461547851562500000000;
    powersOfTwo[31] = 46566128730773925781250000000;
    powersOfTwo[32] = 23283064365386962890625000000;
    powersOfTwo[33] = 11641532182693481445312500000;
    powersOfTwo[34] = 5820766091346740722656250000;
    powersOfTwo[35] = 2910383045673370361328125000;
    powersOfTwo[36] = 1455191522836685180664062500;
    powersOfTwo[37] = 727595761418342590332031250;
    powersOfTwo[38] = 363797880709171295166015625;
    powersOfTwo[39] = 181898940354585647583007812;
    powersOfTwo[40] = 90949470177292823791503906;
    powersOfTwo[41] = 45474735088646411895751953;
    powersOfTwo[42] = 22737367544323205947875976;
    powersOfTwo[43] = 11368683772161602973937988;
    powersOfTwo[44] = 5684341886080801486968994;
    powersOfTwo[45] = 2842170943040400743484497;
    powersOfTwo[46] = 1421085471520200371742248;
    powersOfTwo[47] = 710542735760100185871124;
    powersOfTwo[48] = 355271367880050092935562;
    powersOfTwo[49] = 177635683940025046467781;
    powersOfTwo[50] = 88817841970012523233890;
    powersOfTwo[51] = 44408920985006261616945;
    powersOfTwo[52] = 22204460492503130808472;
    powersOfTwo[53] = 11102230246251565404236;
    powersOfTwo[54] = 5551115123125782702118;
    powersOfTwo[55] = 2775557561562891351059;
    powersOfTwo[56] = 1387778780781445675529;
    powersOfTwo[57] = 693889390390722837764;
    powersOfTwo[58] = 346944695195361418882;
    powersOfTwo[59] = 173472347597680709441;
    powersOfTwo[60] = 86736173798840354720;
    powersOfTwo[61] = 43368086899420177360;
    powersOfTwo[62] = 21684043449710088680;
    powersOfTwo[63] = 10842021724855044340;
    powersOfTwo[64] = 5421010862427522170;
    powersOfTwo[65] = 2710505431213761085;
    powersOfTwo[66] = 1355252715606880542;
    powersOfTwo[67] = 677626357803440271;
    powersOfTwo[68] = 338813178901720135;
    powersOfTwo[69] = 169406589450860067;
    powersOfTwo[70] = 84703294725430033;
    powersOfTwo[71] = 42351647362715016;
    powersOfTwo[72] = 21175823681357508;
    powersOfTwo[73] = 10587911840678754;
    powersOfTwo[74] = 5293955920339377;
    powersOfTwo[75] = 2646977960169688;
    powersOfTwo[76] = 1323488980084844;
    powersOfTwo[77] = 661744490042422;
    powersOfTwo[78] = 330872245021211;
    powersOfTwo[79] = 165436122510605;
    powersOfTwo[80] = 82718061255302;
    powersOfTwo[81] = 41359030627651;
    powersOfTwo[82] = 20679515313825;
    powersOfTwo[83] = 10339757656912;
    powersOfTwo[84] = 5169878828456;
    powersOfTwo[85] = 2584939414228;
    powersOfTwo[86] = 1292469707114;
    powersOfTwo[87] = 646234853557;
    powersOfTwo[88] = 323117426778;
    powersOfTwo[89] = 161558713389;
    powersOfTwo[90] = 80779356694;
    powersOfTwo[91] = 40389678347;
    powersOfTwo[92] = 20194839173;
    powersOfTwo[93] = 10097419586;
    powersOfTwo[94] = 5048709793;
    powersOfTwo[95] = 2524354896;
    powersOfTwo[96] = 1262177448;
    powersOfTwo[97] = 631088724;
    powersOfTwo[98] = 315544362;
    powersOfTwo[99] = 157772181;
  }

  // LUT for two_x(x).  The i'th term is 2^(1 / 10^(i + 1)).
  function setLUT3() public {
    table_2_x[0] = 107177346253629316421300632502334202291;
    table_2_x[1] = 100695555005671880883269821411323978545;
    table_2_x[2] = 100069338746258063253756863930385919571;
    table_2_x[3] = 100006931712037656919243991260264256542;
    table_2_x[4] = 100000693149582830565320908980056168150;
    table_2_x[5] = 100000069314742078650777263622740703038;
    table_2_x[6] = 100000006931472045825965603683996211583;
    table_2_x[7] = 100000000693147182962210384558650120894;
    table_2_x[8] = 100000000069314718080017181643183694247;
    table_2_x[9] = 100000000006931471805839679601136972338;
    table_2_x[10] = 100000000000693147180562347574486828679;
    table_2_x[11] = 100000000000069314718056018553592419128;
    table_2_x[12] = 100000000000006931471805599693320679280;
    table_2_x[13] = 100000000000000693147180559947711682302;
    table_2_x[14] = 100000000000000069314718055994554964374;
    table_2_x[15] = 100000000000000006931471805599453334399;
    table_2_x[16] = 100000000000000000693147180559945311819;
    table_2_x[17] = 100000000000000000069314718055994530966;
    table_2_x[18] = 100000000000000000006931471805599453094;
    table_2_x[19] = 100000000000000000000693147180559945309;
    table_2_x[20] = 100000000000000000000069314718055994531;
    table_2_x[21] = 100000000000000000000006931471805599453;
    table_2_x[22] = 100000000000000000000000693147180559945;
    table_2_x[23] = 100000000000000000000000069314718055995;
    table_2_x[24] = 100000000000000000000000006931471805599;
    table_2_x[25] = 100000000000000000000000000693147180560;
    table_2_x[26] = 100000000000000000000000000069314718056;
    table_2_x[27] = 100000000000000000000000000006931471806;
    table_2_x[28] = 100000000000000000000000000000693147181;
    table_2_x[29] = 100000000000000000000000000000069314718;
    table_2_x[30] = 100000000000000000000000000000006931472;
    table_2_x[31] = 100000000000000000000000000000000693147;
    table_2_x[32] = 100000000000000000000000000000000069315;
    table_2_x[33] = 100000000000000000000000000000000006931;
    table_2_x[34] = 100000000000000000000000000000000000693;
    table_2_x[35] = 100000000000000000000000000000000000069;
    table_2_x[36] = 100000000000000000000000000000000000007;
    table_2_x[37] = 100000000000000000000000000000000000001;
  }

  function setAllLUTs() public {
    if (tablesAreSet == false) {
      setLUT1();
      setLUT2();
      setLUT3();
      tablesAreSet = true;
    }
  }
}
