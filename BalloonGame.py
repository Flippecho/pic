usedBalloon = dict()


def isValid(divided):
    if divided <= 0:  # 假话
        return False
    for i in range(100, 0, -1):
        if i == 1:  # 假话
            return False
        elif divided <= i and divided not in usedBalloon.keys():  # 被除数小于等于除数，真话（若气球还在）
            usedBalloon[divided] = True
            return True
        elif divided % i == 0 and i not in usedBalloon.keys():  # 被除数可被整除时踩气球（若气球还在）
            divided = divided / i
            usedBalloon[i] = True


while True:
    usedBalloon = dict()
    data = input('请输入两个数字并以一个空格隔开: ')
    if data == '0 0':
        break
    (x, y) = data.split(' ')
    (x, y) = (int(x), int(y))
    if x > y:
        (x, y) = (y, x)

    if isValid(x) and not isValid(y):
        print(x)
    else:
        print(y)
