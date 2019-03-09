# Python script for testing  round-off error produced by the algorithm implentations  in DeciMath contract.

# Why? Round-off error accumulates with successive multiplication. This script gives us insight into how error varies with base and exponent.

# The script compares algorithm implementations to python's native exponential functions.
#
# Results are ballpark, as python's native exponentiation is itself approximate and imprecise.
#
# Algorithms tested:
# -Exponentiation by Squaring - b^n,  for decimal base 'b' and natural exponent 'n'
# -Taylor series expansion of e^n

import math

QUINT = 10**18  # One quintillion

# Decimal multiplication funcs. 2DP and 18DP
def decMul2(a, b):
    prod_ab = a*b
    decProduct =  (prod_ab + 50 ) / 100
    return decProduct

def decMul18(a, b):
    prod_ab = a*b
    decProduct =  (prod_ab + (QUINT / 2) ) / QUINT
    return decProduct

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

    return sum

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
