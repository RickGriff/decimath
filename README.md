- [DeciMath](#decimath)
  * [Representing Decimals in Solidity](#representing-decimals-in-solidity)
  * [Getting Started](#getting-started)
  * [Initial Setup - Setting the DeciMath Lookup Tables](#initial-setup---setting-the-decimath-lookup-tables)
  * [DeciMath Functions](#decimath-functions)
  * [Function Gas Costs](#function-gas-costs)
  * [Maximum Inputs - overflow limits](#maximum-inputs---overflow-limits)
  * [Where are DeciMath Functions Useful?](#where-are-decimath-functions-useful?)
  * [Testing DeciMath Functions](#testing-decimath-functions)
  * [Convert Numbers to and from DeciMath format with makeBN.js](#convert-numbers-to-and-from-decimath-format-with-makebnjs)
  * [Calculating Gas and Error with gasCalculator.js](#calculating-gas-and-error-with-gascalculatorjs)
  * [Error Estimate Tables](#error-estimates)
  * [License](#license)

# DeciMath 

DeciMath is an efficient-gas parent contract for fixed-point mathematics in Solidity. It offers basic decimal operations, and as well as transcendental functions - `exp(x)`, `ln(x)` and `pow(b, x)` - for numbers of 18-decimal-place precision.

Solidity does not support native fixed-point mathematics, so I made DeciMath.

## Representing Decimals in Solidity

In DeciMath, fixed-point decimals are represented by uints. Functions take uint parameters, and perform fixed-point operations, to a specified number of digits of precision (DP).

### Input Examples

| Number | uint representation at 18 digits of precision |
| ---------- | ------------------------------------------------------------------ |
| 1 | 1000000000000000000 |
| 1.25 | 1250000000000000000 |
| 37 | 37000000000000000000 |
| 0.000003 | 3000000000000 |
| 0.000000000000000005 | 5 |

**Function example:** the function `decMul18()` outputs the product of two 18DP fixed-point decimals.

**Normal multiplication**:  

`2.5 * 0.005     // returns 0.0125`

**DeciMath multiplication**:

`decMul18(2500000000000000000, 50000000000000000)     // returns 1250000000000000`

## Getting Started

DeciMath is an inheritable parent contract.

To use DeciMath functions in your contracts, simply copy the *DeciMath.sol* contract into your project and inherit from it.

## Initial Setup - Setting the DeciMath Lookup Tables

DeciMath uses three lookup tables (LUTs) in its algorithms for efficient computation.

Before you can call math functions on a deployed DeciMath instance, you need to set the lookup tables - I.e. write the table data to your contract’s storage.

With your DeciMath instance deployed, you must manually call the table setter functions via separate transactions before you can use the the `exp()`, `ln()` or `pow()` functions.

Set lookup tables by calling the LUT setter functions **once each**:

```
setLUT1()
setLUT2()
setLUT3_1()
setLUT3_2()
setLUT3_3()
setLUT3_4()
```
**Reason:** Lookup tables make the math function calls gas-efficient, but it costs around 12 million gas upfront to write all table data to the blockchain.

To avoid large deployment costs, set the LUTs with individual transactions after the contract is deployed. 

## DeciMath Functions

### Basic mathematical functions, equivalent to SafeMath (not fixed-point)

`add(x,y)`

`div(x,y)`

`sub(x,y)`

`mul(x,y)`

### Fixed-point mathematical functions

| Function           | Input                            | Description                                                       | Valid for |
|--------------------|----------------------------------|-------------------------------------------------------------------|-----------|
| decMul18(x,y)      | Fixed-point 18DP                 | Multiplies two fixed-point numbers                                | x, y >= 0 |
| devDiv18(x,y)      | Fixed-point 18DP                 | Divides one fixed-point by another                                | x, y > 0  |
| exp(x)             | Fixed-point 18DP                 | Exponential function. Algorithm based on lookup tables.           | x >= 0    |
| exp_taylor(x)      | Fixed-point 18DP                 | Exponential function. Algorithm based on taylor series expansion. | x >= 0    |
| ln(x)              | Fixed-point 18DP                 | Natural logarithm.                                                | x >= 1    |
| powBySquare18(b,x) | b:  18DP, x: integer | General exponentiation. Fixed-point base, integer exponent        | b, x >= 0 |
| pow(b,x)           | Fixed-point 18DP                 | General exponentiation. Fixed-point base and exponent             | b, x >= 0 |

## Function Gas Costs

The algorithms have gas costs in the following ranges (calculated from large sample of calls with randomized input params):

| function            | gas range |
|---------------------|-----------|
| ln(x, accuracy=70)  | 60-63k   |
| exp(x)              | 31-34k    |
| pow(b,x)            | 85k-94k |
| powBySquare18(b,x)  | 3-10k    |
| powBySquare(b,x)    | 3-10k    |     
| exp_taylor(x)       | 14-197k   |
   
The 21k transaction fee is excluded.

Thanks to the lookup-table algorithms, **DeciMath functions have near constant gas usage.**  Performance is stable for both very small and very large bases, exponents and arguments.

The accuracy of `ln(x)` increases with the number of iterations in the algorithm. Above 70 iterations, accuracy plateaus - but gas continues to increase. You can use a lower number of iterations if you’re willing to trade accuracy for lower gas cost.

The gas of `exp_taylor(x)` roughly linearly with the exponent. It is included for comparison with the LUT-based algorithms.

## Where are DeciMath Functions Useful?

All functions have a level of error - their usefulness depends, to a degree, on the level of accuracy you need.

Error tables at the end of this document show how percentage errors vary with inputs. You can use gasCalculator.js to calculate errors and gas costs for specific input ranges.

### Function Accuracy 

`ln(x)` is **very accurate** - max percentage error is nearly constant, and outputs are always < 100 - thus `ln(x)` is always accurate to at least 17 decimal places.

`exp(x)` and `exp_taylor(x)` have nearly constant percentage error, but output grows exponentially. **Thus, `exp()` functions are most accurate at lower exponent.** `exp(10)` is accurate to at least 10 decimal places, while `exp(60)` is accurate to the nearest 1e6. 

`pow(b,x)` **is most accurate in the middle ranges** - e.g base 0.1 - 10, with exponent 0 - 15, here it accurate to at least several decimal places. It is least accurate at the extremes: at high base, or base  ≈1 with very high exponent - domains with both large output and percentage error.

**For pow() with an integer exponent, use `powBySquare18()` over `pow()`** - it costs less gas, and offers better precision, particularly at higher base. `powBySquare18()` has mostly zero error for exponent < 100 and base < 1.

## Maximum Inputs - Overflow Limits

Functions will revert if an internal multiplication produces a uint256 overflow. The limits of each function depend on the operations performed, and vary between the specific algorithms. 

When a function reverts due to overflow, the overflow error bubbles up from the basic operation that caused it.

### Input limits - single parameter functions

| Function      | overflows for x > ... |
|---------------|-----------------------|
| exp(x)        | 89                    |
| exp_taylor(x) | 92                    |
| ln(x)         | 1.1e41                |
### Input Limits - Two-Parameter functions
The maximum base is 1.1e41.  The max exponent depends on the base:

**pow(b,x)**

For x < 1:

| base                  | 1e-10 | 1e-6 | 1e-5 | 1e-4 | 0.001 | 0.01 | 0.1 | 0.5 |
|-----------------------|--------|-------|-------|-------|--------|-------|------|------|
| overflow at x >  | 3.9    | 6.5   | 7.8   | 9.5   | 13     | 19    | 39   | 129  | 
 
For x > 1:

| base                  | 1.1 | 1.5 | 2 | 10 | 50 | 100 | 1000 | 10000 | 1e5 | 1e6 | 1e10 | 1e20 | 1e30 | 1e40 |
|-----------------------|------|------|-----|-----|-----|------|-------|--------|------|------|-------|-------|-------|-------|
| overflow at x >  | 940  | 220  | 129 | 39  | 22  | 19   | 13    | 9.5    | 7.8  | 6.5  | 3.9   | 1.85  | 1.3   | 0.95  |

**powBySquare18(b,x)**

| base                  | <1        | 1.1 | 1.5 | 2   | 10 | 50 | 100 | 1000 | 1e4 | 1e5 | 1e6 | 1e10 | 1e20 |
|-----------------------|-----------|-----|-----|-----|----|----|-----|------|------|------|------|-------|-------|
| overflow at x > | unlimited | 990 | 230 | 136 | 41 | 24 | 19  | 13   | 10   | 8    | 6    | 4     | 2     |

These are a sample of values. The two-parameter functions have a boundary overflow limit in the plane of (base, exponent) - higher bases have lower maximum exponents.


## Testing DeciMath Functions

Tests for all functions are provided as *.sol* files in /tests, written for the Truffle framework.

Copy tests to your /tests folder, and run:

`truffle test`

## Convert Numbers to and from DeciMath format with makeBN.js 

DeciMath inputs and outputs are always integer-representations of decimals. 

DeciMath comes with the node module makeBN.js for converting numbers to and from DeciMath format.

### Usage

On a dApp front-end, web3 accepts BN objects as contract call parameters. Use makeBN.js to convert numbers to uint representations of decimals that DeciMath expects, in BN form.

DeciMath-format BNs can be passed as function parameters via web3 contract calls.

### Installation

 - Copy makeBN.js in to your project (e.g. /scripts or /utils), and import makeBN.js to your front-end application:

`const makeBN = require('./makeBN.js');`

 - Call the conversion functions as needed:

**Convert string to DeciMath-format BN for a contract call:**

`makeBN.makeBN18`  // convert a string to a uint representation of a decimal in BN form - for input to DeciMath functions via web3.

Example:

`makeBN18(‘0.0123’)`    // returns new BN(12300000000000000) 

**Convert a returned DeciMath-format BN to a Decimal:**

`makeBN.makeDecimal18`  //convert a uint representation of a decimal in BN form - I.e. the return value of a web3 DeciMath contract call - to a JS Decimal object.

Example:

`makeDecimal18(BN(123456789987654321000000000))`  // returns a new Decimal(‘123456789.987654321’)

makeBN requires the basic JS math libraries Decimal.js and BN.js.

## Calculating Gas and Error with gasCalculator.js

DeciMath comes with a gas and error calculator - gasCalculator.js. It contains several functions for computing the gas & error of each DeciMath math function. Use it to explore the gas costs and error percentages of the different math functions at different input ranges.

The file runs as an external JS script in your Truffle development environment. All functions are async/await since they call the contract on the blockchain.

### Gas Calculator Setup

- Copy the /scripts folder to your Truffle project.  This contains gasCalculator.js and its dependencies.
- Copy *DeciMathCaller.sol* to your /contracts folder ( needed to make raw calls to DeciMath functions, to test actual gas usage)

- Launch your development blockchain (e.g. Ganache)
- Compile and migrate your contracts:

```
truffle compile
truffle migrate --reset
```

To test particular gas and error of DeciMath functions, place the appropriate calculator function(s) at the end of the script. 

- In the gasCalculator directory, run the script via:

```
truffle console
exec gasCalculator.js
```

Results will print to the console. Functions take string arguments, to avoid Javascript’s maximum integer limit.

### Gas and Error functions

**One-off function calls**

Example: `gasPrinter.exp(n)`

These functions call their corresponding math function in DeciMath once. They log gas cost and percentage error to the console, and return them in an array. 

**Iterative function calls**

Example: `gasPrinter.exp_upTo(n, increment)`

These functions repeatedly call their corresponding DeciMath functions, with their main argument increasing from it’s minimum, to arbitrary n, in specified increments.

Use them to see how a functions gas cost and percentage error vary with input.

**Mean gas and error calculators**

Example: `gasPrinter.exp_mean(min, max, timesToCall)`

Errors and gas vary depending on function argument. These functions call their respective DeciMath function multiple times with random arguments between a given range, and returns the average gas cost and percentage error. 

## Error Estimates

These tables show the maximum and average error for inputs in different ranges. Tables are produced from a large sample of calls with randomized input. 

### Single parameter functions

**ln(x)**

| x            | Avg. gas | Min % error | Max % error  | Avg. % error |
|--------------|----------|-----------|------------|------------|
| 1 to 10      | 58616    | 0         | 1.4e-16 | 9.4e-18 |
| 10 to 1000   | 58638    | 0         | 4.6e-17 | 2.3e-18 |
| 1000 to1e10  | 59243    | 0         | 4.9e-18 | 8.4e-19 |
| 1e10 to 1e20 | 60089    | 0         | 2.3e-18 | 3.6e-19 |
| 1e20 to 1e30 | 60529    | 0         | 1.5e-18 | 2.3e-19 |
| 1e30 to 1e41 | 61564    | 0         | 1.1e-18 | 1.9e-19 |

**exp(x)**

| x            | Avg. gas | Min % error | Max % error  | Avg. % error |
|--------------|----------|-----------|------------|------------|
| 1 to 10      | 58616    | 0         | 1.4e-16 | 9.4e-18 |
| 10 to 1000   | 58638    | 0         | 4.6e-17 | 2.3e-18 |
| 1000 to1e10  | 59243    | 0         | 4.9e-18 | 8.4e-19 |
| 1e10 to 1e20 | 60089    | 0         | 2.3e-18 | 3.6e-19 |
| 1e20 to 1e30 | 60529    | 0         | 1.5e-18 | 2.3e-19 |
| 1e30 to 1e41 | 61564    | 0         | 1.1e-18 | 1.9e-19 |

**exp_taylor(x)**

| x        | Avg. gas | Min % error | Max % error | Avg. % error |
|----------|----------|-----------|-----------|------------|
| 0 to 1   | 14240    | 0         | 2.8e-16 | 6e-17     |
| 1 to 10  | 30966    | 0         | 1.4e-16  | 8e-18     |
| 10 to 30 | 62302    | 5.4e-22', | 1.2e-18  | 2e-19     |
| 30 to 60 | 112004   | 5.6e-22'  | 1.3e-19  | 3e-20     |
| 60 to 92 | 168357   | 8.8e-23   | 3.8e-20  | 1e-20     |

### Errors Estimates - Two-Parameter Functions

Different bases have different max exponents before overflow. Here are max and average percentage error for different base ranges, up to the max exponent for the upper end of the range.

**pow(b,x)**

| Base          | max exponent before overflow | Avg. gas | Min % error | Max % error | Avg. % error |
|---------------|------------------------------|----------|-----------|-----------|------------|
| **b < 1**         |                              |          |           |           |            |
| 1e-6 to 1e-10 | 3.5                          | 87785   | 0         | 4.7e-16  | 2.3e-18   |
| 1e-5 to 1e-6  | 6.5                          | 88532   | 0         | 1.8e-16  | 1e-18     |
| 1e-4 to 1e-5  | 7.8                          | 88322   | 0         | 4.8e-16  | 3.4e-18   |
| 1e-3 to 1e-4  | 9.5                          | 88151   | 0         | 1.7e-16  | 5.7e-19   |
| 0.01 to 1e-3  | 13                           | 87835   | 0         | 1.5e-16  | 5e-19     |
| 0.1 to 0.01   | 19                           | 87835   | 0         | 3.6e-15  | 1.2e-17   |
| 0.5 to 0.1    | 39                           | 87979   | 0         | 1.71e-15 | 8.3e-18   |
| 1 to 0.5      | 129                          | 87052   | 0         | 7.5e-14  | 8.5e-16   |
|**b > 1**         |                              |          |           |           |            |
| 1 to 1.1      | 940                          | 86073   | 3.6e-17   | 4.5e-14  | 1.1e-14   |
| 1.1 to 1.5    | 220                          | 86609   | 0         | 1e-14    | 2.6e-15   |
| 1.5 to 2      | 129                          | 87065   | 0         | 6.3e-15  | 1.5e-15   |
| 2 to 10       | 39                           | 87550   | 0         | 2.7e-15  | 6e-16     |
| 10 to 50      | 22                           | 87418   | 0         | 1.6e-15  | 3.2e-16   |
| 50 to 100     | 19                           | 87467   | 0         | 1.1e-15  | 2.7e-16   |
| 100 to 1000   | 13                           | 87344   | 0         | 1.e-15   | 1.8e-16   |
| 1000 to 10^4  | 9.5                          | 88159   | 0         | 9.3e-16  | 1.7e-16   |
| 1e4 to 1e5    | 7.8                          | 87943   | 0         | 5.4e-16  | 1e-16     |
| 1e5 to 1e6    | 6.5                          | 88165   | 0         | 5.5e-16  | 9e-17     |
| 1e6 to1e10    | 3.9                          | 87992   | 0         | 3.0e-16  | 5.6e-17   |
| 1e10 to 1e20  | 1.85                         | 88872   | 0         | 1.6e-16  | 3.9e-17   |
| 1e20 to 1e30  | 1.3                          | 89492   | 0         | 1.1e-16  | 3.2e-17   |
| 1e30 to 1e40  | 1.95                         | 90443   | 0         | 9.8e-17  | 2.8e-17   |

**powBySquare18(b,x)**

| Base         | max exponent before overflow | Avg. gas | Min % error | Max % error   | Avg. % error |
|--------------|------------------------------|----------|-----------|-------------|------------|
| 1 to 1.1     | 990                          | 8914    | 0         | 3.04e-14 | 6.5e-15 |
| 1.1 to 1.5   | 230                          | 8701    | 0         | 4.5e-15  | 8.6e-16 |
| 1.5 to 2     | 136                          | 7052    | 0         | 1.4e-15  | 2.8e-16 |
| 2 to 10      | 41                           | 6098    | 0         | 1.2e-16  | 1.1e-17 |
| 10 to 50     | 24                           | 5624    | 0         | 2.7e-18  | 2.4e-19 |
| 50 to 100    | 19                           | 5491    | 0         | 1.3e-19  | 2.1e-20 |
| 100 to 1000  | 13                           | 5193    | 0         | 1.9e-20  | 7.6e-22 |
| 1000 to 1e4  | 10                           | 5062    | 0         | 8.1e-23  | 4.7e-24 |
| 1e4 to 1e5   | 8                            | 4915    | 0         | 8.7e-25  | 3.3e-26 |
| 1e5 to 1e6   | 6                            | 4638    | 0         | 6.4e-27  | 1.8e-28 |
| 1e6 to 1e10  | 4                            | 4536    | 0         | 4.5e-34  | 2.9e-36 |
| 1e10 to 1e20 | 2                            | 4592    | 0         | 4.1e-48  | 2.4e-49 |

## License
