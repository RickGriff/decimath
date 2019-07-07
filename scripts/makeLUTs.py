# Python script that prints the lookup tables (LUTs) for the log(x) and 2^x algorithms used in DeciMath.

# The outputs of this file - the printed LUTs - are hard-coded into the DeciMath solidity contract.
# Using LUT-based algorithms in DeciMath confers a performance advantage in Solidity. It costs significantly less gas
# than computing each fixed-point term.

import decimal as dec
dec.getcontext().prec = 39

##### LOG FUNCTIONS #####

# logarithm algorithm, base-2.  Valid for x in [1,2[.
def log2(x, precision):
    prod = dec.Decimal(x)
    output = 0

    for i in range(1, precision):
        newProd = prod * term_log2(i)
        print("term_log2(i) is {}".format(str(term_log2(i))))
        print("newProd is {}".format(str(newProd)))
        if newProd >= 1:
            prod = newProd
            output += secondTerm_log2(i)
            print(output)
    return output

# The i'th term in the first log2 lookup table:  1/( 2^(1/2^i) )
def term_log2(i):
    num = dec.Decimal(i)
    term = 1 / (2**(1/2**num))
    return term

# The i'th term in the second log2 lookup table:  1/(2^i)
def secondTerm_log2(i):
    num = dec.Decimal(2)**(-i)
    return num


##### HELPERS #####

def count_leading_zeros(num):
    count = 0
    while num <= 1:
        num *= 10
        count += 1
    return count

def make_log2_LUT2_entry(num):
    # convert to 38 DP
    num = num.quantize(dec.Decimal('1.00000000000000000000000000000000000000'))
    # suppress scientific notation, and chop leading zeros
    return '{0:f}'.format(num)[(count_leading_zeros(num) + 1):]

##### LOG2 LOOKUP TABLE PRINTERS #####

# Create LUT tables for use in DeciMath's log2() function. 
# Values are integer representations of fixed-point 18 DP decimals.

def make_log2_LUT(n):
    for i in range(n):
        with dec.localcontext() as ctx:   # do calculation in high precision
            ctx.prec = 60
            term = term_log2(i)
        term = +term  # round back down to 38 DP

        tableKey = str(i)
        fractPart = str(term)[2:]

        outputString = "table_log2[{}] = {};".format(tableKey, fractPart)
        print(outputString)

def make_log2_LUT2(n):
    for i in range(n):
        with dec.localcontext() as ctx:
            ctx.prec = 60
            term = secondTerm_log2(i)
        term = +term

        tableIndex = str(i)
        tableEntry = make_log2_LUT2_entry(term)

        outputString = "table2_log2[{}] = {};".format(tableIndex, tableEntry)
        print(outputString)


##### POW2 FUNCTIONS #####

# i'th term in the pow2 lookup table
# i'th term is 2^(1 / 10^(i + 1))
def term_pow2(i):
    num = dec.Decimal(i)
    term = 2 ** (1 / (10 ** (num + 1)))
    return term

# Valid for x in range [1,2[
def pow2(x):
    prod = 2
    fractPart = x[2:]  # grab the digits after the point
    digits = [int(i) for i in fractPart]

    # // loop and multiply each digit of mantissa by Lookup-table value
    for i in range(len(fractPart)):
        term = term_pow2(i) ** digits[i]
        prod = prod * term

    return prod

##### POW2 LOOKUP TABLE PRINTERS #####

# Create LUT tables for use in DeciMath's pow2() function. 
# Values are integer representations of fixed-point 18 DP decimals.
def make_pow2_LUT(n):
    for i in range(n):
        with dec.localcontext() as ctx:
            ctx.prec = 60
            term = term_pow2(i)  # do calculation in high precision
        term = +term  # round back down to 38 DP

        tableIndex = str(i)
        fractPart = str(term)[2:]

        outputString = "table_pow2[{}] = 1{};".format(tableIndex, fractPart)
        print(outputString)


# A more extensive lookup table for pow2().
# We make a 2-D array LUT[i][d] = (2^(1 / 10^(i + 1)))^d.  d ranges 0-9.

# The LUT contains N arrays, each length 10.
# This LUT allows us to skip the exponentiation at each step in the pow2() algorithm.
# Using this extended LUT in the contract confers significantly lower gas usage, and slightly lower error.
# This function prints table as text, for use in the contract.
def make_pow2_LUT_2d(n):
    for i in range(n):
        for d in range(10):
            with dec.localcontext() as ctx:
                ctx.prec = 60
                term = pow(term_pow2(i), d)
            term = +term
            tableIndex = str(i)
            exponent = str(d)

            if d == 0:
                # return 1 for anything raised to power 0
                trailingZeros =  str('0'*38)
                outputString = "table_pow2[{}][{}] = 1{};".format(tableIndex, exponent, trailingZeros)
                print(outputString)

            else:
                fractPart = str(term)[2:] 
                outputString = "table_pow2[{}][{}] = 1{};".format(tableIndex, exponent, fractPart)
                print(outputString)


##### FUNCTION CALLS ######

# make_pow2_LUT(40)
# make_pow2_LUT_2d(40)

# make_log2_LUT(100)
# make_log2_LUT2(100)
