import xlrd

workbook = xlrd.open_workbook("D:\\OneDrive\\Study\\数据库\\实验\\CAP.xls")
Customers = workbook.sheet_by_index(0)
Products = workbook.sheet_by_index(1)
Agents = workbook.sheet_by_index(2)
Orders = workbook.sheet_by_index(3)

print("insert into Customers (cid, cname, city, discnt)")
print("values")

gap = "', '"

for i in range(1, 7):
    cid = Customers.cell_value(i, 0)
    cname = Customers.cell_value(i, 1)
    city = Customers.cell_value(i, 2)
    discnt = Customers.cell_value(i, 3)
    n = discnt
    n = str(n).rstrip('0')  # 删除小数点后多余的0
    n = int(n.rstrip('.')) if n.endswith('.') else float(n)  # 只剩小数点直接转int，否则转回float
    discnt = n
    if i == 6:
        print("\t('", cid, gap, cname, gap, city, gap, discnt, "')", sep='')
    else:
        print("\t('", cid, gap, cname, gap, city, gap, discnt, "'),", sep='')

print("\ninsert into Products (pid, pname, city, quantity, price)")
print("values")

for i in range(1, 8):
    pid = Products.cell_value(i, 0)
    pname = Products.cell_value(i, 1)
    city = Products.cell_value(i, 2)
    quantity = int(Products.cell_value(i, 3))
    price = Products.cell_value(i, 4)
    n = price
    n = str(n).rstrip('0')  # 删除小数点后多余的0
    n = int(n.rstrip('.')) if n.endswith('.') else float(n)  # 只剩小数点直接转int，否则转回float
    price = n
    if i == 7:
        print("\t('", pid, gap, pname, gap, city, gap, quantity, gap, price, "')", sep='')
    else:
        print("\t('", pid, gap, pname, gap, city, gap, quantity, gap, price, "'),", sep='')

print("\ninsert into Agents (aid, aname, city, percent)")
print("values")

for i in range(1, 7):
    aid = Agents.cell_value(i, 0)
    aname = Agents.cell_value(i, 1)
    city = Agents.cell_value(i, 2)
    percent = int(Agents.cell_value(i, 3))
    if i == 6:
        print("\t('", aid, gap, aname, gap, city, gap, percent, "')", sep='')
    else:
        print("\t('", aid, gap, aname, gap, city, gap, percent, "'),", sep='')

print("\ninsert into Orders (Ordno, month, cid, aid, pid, qty, dollars)")
print("values")

for i in range(1, 17):
    Ordno = int(Orders.cell_value(i, 0))
    month = Orders.cell_value(i, 1)
    cid = Orders.cell_value(i, 2)
    aid = Orders.cell_value(i, 3)
    pid = Orders.cell_value(i, 4)
    qty = int(Orders.cell_value(i, 5))
    dollars = Orders.cell_value(i, 6)
    n = dollars
    n = str(n).rstrip('0')  # 删除小数点后多余的0
    n = int(n.rstrip('.')) if n.endswith('.') else float(n)  # 只剩小数点直接转int，否则转回float
    dollars = n
    if i == 16:
        print("\t('", Ordno, gap, month, gap, cid, gap, aid, gap, pid, gap, qty, gap, dollars, "')", sep='')
    else:
        print("\t('", Ordno, gap, month, gap, cid, gap, aid, gap, pid, gap, qty, gap, dollars, "'),", sep='')
