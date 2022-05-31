-- Step 1 定义一个视图，包括定单的编号、时间、金额以及收货人的姓名、国家代码和国家名称

create view vTest
as
select cOrderNo, dOrderDate, mTOtalCost, vFirstName + ' ' + vLastName as vName, Shopper.cCountryId, cCountry
from Orders
join Shopper
on Shopper.cShopperId = Orders.cShopperId
join Country
on Country.cCountryId = Shopper.cCountryId

-- Step 2 基于（1）中定义的视图，查询所有国家代码为‘001’的收货人的姓名和他们所下定单的笔数及定单的总金额

select vName, count(mTotalCost) as 订单数, sum(mTotalCost) as 总金额
from vTest
where cCountryId = '001'
group by vName

-- Step 3 创建指定视图后执行更新命令，并分析命令的执行结果

create view vwOrderWrapper
as
select cOrderNo, cToyId, siQty, vDescription, mWrapperRate
from OrderDetail
join Wrapper
on OrderDetail.cWrapperId = Wrapper.cWrapperId

update vwOrderWrapper
set siQty = 2, mWrapperRate = mWrapperRate + 1
where cOrderNo = '000001'

-- 报错提示：视图或函数 'vwOrderWrapper' 不可更新，因为修改会影响多个基表。

-- 官方文档指出视图修改基表数据需要满足几个条件：
-- 1. 任何修改（包括 UPDATE、INSERT 和 DELETE 语句）都只能引用一个基表的列。
-- 2. 视图中被修改的列必须直接引用表列中的基础数据，不能通过聚合函数、计算等方式对列进行派生。
-- 3. 被修改的列不受 GROUP BY、HAVING 或 DISTINCT 子句的影响。
-- 4. TOP 在视图的 select_statement 中的任何位置都不会与 WITH CHECK OPTION 子句一起使用。

-- 解决方案：
-- 1. 每次只针对一个表的列分次更新

update vwOrderWrapper
set siQty = 2
where cOrderNo = '000001'

update vwOrderWrapper
set mWrapperRate = mWrapperRate + 1
where cOrderNo = '000001'

-- 2. INSTEAD OF 触发器

create trigger trigger_vwOrderWrapper_update
on vwOrderWrapper instead of update
as
begin
	if update(cOrderNo)
	begin
		update OrderDetail
		set OrderDetail.cOrderNo = inserted.cOrderNo 
		from OrderDetail, inserted, deleted
		where OrderDetail.cOrderNo = deleted.cOrderNo
	end

	if update(cToyId)
	begin
		update OrderDetail
		set OrderDetail.cToyId = inserted.cToyId
		from OrderDetail, inserted
		where OrderDetail.cOrderNo = inserted.cOrderNo
	end

	if update(siQty)
	begin
		update OrderDetail
		set OrderDetail.siQty = inserted.siQty
		from OrderDetail, inserted
		where OrderDetail.cOrderNo = inserted.cOrderNo
	end

	if update(vDescription)
	begin
		update Wrapper
		set Wrapper.vDescription = inserted.vDescription
		from OrderDetail, inserted
		where OrderDetail.cOrderNo = inserted.cOrderNo
	end

	if update(mWrapperRate)
	begin
		update Wrapper
		set Wrapper.mWrapperRate = inserted.mWrapperRate
		from OrderDetail, inserted
		where OrderDetail.cOrderNo = inserted.cOrderNo
	end
end

go

create trigger trigger_vwOrderWrapper_insert
on vwOrderWrapper instead of insert
as
begin
	insert OrderDetail(cOrderNo, cToyId, siQty)
	select cOrderNo, cToyId, siQty from inserted

	insert Wrapper(vDescription, mWrapperRate)
	select vDescription, mWrapperRate from inserted
end

go

create trigger trigger_vwOrderWrapper_delete
on vwOrderWrapper instead of delete
as
begin
	delete OrderDetail
	from OrderDetail, deleted
	where OrderDetail.cOrderNo = deleted.cOrderNo

	delete Wrapper
	from OrderDetail, deleted
	where OrderDetail.cOrderNo = deleted.cOrderNo
end

-- 3. 分区视图

-- 分区视图是通过对成员表使用 UNION ALL 所定义的视图，这些成员表的结构相同，但作为多个表分别存储。
-- 本题中 OrderDetail 和 Wrapper 表结构不同，分区视图不适用。

-- Step 4 在 GlobalToyz 数据库里创建一个用户，用户名为 user_xxxx（你的学号）。通过视图限制该用户只能访问 Orders 表中 2017 年以前的数据

create view vwOrders
as
select *
from Orders
where dOrderDate < '2017-01-01'

go

create login user_8208201030 with password='password', default_database=GlobalToyz

create user user_8208201030 for login user_8208201030 with default_schema = dbo

grant select on vwOrders to user_8208201030

-- Step 5 当购物者确认定单时，应该包含一些步骤，将这些步骤定义为一个事务。编写一个过程以购物车 ID 和购物者 ID 为参数，实现这个事务。（提示：首先需要修改表 ShoppingCart 的结构，在表中新增一个字段‘Status’。该字段取值为 1，表示该玩具为本次下订单时要购买的玩具，并产生一些模拟数据。）

alter table ShoppingCart add Status smallint

update ShoppingCart
set Status = 1
where cCartId in(
    select top 700 cCartId
    from ShoppingCart
    order by newid()
)

create procedure prcNewOrderNo(
    @cOrderNo char(6) output
)
as
begin
    select top 1 @cOrderNo = cOrderNo
    from Orders
    order by cOrderNo desc

    set @cOrderNo = right('000000' + convert(varchar,convert(int, @cOrderNo) + 1),6)
end

create procedure prcBuyBuyBuy(
    @cCartId char(6),
    @cShopperId char(6)
)
as
begin
    set nocount on
    set xact_abort on           -- automatically rollback

    begin transaction
        declare @cOrderNo as char(6), @Date_start as datetime, @Date_end as datetime, @dOrderDate as datetime, @cShippingModeId as char(2)
        declare @cCountryId as char(3), @iToyKinds as int, @siTotalToyWeight as smallint, @mTotalToyCharge as money, @mGiftWrapCharges as money, @cOrderProcessed as char(1)
        declare @cToyId as char(6), @mToyRate as money, @siToyWeight as smallint, @siToyQoh as smallint, @siQty as int, @WrapperFlag as int, @cGiftWrap as char(1), @mToyCost as money
        declare @cWrapperId as char(3), @mWrapperRate as money, @vMessage as varchar(256), @iMaxDelDays as int, @mShippingCharges as money, @mTotalCost as money, @dExpDelDate as datetime
        declare @randomDays as int, @dShipmentDate as datetime, @DeliveryFlag as int, @cDeliveryStatus as char(1), @iActualDelDays as int, @dActualDeliveryDate as datetime
        declare @vFirstName as varchar(20), @vLastName as varchar(20), @vAddress as varchar(20), @cCity as char(15), @cState as char(15), @cZipCode as char(10), @cPhone as char(15)
        declare @toyCount as int
        exec prcNewOrderNo @cOrderNo output
        set @dOrderDate = getdate()
        set @siTotalToyWeight = 0
        set @mTotalToyCharge = 0
        set @mGiftWrapCharges = 0
        set @cOrderProcessed = 'Y'

        select @cCountryId = cCountryId
        from Shopper
        where cShopperId = @cShopperId

        insert into Orders
        values(@cOrderNo, @dOrderDate, @cCartId, @cShopperId, null, null, null, null, null, null)

        select @toyCount = count(Status)
        from ShoppingCart
        where cCartId = @cCartId and Status = 1

        declare cursorShoppingCart cursor scroll
        for
        select cToyId, siQty
        from ShoppingCart
        where cCartId = @cCartId and Status = 1

        open cursorShoppingCart

        while @toyCount > 0
        begin
            set @toyCount = @toyCount - 1

            fetch cursorShoppingCart into @cToyId, @siQty

            select @mToyRate = mToyRate, @siToyWeight = siToyWeight, @siToyQoh = siToyQoh
            from Toys
            where cToyId = @cToyId

            set @mToyCost = @mToyRate * @siQty
            set @mTotalToyCharge = @mTotalToyCharge + @mToyCost
            set @siTotalToyWeight = @siTotalToyWeight + @siToyWeight

            set @WrapperFlag = convert(int, rand() * 5 + 1)
            if @WrapperFlag = 1
                begin

                set @cGiftWrap = 'N'
                set @cWrapperId = null
                set @vMessage = null

                end
            else
                begin

                set @cGiftWrap = 'Y'

                select @cWrapperId = cWrapperId, @mWrapperRate = mWrapperRate
                from Wrapper
                order by newid()

                select @vMessage = vMessage
                from OrderDetail
                where not vMessage is null
                order by newid()

                set @mGiftWrapCharges = @mGiftWrapCharges + @mWrapperRate * @siQty
            
            end

            insert into OrderDetail
            values(@cOrderNo, @cToyId, @siQty, @cGiftWrap, @cWrapperId, @vMessage, @mToyCost)

            set @siToyQoh = @siToyQoh - @siQty

            if @siToyQoh < 0
                set @cOrderProcessed = 'N'

            update Toys
            set siToyQoh = @siToyQoh
            where cToyId = @cToyId
        end

        close cursorShoppingCart
        deallocate cursorShoppingCart

        select @cShippingModeId = cModeId, @iMaxDelDays = iMaxDelDays
        from ShippingMode
        order by newid()

        select @mShippingCharges = mRatePerPound * @siTotalToyWeight
        from ShippingRate
        where cCountryId = @cCountryId and cModeId = @cShippingModeId

        set @mTotalCost = @mTotalToyCharge + @mShippingCharges + @mGiftWrapCharges

        if @cOrderProcessed = 'N'
            set @dExpDelDate = null
        else
            begin

            set @randomDays = convert(int, rand()*14+1)
            set @dShipmentDate = dateadd(day, @randomDays, @dOrderDate)
            set @dExpDelDate = dateadd(day, @iMaxDelDays, @dShipmentDate)

            set @DeliveryFlag = convert(int, rand()*5 + 1)
            if @DeliveryFlag = 1
                begin

                set @cDeliveryStatus = 's'
                set @dActualDeliveryDate = null

                end
            else
                begin

                set @cDeliveryStatus = 'd'
                set @iActualDelDays = convert(int, rand() * (@iMaxDelDays + 1))
                set @dActualDeliveryDate = dateadd(day, @iActualDelDays, @dShipmentDate)

                end

            insert into Shipment
            values(@cOrderNo, @dShipmentDate, @cDeliveryStatus, @dActualDeliveryDate)

            end
        
        select @vFirstName = vFirstName, @vLastName = vLastName, @vAddress = vAddress, @cCity = cCity, @cState = cState, @cCountryId = cCountryId, @cZipCode = cZipCode, @cPhone = cPhone
        from Recipient
        order by newid()

        insert into Recipient
        values(@cOrderNo, @vFirstName, @vLastName, @vAddress, @cCity, @cState, @cCountryId, @cZipCode, @cPhone)

        update Orders
        set cShippingModeId = @cShippingModeId, mShippingCharges = @mShippingCharges, mGiftWrapCharges = @mGiftWrapCharges, cOrderProcessed = @cOrderProcessed, mTotalCost = @mTotalCost, dExpDelDate = @dExpDelDate
        where cOrderNo = @cOrderNo

        delete from ShoppingCart
        where cCartId = @cCartId

    commit transaction    
        
    set nocount off
end

-- Step 6 编写一个程序显示每天的定单状态。如果当天的定单值总合大于 150，则显示 “High sales”,否则显示 ”Low sales”。要求列出日期、定单状态和定单总价值。（要求用游标实现）

declare cursorOrder cursor scroll
for
select mTotalCost
from Orders
where dOrderDate = convert(varchar(10),getdate(), 120)

go

open cursorOrder

go

declare @mTotalCost money, @mSumTodayCost money

set @mSumTodayCost = 0

fetch next from cursorOrder into @mTotalCost

while @@fetch_status = 0 and @mSumTodayCost <= 150
begin
    set @mSumTodayCost = @mSumTodayCost + @mTotalCost
    fetch next from cursorOrder into @mTotalCost
end

close cursorOrder

deallocate cursorOrder

select dOrderDate, cOrderProcessed, mTotalCost
from Orders
where dOrderDate = convert(varchar(10),getdate(), 120)

if @mSumTodayCost > 150
    print 'High sales'
else
    print 'Low sales'

-- Step 7 基于表 Orders 和 Shopper，生成指定格式报表

declare @cShopperId as char(6), @vFullName as varchar(50), @vAddress as varchar(40)
declare @cOrderNo as char(6), @dOrderDate as datetime, @mTotalCost as money

declare cursorShopper cursor scroll
for
select cShopperId, vFirstName + ' ' + vLastName as vFullName, vAddress
from Shopper

open cursorShopper

fetch next from cursorShopper into @cShopperId, @vFullName, @vAddress

while @@fetch_status = 0
begin
    print N'购物者ID: ' + @cShopperId + N'    购物者姓名: ' + @vFullName
    print N'购物者地址: ' + @vAddress 

    declare cursorOrder cursor scroll
    for
    select cOrderNo, dOrderDate, mTotalCost
    from Orders
    where cShopperId = @cShopperId

    open cursorOrder

    fetch next from cursorOrder into @cOrderNo, @dOrderDate, @mTotalCost

    while @@fetch_status = 0
    begin
        print N'订单号: ' + @cOrderNo + N'    订单时间: ' + convert(varchar(20), @dOrderDate) + N'    订单金额: ' + convert(char(20), @mTotalCost)
        fetch next from cursorOrder into @cOrderNo, @dOrderDate, @mTotalCost
    end

    close cursorOrder
    deallocate cursorOrder

    print N''

    fetch next from cursorShopper into @cShopperId, @vFullName, @vAddress

end

close cursorShopper
deallocate cursorShopper
