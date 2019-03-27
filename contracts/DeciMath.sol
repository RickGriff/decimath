pragma solidity ^0.5.0;

import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
contract DeciMath {
  using SafeMath for uint;

  uint constant QUINT = 10**18;
  uint constant ONE_38_ZEROS = 10**38;
  uint constant TEN20 = 10**20;
  uint constant TEN19 = 10**19;

  uint[100] public ith_term;
  uint[100] public powersOfTwo;

  // 2 DP functions
  function decMul2(uint x, uint y) public pure returns (uint decProduct) {
    uint prod_xy = x.mul(y);
    decProduct = prod_xy.add(100 / 2) / 100;
  }
  function decDiv2(uint x, uint y) public pure returns (uint decQuotient) {
    uint prod_100x = x.mul(100);
    decQuotient = prod_100x.add(y / 2) / y;
  }

  // 18 DP Functions
  function decMul18(uint x, uint y) public pure returns (uint decProd) {
    uint prod_xy = x.mul(y);
    decProd = prod_xy.add(QUINT / 2) / QUINT;
  }

  function decMul38(uint x, uint y) public pure returns (uint decProd) {
    uint prod_xy = x.mul(y);
    decProd = prod_xy.add(ONE_38_ZEROS / 2) / ONE_38_ZEROS;
  }

  function decDiv18(uint x, uint y) public pure returns (uint decQuotient) {
    uint prod_xQuint = x.mul(QUINT);
    decQuotient = prod_xQuint.add(y / 2) / y;
  }

  // rounds a 38DP decimal to a 18DP decimal
   function convertTo18DP(uint x) public pure returns ( uint y ) {
    // Use modulus and floor division to grab the 20th digit from-the-right
    uint digit = ( x % TEN20 ) / TEN19;

     if ( digit < 5 ) {
       // round down - chop off last 20 digits with floor div
      y = x.div(TEN20);

      } else if ( digit >= 5 ) {
        // round up - chop off last 20 digits, and increment the 18th digit by one
        y = x.div(TEN20) + 1;
      }
      return y;
    }

    //integer base, integer exponent
    function expNoDec(uint x, uint n) public pure returns (uint) {
      if (n == 0)
      return 1;

      uint y = 1;

      while (n > 1)
      if (n % 2 == 0) {
        x = x.mul(x);
        n = n / 2;
        } else if (n % 2 != 0) {
          y = x.mul(y);
          x = x.mul(x);
          n = (n - 1)/2;
        }
        return x.mul(y);
      }

      //2DP base, positive integer exponent n
      function exp2(uint x, uint n) public pure returns (uint) {
        if (n == 0)
        return 100;

        uint y = 100;

        while (n > 1)
        if (n % 2 == 0) {
          x = decMul2(x, x);
          n = n / 2;
          } else if (n % 2 != 0) {
            y = decMul2(x, y);
            x = decMul2(x, x);
            n = (n - 1)/2;
          }
          return decMul2(x, y);
        }



        //18DP base, positive integer exponent n
        function exp18(uint base, uint n) public pure returns (uint) {
          if (n == 0)
          return QUINT;

          uint y = QUINT;

          while (n > 1)
          if (n % 2 == 0) {
            base = decMul18(base, base);
            n = n / 2;
            } else if (n % 2 != 0) {
              y = decMul18(base, y);
              base = decMul18(base, base);
              n = (n - 1)/2;
            }
            return decMul18(base, y);
          }

          // e^n for real exponent.
          // Exponent 'n' is  uint representing fixed-point 18DP.
          // output is uint representing fixed-point 18DP.
          function exp(uint n) public pure returns (uint) {
            uint tolerance = 1;
            uint term = QUINT;
            uint sum = QUINT;
            uint i = 0;

            while (term > tolerance) { // stop computing terms when smallest term reaches 10^-18 in size
              i += QUINT;
              term = decDiv18( decMul18(term, n), i );
              sum += term;
            }
            return sum;
          }

          //Lookup Table 1. Called by log2(x) func. Used to grab the 'i'th term in the log2 algorithm.

          function setLUT1() public {
            // Terms at 38 DP.
            ith_term[0] =0;
            ith_term[1] =70710678118654752440084436210484903927;
            ith_term[2] =84089641525371454303112547623321489504;
            ith_term[3] =91700404320467123174354159479414442803;
            ith_term[4] =95760328069857364693630563514791544391;
            ith_term[5] =97857206208770013450916112581343574558;
            ith_term[6] =98922801319397548412912495906558366776;
            ith_term[7] =99459942348363317565247768622216631446;
            ith_term[8] =99729605608547012625765991384792260110;
            ith_term[9] =99864711289097017358812131808592040801;
            ith_term[10] =99932332750265075236028365984373804110;
            ith_term[11] =99966160649624368394219686876281565555;
            ith_term[12] =99983078893192906311748078019767389870;
            ith_term[13] =99991539088661349753372497156418872729;
            ith_term[14] =99995769454843113254396753730099797523;
            ith_term[15] =99997884705049192982650067113039327478;
            ith_term[16] =99998942346931446424221059225315431669;
            ith_term[17] =99999471172067428300770241277030532524;
            ith_term[18] =99999735585684139498225234636504270994;
            ith_term[19] =99999867792754675970531776759801063701;
            ith_term[20] =99999933896355489526178052900624509793;
            ith_term[21] =99999966948172282646511738368820575116;
            ith_term[22] =99999983474084775793885880947314828005;
            ith_term[23] =99999991737042046514572235133214264693;
            ith_term[24] =99999995868520937911689915196095249004;
            ith_term[25] =99999997934260447619445466250978583191;
            ith_term[26] =99999998967130218475622805194415901617;
            ith_term[27] =99999999483565107904286413727651274869;
            ith_term[28] =99999999741782553618761958785587923501;
            ith_term[29] =99999999870891276726035667265628464908;
            ith_term[30] =99999999935445638342181505587572099685;
            ith_term[31] =99999999967722819165881670780794171831;
            ith_term[32] =99999999983861409581638564886938948308;
            ith_term[33] =99999999991930704790493714817578668744;
            ith_term[34] =99999999995965352395165465502313349144;
            ith_term[35] =99999999997982676197562384774537267783;
            ith_term[36] =99999999998991338098776105393113730878;
            ith_term[37] =99999999999495669049386780948018133270;
            ith_term[38] =99999999999747834524693072536874382790;
            ith_term[39] =99999999999873917262346456784153520332;
            ith_term[40] =99999999999936958631173208521005842391;
            ith_term[41] =99999999999968479315586599292735191745;
            ith_term[42] =99999999999984239657793298404425663514;
            ith_term[43] =99999999999992119828896648891727348671;
            ith_term[44] =99999999999996059914448324368242303565;
            ith_term[45] =99999999999998029957224162164715809086;
            ith_term[46] =99999999999999014978612081077506568867;
            ith_term[47] =99999999999999507489306040537540450517;
            ith_term[48] =99999999999999753744653020268467016779;
            ith_term[49] =99999999999999876872326510134157706270;
            ith_term[50] =99999999999999938436163255067059902600;
            ith_term[51] =99999999999999969218081627533525213665;
            ith_term[52] =99999999999999984609040813766761422426;
            ith_term[53] =99999999999999992304520406883380415114;
            ith_term[54] =99999999999999996152260203441690133531;
            ith_term[55] =99999999999999998076130101720845048263;
            ith_term[56] =99999999999999999038065050860422519503;
            ith_term[57] =99999999999999999519032525430211258593;
            ith_term[58] =99999999999999999759516262715105629008;
            ith_term[59] =99999999999999999879758131357552814435;
            ith_term[60] =99999999999999999939879065678776407196;
            ith_term[61] =99999999999999999969939532839388203589;
            ith_term[62] =99999999999999999984969766419694101792;
            ith_term[63] =99999999999999999992484883209847050901;
            ith_term[64] =99999999999999999996242441604923525450;
            ith_term[65] =99999999999999999998121220802461762730;
            ith_term[66] =99999999999999999999060610401230881370;
            ith_term[67] =99999999999999999999530305200615440690;
            ith_term[68] =99999999999999999999765152600307720350;
            ith_term[69] =99999999999999999999882576300153860180;
            ith_term[70] =99999999999999999999941288150076930090;
            ith_term[71] =99999999999999999999970644075038465050;
            ith_term[72] =99999999999999999999985322037519232530;
            ith_term[73] =99999999999999999999992661018759616270;
            ith_term[74] =99999999999999999999996330509379808140;
            ith_term[75] =99999999999999999999998165254689904070;
            ith_term[76] =99999999999999999999999082627344952040;
            ith_term[77] =99999999999999999999999541313672476020;
            ith_term[78] =99999999999999999999999770656836238010;
            ith_term[79] =99999999999999999999999885328418119010;
            ith_term[80] =99999999999999999999999942664209059510;
            ith_term[81] =99999999999999999999999971332104529760;
            ith_term[82] =99999999999999999999999985666052264880;
            ith_term[83] =99999999999999999999999992833026132440;
            ith_term[84] =99999999999999999999999996416513066220;
            ith_term[85] =99999999999999999999999998208256533110;
            ith_term[86] =99999999999999999999999999104128266560;
            ith_term[87] =99999999999999999999999999552064133280;
            ith_term[88] =99999999999999999999999999776032066640;
            ith_term[89] =99999999999999999999999999888016033320;
            ith_term[90] =99999999999999999999999999944008016660;
            ith_term[91] =99999999999999999999999999972004008330;
            ith_term[92] =99999999999999999999999999986002004170;
            ith_term[93] =99999999999999999999999999993001002090;
            ith_term[94] =99999999999999999999999999996500501050;
            ith_term[95] =99999999999999999999999999998250250530;
            ith_term[96] =99999999999999999999999999999125125270;
            ith_term[97] =99999999999999999999999999999562562640;
            ith_term[98] =99999999999999999999999999999781281320;
            ith_term[99] =99999999999999999999999999999890640660;
          }

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

          /// Log functions
          // 18DP. x is fixed point 18Dp as uint. i is uint.

          // Valid for x in [1,2[
          // remember ith_term array is zero-indexed, code accordingly...

          function log2(uint x, uint accuracy) public view returns (uint) {
            require(x >= QUINT && x < 2 * QUINT, 'input x must be within range [1,2[');
            uint prod = x * TEN20;
            uint newProd = ONE_38_ZEROS;
            uint output = 0;

            for (uint i = 1; i <= accuracy; i++) {
              newProd = decMul38(ith_term[i], prod);

              if (newProd >= ONE_38_ZEROS) {
                prod = newProd;
                output += powersOfTwo[i];
              }
            }
            return convertTo18DP(output);
          }
        }
