from datetime import datetime
from random import randint
from math import sqrt


def isDivisor(n, d, s, a):
    x = pow(a, d, n)
    if x == 1 or x == n - 1:
        return False
    for j in range(s):
        x = pow(x, 2, n)
        if x == 1:
            return True
        if x == n - 1:
            return False
    return True


def MillerRabinTest(n, trials=10):
    if n == 1:
        return False
    if n == 2:
        return True
    if n % 2 == 0:
        return False
    d, s = n - 1, 0
    while d % 2 == 0:
        d, s = d // 2, s + 1
    for j in range(trials):
        a = randint(2, n - 1)
        if isDivisor(n, d, s, a):
            return False
    return True


def sixPrime(n):
    if n == 1:
        return False
    if n in [2, 3]:
        return True
    if n % 6 not in [1, 5]:
        return False
    for j in range(5, int(sqrt(n)) + 1, 6):
        if 0 in [n % j, n % (j + 2)]:
            return False
    return True


while True:
    (minNumber, maxNumber) = input("\n请输入检测范围(用空格隔开): ").split(' ')

    (minNumber, maxNumber) = (int(minNumber), int(maxNumber))

    if minNumber < 0 or maxNumber <= 0 or maxNumber < minNumber:
        break

    count = 0
    time_start = datetime.now()
    for i in range(minNumber, maxNumber + 1):
        if MillerRabinTest(i):
            count += 1
    print(maxNumber, "以内的素数数量为:", count)
    time_end = datetime.now()
    time_cost = time_end - time_start
    print("素数测试算法耗时:", time_cost.seconds, "秒\n")

    count = 0
    time_start = datetime.now()
    for i in range(1, maxNumber + 1):
        if sixPrime(i):
            count += 1
    print(maxNumber, "以内的素数数量为:", count)
    time_end = datetime.now()
    time_cost = time_end - time_start
    print("模六算法耗时:", time_cost.seconds, "秒\n")
