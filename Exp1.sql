-- Step 1 用 SQL 语句创建数据库 CAP，数据文件名为 `CAPData.mdf` ，数据文件的初始存储空间大小为50M，最大存储空间为500M，存储空间自动增长量为10M

create database CAP
on
(
    name = CAP,
    filename = 'D:\OneDrive\Study\数据库\实验\CAPData.mdf',
    size = 50,
    maxsize = 500,
    filegrowth = 10
)

-- Step 2 在 CAP 数据库中用 SQL 语句创建 Customers、Products、Agents 和 Orders 4 张表，合理设计每个字段的数据类型，建立主键与外键约束。表 Products 中的 Price 字段不允许为空。表 Customers 的 discnt 字段取值范围在 [0,30] 之间。利用 SQL 语句向表中添加 `CAP.xls` 中的数据

use CAP
create table Customers
(
    "cid" char(4) constraint Custom_Prim primary key,
    "cname" varchar(10),
    "city" varchar(10),
    "discnt" numeric(4,2) constraint DISCNT_CHK check(discnt between 0 and 30)
)

create table Products
(
    "pid" char(3) constraint Product_Prim primary key,
    "pname" varchar(10),
    "city" varchar(10),
    "quantity" int,
    "price" numeric(10, 2) constraint Price_NotNull not null
)

create table Agents
(
    "aid" char(3) constraint Agent_Prim primary key,
    "aname" varchar(10),
    "city" varchar(10),
    "percent" tinyint
)

create table Orders
(
    "Ordno" char(4) constraint Order_Prim primary key,
    "month" char(3) constraint Month_CHK check(month in 
    ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec')),
    "cid" char(4) constraint Cid_Fore foreign key references Customers(cid),
    "aid" char(3) constraint Aid_Fore foreign key references Agents(aid),
    "pid" char(3) constraint Pid_Fore foreign key references Products(pid),
    "qty" int,
    "dollars" numeric(10,2)
)

insert into Customers (cid, cname, city, discnt)
values
	('C001', 'TipTop', 'Duluth', '10'),
	('C002', 'Basics', 'Dallas', '12'),
	('C003', 'Allied', 'Dallas', '8'),
	('C004', 'ACME', 'Duluth', '8'),
	('C005', 'Oriental', 'Kyoto', '6'),
	('C006', 'ACME', 'Kyoto', '0')

insert into Products (pid, pname, city, quantity, price)
values
	('P01', 'comb', 'Dallas', '111400', '0.5'),
	('P02', 'brush', 'Newark', '203000', '0.5'),
	('P03', 'razor', 'Duluth', '150600', '1'),
	('P04', 'Pen', 'Duluth', '125300', '1'),
	('P05', 'pencil', 'Dallas', '221400', '1'),
	('P06', 'folder', 'Dallas', '123100', '2'),
	('P07', 'case', 'Newark', '100500', '1')

insert into Agents (aid, aname, city, "percent")
values
	('A01', 'smith', 'New York', '6'),
	('A02', 'Jones', 'Newark', '6'),
	('A03', 'Brown', 'Tokyo', '7'),
	('A04', 'Gray', 'New York', '6'),
	('A05', 'Otasi', 'Duluth', '5'),
	('A06', 'Smith', 'Dallas', '5')

insert into Orders (Ordno, month, cid, aid, pid, qty, dollars)
values
	('1011', 'Jan', 'C001', 'A01', 'P01', '1000', '450'),
	('1012', 'Jan', 'C001', 'A01', 'P01', '1000', '450'),
	('1019', 'Feb', 'C001', 'A02', 'P02', '400', '180'),
	('1017', 'Feb', 'C001', 'A06', 'P03', '600', '540'),
	('1018', 'Feb', 'C001', 'A03', 'P04', '600', '540'),
	('1023', 'Mar', 'C001', 'A04', 'P05', '500', '450'),
	('1022', 'Mar', 'C001', 'A05', 'P06', '400', '720'),
	('1025', 'Apr', 'C001', 'A05', 'P07', '800', '720'),
	('1013', 'Jan', 'C002', 'A03', 'P03', '1000', '880'),
	('1026', 'May', 'C002', 'A05', 'P03', '800', '704'),
	('1015', 'Jan', 'C003', 'A03', 'P05', '1200', '1104'),
	('1014', 'Jan', 'C003', 'A03', 'P05', '1200', '1104'),
	('1021', 'Feb', 'C004', 'A06', 'P01', '1000', '460'),
	('1016', 'Jan', 'C004', 'A01', 'P01', '1000', '500'),
	('1020', 'Feb', 'C005', 'A03', 'P07', '600', '600'),
	('1024', 'Mar', 'C006', 'A06', 'P01', '800', '400')

-- Step 3 利用系统预定义的存储过程 `sp_helpdb` 查看数据库的相关信息，例如所有者、大小、创建日期等

exec sp_helpdb

-- Step 4 利用系统预定义的存储过程 `sp_helpconstraint` 查看表中出现的约束（包括 Primary key、Foreign key、check constraint、default、unique）

exec sp_helpconstraint Orders

-- Step 5 创建一张表 Orders_Jan，表的结构与 Orders 相同，将 Orders 表中 month 为 ‘Jan’ 的订单记录复制到表 Orders_Jan 中

create table Orders_Jun
(
    "Ordno" char(4) constraint Order_Jan_Prim primary key,
    "month" char(3) constraint Month_Jan_CHK check(month in 
    ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec')),
    "cid" char(4) constraint Cid_Fore foreign key references Customers(cid),
    "aid" char(3) constraint Aid_Fore foreign key references Agents(aid),
    "pid" char(3) constraint Pid_Fore foreign key references Products(pid),
    "qty" int,
    "dollars" numeric(10,2)
)

insert into Orders_Jun
select *
from Orders
where month = 'Jan'

-- Step 6 将 Orders 表中 month 为 ‘Jan’ 的订单记录全部删掉

delete
from Orders
where month = 'Jan'

-- Step 7 对曾经下过金额（dollars）大于 500 的订单的客户，将其 discnt 值增加 2 个百分点（+2）

update Customers
set discnt = discnt + 2
where cid in (
    select distinct cid
    from Orders
    where dollars > 500
)

-- Step 8 写一段 TSQL 程序，向表 Orders 中增加 5000 条记录，要求订单尽可能均匀地分布在 12 个月中

use CAP
declare @i as int, @randomNum as int, @price as numeric(10,2), @Ordno as char(4), @month as char(3), @cid as char(4), @aid as char(3), @pid as char(3), @qty as int, @dollars as numeric(10,2)
set @i = 1
set @Ordno = 2000
while @i <= 5000
    begin
        set @randomNum = convert(int, rand()*12 + 1)
        set @month =
        case @randomNum
            when 1 then 'Jan'
            when 2 then 'Feb'
            when 3 then 'Mar'
            when 4 then 'Apr'
            when 5 then 'May'
            when 6 then 'Jun'
            when 7 then 'Jul'
            when 8 then 'Aug'
            when 9 then 'Sep'
            when 10 then 'Oct'
            when 11 then 'Nov'
            when 12 then 'Dec'
            else 'Err'
        end
    
    select @cid = cid
    from Customers
    order by newid()

    select @aid = aid
    from Agents
    order by newid()

    select @pid = pid, @price = price
    from Products
    order by newid()

    set @qty = convert(int, rand() * 801 + 400)
    set @dollars = @price * @qty

    insert into Orders
    values(convert(char(4), @Ordno), @month, @cid, @aid, @pid, @qty, @dollars)

    set @Ordno = @Ordno + 1
    set @i = @i + 1

    end


-- Step 9 在表 Orders 的 month 字段上建立索引

create index Orders_Index
on Orders(month)

-- Step 10 创建一个视图 order_month_summary，视图中的字段包括月份、该月的订单总量和该月的订单总金额。基于视图 order_month_summary，查询第一季度各个月份的订单总量和订单总金额

create view order_month_summary(month, total_qty, total_dollars)
as 
select month, sum(qty), sum(dollars)
from Orders
group by month

select month, total_qty, total_dollars
from order_month_summary
where month in ('Jan', 'Feb', 'Mar')
