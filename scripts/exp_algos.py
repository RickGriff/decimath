#  Exponentiation algorithms in Python.
#  exp(x) is implemented with 1) an exponentiation-by-squaring algorithm for integer exponent,
#  and 2) a Taylor series expansion algorithm for decimal exponent.

import math

QUINT = 10**18  # One quintillion

##### EXP FUNCTIONS #####

#Exponentiation-by-squaring algorithm.
# base and output are integer representations of 2DP decimals.
# Exponent n is integer.
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

# exp(x), using Taylor series expansion to 18 DP.
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
