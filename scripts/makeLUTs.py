# Python script for testing the log(x) and 2^x algorithms used in DeciMath, and printing their respective lookup tables (LUTs).

# The outputs of this file - the printed LUTs - are hard-coded into the DeciMath solidity contract.
# Using LUT-based algorithms in DeciMath confers a performance advantage in Solidity: it costs significantly less gas
# than computing each fixed-point term.

import decimal as dec
dec.getcontext().prec = 39

##### LOG FUNCTIONS #####

# logarithm algorithm, base-2.  Valid for x in [1,2[.
def log2(x, precision):
    prod = dec.Decimal(x)
    output  = 0

    for i in range(1, precision):
        newProd = prod * term_log2(i)
        print("term_log2(i) is" + str(term_log2(i)))
        print("newProd is" + str(newProd))
        if newProd >= 1:
            prod = newProd
            output += secondTerm_log2(i)
            print(output)
    return output

# The i'th term in the first log2 lookup table.
# The i'th term is  1/(2^(1/2^i)).
def term_log2(i):
    num = dec.Decimal(i)
    term = 1 / (2**(1/2**num))
    return term

# The i'th term in the second log2 lookup table.
# The i'th term is 1/(2^i)
def secondTerm_log2(i):
    num = dec.Decimal(2)**(-i)
    return num


##### HELPERS #####

# Return the number of leading zeros in a decimal
def leading_zeros(num):
    count = 0
    while num <= 1:
        num *= 10
        count += 1
    return count

def make_log2_LUT1_entry(num):
    num = num.quantize(dec.Decimal('1.00000000000000000000000000000000000000'))  # convert to 38 DP
    return '{0:f}'.format(num)[(leading_zeros(num) + 1):] # suppress sci. notation, and chop leading zeros

##### LOG2 LOOKUP TABLE PRINTERS #####
# Create LUT tables for use in DeciMath's log2() function. Values are integer representations of fixed-point 18 DP decimals.

def make_log2_LUT(n):
        for i in range(n):
            with dec.localcontext() as ctx:
                ctx.prec = 60
                term = term_log2(i) # perform calculation in high precision
            term = +term # round back down to 38 DP
            print("table_log2[" + str(i) + "] = " + str(term)[2:] + ";")

def make_log2_LUT2(n):
        for i in range(n):
            with dec.localcontext() as ctx:
                ctx.prec = 60
                term = secondTerm_log2(i)
            term = +term
            print("table2_log2[" + str(i) + "] = " + make_log2_LUT1_entry(term)  + ";") #'{0:f}'.format(term)

##### POW2 FUNCTIONS #####

# i'th term in the pow2 lookup table
# i'th term is 2^(1 / 10^(i + 1))
def term_pow2(i):
    num = dec.Decimal(i)
    term  = 2 ** (1 / (10 ** (num + 1)))
    return term

# Valid for x in range [1,2[
def pow2(x):
    prod = 2
    fractPart = x[2:] # grab the digits after the point
    digits = [int(i) for i in fractPart]

    # // loop and multiply each digit of mantissa by Lookup-table value
    for i in range (len(fractPart)):
        term = term_pow2(i) ** digits[i]
        prod = prod * term

    return prod

##### POW2 LOOKUP TABLE PRINTERS #####

# Create LUT tables for use in DeciMath's pow2() function. Values are integer representations of fixed-point 18 DP decimals.
def make_pow2_LUT(n):
    for i in range(n):
        with dec.localcontext() as ctx:
            ctx.prec = 60
            term = term_pow2(i) # perform calculation in high precision
        term = +term # round back down to 38 DP
        print("table_pow2[" + str(i) + "] = 1." + str(term)[2:] + ";")


# A more extensive lookup table for two_x().
# We make a 2-D array LUT[i][d] = (2^(1 / 10^(i + 1)))^d.  d ranges 0-9.
# The LUT contains 38 arrays, each length 10.
# This LUT allows us to skip the exponentiation at each step in the pow2() algorithm.
# Using this extended LUT in the contract confers significantly lower gas usage, and slightly lower error.
# The function prints table as text, for use in the contract.
def make_pow2_LUT_2d(n):
    for i in range(n):
        for d in range(10):
            with dec.localcontext() as ctx:
                ctx.prec = 60
                term = pow(term_pow2(i), d)
            term = +term

            if d == 0:
                print("table_pow2[" + str(i) + "]["+ str(d) + "] = 1" + str('0'*38) + ";")  # return 1 for anything raised to power 0
            else:
                print("table_pow2[" + str(i) + "]["+ str(d) + "] = 1" + str(term)[2:] + ";")


##### FUNCTION CALLS ######

# print(pow2('1.000000000000000001'))
# print(pow2('1.500000000000000000'))
# print(pow2('1.999999999999999999'))
# print(pow2('1.999999999999999999'))

# print(log2(1.5, 70))
# make_pow2_LUT(40)
# make_pow2_LUT_2d(40)

# make_log2_LUT(100)
# make_log2_LUT2(100)
