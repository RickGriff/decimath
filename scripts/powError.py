# Python script for testing  round-off error produced by the algorithm implentations in DeciMath contract.

# Why? Round-off error accumulates with successive multiplication. This script gives us insight into how error varies with base and exponent.

# The script compares algorithm implementations to python's native exponential functions.
#
# Results are ballpark, as python's native exponentiation is itself approximate and imprecise.
#
# Algorithms tested:
# -Exponentiation by Squaring - b^n,  for decimal base 'b' and natural exponent 'n'
# -Taylor series expansion of e^n

import math
import numpy as np
import decimal as dec
dec.getcontext().prec = 38

QUINT = 10**18  # One quintillion
TEN20 = 10**20
TEN38 = 10**38

# Decimal multiplication funcs. 2DP and 18DP
def decMul2(a, b):
    prod_ab = a*b
    decProduct =  (prod_ab + 50 ) / 100
    return decProduct

def decMul18(a, b):
    prod_ab = a*b
    decProduct =  (prod_ab + (QUINT / 2) ) / QUINT
    return decProduct


##### EXP FUNCS #####

#Exponentiation-by-squaring algorithm. Base 'b' and output are integer representations of 2DP decimals.
# '100' represents '1.00'. Exponent n is integer.
def exp_square2(base, n):
    if n == 0:
        return 100

    y = 100

    while n > 1:
        if n % 2 == 0:
            base = decMul2(base, base)
            n = n / 2
        elif n % 2 != 0:
            y = decMul2(base, y)
            base = decMul2(base, base)
            n = (n - 1)/2
    return decMul2(base, y)

# 18DP Exponentiation-by-squaring. 1 QUINT represents 1.000000000000000000 .
def exp_square18(base, n):
    if n == 0:
        return QUINT

    y = QUINT

    while n > 1:
        if n % 2 == 0:
            base = decMul18(base, base)
            n = n / 2
        elif n % 2 != 0:
            y = decMul18(base, y)
            x = decMul18(base, base)
            n = (n - 1)/2
    return decMul18(base, y)

# e^x, using Taylor series expansion to 18 DP
def exp18(n):
    tolerance = 0.000000000000000001
    term = 1.0
    sum = 1
    i = 0

    while term > tolerance:
        i += 1
        term = term * n / i
        sum += term
    print("number of iterations to compute e^" +"(" + str(n) + "): " + str(i))
    return sum

##### LOG FUNCS #####

# helper function - calculate terms in log2(x)
# // Replace this computation by lookup table
def term_log2(x, i):
    x = dec.Decimal(x)
    denom = dec.Decimal('2')
    # ((1/2.0)**i)
    for j in range(i):
        denom = denom.sqrt()

    term  = x / denom
    return term

# logarithm base 2, first attempt.
# Valid for x [1,2[
def log2(x, precision):
  # For binary, we can also compute each digit a1, a2, etc
    digits = []
    termInput = dec.Decimal(x)
    #compute t1 = x/root(2)
    output  = 0
    for i in range(1, precision):
        digits += [dec.Decimal(2)**(-i-1)]

        t = term_log2(termInput, i)
        if t >= 1:
            termInput = t
            output += digits[i-1]
    # print "digits array is:"
    # print(digits)

    # for pair in digits:
    #     mantissa += (pair[0] * pair[1]) * 2

    return output * 2

# Used only to output a lookup table of powers-of-two. Not used in log2(x) func.
def powerOfTwo(i):
  num = dec.Decimal(2)**(-i)
  return num


def print_powersOfTwo(n):
    print("printing 1/(2^((1/2)^i)) up to i = " + str(n))
    for i in range(0,n):
        pow = '%.72f' % powerOfTwo(i)

        print ("powersOfTwo[" + str(i) + "] = " + str(pow))

def print_powersOfTwo_fractPart(n):
    print("printing 1/(2^((1/2)^i)), up to i = " + str(n))
    for i in range(1,n):
        pow = '%.72f' % powerOfTwo(i)
        print ("powersOfTwo[" + str(i) + "] = (0.)" + str(pow)[2:40] + ";")


##### LOG2 LOOKUP TABLE #####

# The n'th term in the log2 lookup table
# n'th term is  1/(2^(1/2^n))

def term_log2(n):
    n = dec.Decimal(n)
    term = 1 / (2**(1/2**n))
    return term

def make_log2_LUT(n):
        for i in range(n):
            with dec.localcontext() as ctx:
                ctx.prec = 60
                term = term_log2(i) # perform calculation in high precision
            term = +term # round back down to 38 DP
            print("table_log2[" + str(i) + "] = " + str(term)[2:] + ";")







# Holds only for range [0, 1[
def check_log2(n):
    print("Check log2(x) up to x = " + str(n)) +"\n"
    for j in range(1, n):
        j = 1 + j / 100.0 # check range [1..2]
        res = log2(j, 50)
        py_log2 = math.log(j, 2)
        print("Algo log2(" + str(j) + ") is: "+ str(res))
        print ("py native log2(" + str(j) +") is: " + str(py_log2)) +"\n"

def check_terms_fractPart(n):
    print("Check terms up to i =  " + str(n))  +"\n"
    for i in range(1,n):
        print("ith_term["+ str(i) +"]" + " =" + "(0.)" + str(term_log2(1,i))[2:] + ";")

def check_terms(n):
    print("Check terms up to i =  " + str(n))  +"\n"
    for i in range(1,n):
        print("i = " + str(i) + "." + " term = 1/(2^((1/2)^"+ str(i) +")): " + str(term_log2(1,i)) )



##### TWO_X FUNCS #####

# n'th term in the 2^x lookup table
# n'th term is 2^(1 / 10^(n + 1))
def term_2_x(n):
    n = dec.Decimal(n)
    term  = 2 ** (1 / (10 ** (n + 1)))
    return term

# Valid for x = 1.m i.e. x in range [1,2[
def two_x(x):
    prod = 2
    fractPart = x[2:] # grab the digits after the point
    digits = [int(i) for i in fractPart]

    # // loop and multiply each digit of mantissa by Lookup-table value
    for i in range (len(fractPart)):
        term = term_2_x(i) ** digits[i]
        prod = prod * term

    return prod

# Generate a Lookup table of terms, from the term_2_x() function.
# Prints table as text for use in the Solidity contract.
def make_two_x_LUT(n):
    for i in range(n):
        with dec.localcontext() as ctx:
            ctx.prec = 60
            term = term_2_x(i) # perform calculation in high precision
        term = +term # round back down to 38 DP
        print("term_2_x[" + str(i) + "] = 1." + str(term)[2:] + ";")



# A more extensive lookup table for two_x().
# We make a 2-D array LUT[i][d] = (2^(1 / 10^(i + 1))) ** d.  d ranges 0-9.
# The LUT contains 38 arrays, each length 10.
# This LUT allows us to skip the exponentiation at each step in the two_x() algorithm, and thus reduces
# a source of round-off error.

# Function prints table as text, for use in the Solidity contract.

def make_two_x_LUT_2d(n):
    for i in range(n):
        for d in range(10):

            with dec.localcontext() as ctx:
                ctx.prec = 60
                term = pow(term_2_x(i), d) # perform calculation in high precision
            term = +term

            if d == 0:
                print("term_2_x[" + str(i) + "]["+ str(d) + "] = 1" + str('0'*38) + ";")
            else:
                print("term_2_x[" + str(i) + "]["+ str(d) + "] = 1" + str(term)[2:] + ";")










##### FUNCTION CALLS ######

# print_powersOfTwo(100)

# print(two_x('1.000000000000000001'))
# print(two_x('1.500000000000000000'))
# print(two_x('1.999999999999999999'))
# make_two_x_LUT(40)
# make_two_x_LUT_2d(40)


make_log2_LUT(100)

# check_terms_fractPart(100)

# check_log2(100)

# Error checking funcs

def exp18Error(n):
    for j in range(0, n):
        j =  j / 10.0
        algo_exp = exp18(j)
        py_exp = math.exp(j)
        error_percent = (py_exp - algo_exp) *100  / py_exp
        print("n: " + str(j) + ", exp18(n): " + str(algo_exp) + ", py exp(n): " + str(py_exp) + ", error percent: " + str(error_percent)+ "%")

# Compute the error produced by exp_square algorithm at 2DP
def exp_square2_errors(base, n):
    for i in range(0, n):
        print("base: " + str(base/100.0) + ", n: "+ str(i))

        exp = exp_square2(base, i)
        exp_as_float = exp / 100.0
        expPy = (base / 100.0) ** i
        err = (expPy - exp_as_float) / expPy

        err_percent = str(err * 100.00) + " %"
        print(exp, exp_as_float, expPy, err_percent)

# Compute the error produced by exp_square algorithm at 2DP
def exp_square18_errors(base, n):
    for i in range(0, n):
        print("base: " + str(base/float(QUINT)) + ", n: "+ str(i))

        exp = exp_square18(base, i)
        exp_as_float = exp / float(QUINT)
        expPy = (base/float(QUINT)) ** i
        err = (expPy - exp_as_float) / expPy

        err_percent = str(err * 100.00) + " %"
        print(exp, exp_as_float, expPy, err_percent)
