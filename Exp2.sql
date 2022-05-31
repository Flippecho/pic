-- Step 1-1 运行给定的SQL Script，建立数据库 GlobalToyz

-- Step 1-2 创建数据库关系图，了解表的结构

-- Step 1-3 在 Orders 表中增加 1000 笔订单数据

declare @cOrderNo as int, @Date_start as datetime, @Date_end as datetime, @dOrderDate as datetime, @cCartId as char(6), @cShopperId as char(6), @cShippingModeId as char(2)
declare @cCountryId as char(3), @iToyKinds as int, @siTotalToyWeight as smallint, @mTotalToyCharge as money, @mGiftWrapCharges as money, @cOrderProcessed as char(1)
declare @cToyId as char(6), @mToyRate as money, @siToyWeight as smallint, @siToyQoh as smallint, @siQty as int, @WrapperFlag as int, @cGiftWrap as char(1), @mToyCost as money
declare @cWrapperId as char(3), @mWrapperRate as money, @vMessage as varchar(256), @iMaxDelDays as int, @mShippingCharges as money, @mTotalCost as money, @dExpDelDate as datetime
declare @randomDays as int, @dShipmentDate as datetime, @DeliveryFlag as int, @cDeliveryStatus as char(1), @iActualDelDays as int, @dActualDeliveryDate as datetime
declare @vFirstName as varchar(20), @vLastName as varchar(20), @vAddress as varchar(20), @cCity as char(15), @cState as char(15), @cZipCode as char(10), @cPhone as char(15)

update Toys
set siToyQoh = 200

set @cOrderNo = 11
while @cOrderNo <= 1010
    begin

    set @Date_start= '2016-01-01' 
    set @Date_end= '2017-12-31' 
    select @dOrderDate=dateadd(minute,abs(checksum(newid()))%(datediff(minute,@Date_start,@Date_end)+1),@Date_start)
    
    set @cCartId = right('000000' + convert(varchar,@cOrderNo),6)

    select @cShopperId = cShopperId, @cCountryId = cCountryId
    from Shopper
    order by newid()

    insert into Orders
    values(right('000000' + convert(varchar,@cOrderNo),6), @dOrderDate, @cCartId, @cShopperId, null, null, null, null, null, null)

    set @iToyKinds = convert(int, rand()*3 + 1)
    set @siTotalToyWeight = 0
    set @mTotalToyCharge = 0
    set @mGiftWrapCharges = 0
    set @cOrderProcessed = 'Y'

    while @iToyKinds > 0
        begin

        begin try

        select @cToyId = cToyId, @mToyRate = mToyRate, @siToyWeight = siToyWeight, @siToyQoh = siToyQoh
        from Toys
        order by newid()

        set @siQty = convert(int, rand()*4 + 1)

        set @siToyQoh = @siToyQoh - @siQty

        if @siToyQoh < 0
            set @cOrderProcessed = 'N'

        set @siTotalToyWeight = @siTotalToyWeight + @siToyWeight

        set @mToyCost = @mToyRate * @siQty

        set @mTotalToyCharge = @mTotalToyCharge + @mToyCost

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

        -- No need to insert into ShoppingCart since order is committed
        -- insert into ShoppingCart
        -- values(right('000000' + convert(varchar,@cCartId),6), @cToyId, @siQty)

        update Toys
        set siToyQoh = @siToyQoh
        where cToyId = @cToyId

        insert into OrderDetail
        values(right('000000' + convert(varchar,@cOrderNo), 6), @cToyId, @siQty, @cGiftWrap, @cWrapperId, @vMessage, @mToyCost)

        set @iToyKinds = @iToyKinds - 1

        end try

        begin catch

        set @iToyKinds = @iToyKinds + 1

        end catch

        end

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
        values(right('000000' + convert(varchar,@cOrderNo),6), @dShipmentDate, @cDeliveryStatus, @dActualDeliveryDate)

        end

    select @vFirstName = vFirstName, @vLastName = vLastName, @vAddress = vAddress, @cCity = cCity, @cState = cState, @cCountryId = cCountryId, @cZipCode = cZipCode, @cPhone = cPhone
    from Recipient
    order by newid()

    insert into Recipient
    values(right('000000' + convert(varchar,@cOrderNo),6), @vFirstName, @vLastName, @vAddress, @cCity, @cState, @cCountryId, @cZipCode, @cPhone)

    update Orders
    set cShippingModeId = @cShippingModeId, mShippingCharges = @mShippingCharges, mGiftWrapCharges = @mGiftWrapCharges, cOrderProcessed = @cOrderProcessed, mTotalCost = @mTotalCost, dExpDelDate = @dExpDelDate
    where cOrderNo = right('000000' + convert(varchar,@cOrderNo),6)

    set @cOrderNo = @cOrderNo + 1

    end

-- Step 1-4 更新 PickofMonth 表

drop PickofMonth

insert into PickOfMonth
select OrderDetail.cToyId, MONTH(Orders.dOrderDate) as siMonth, YEAR(Orders.dOrderDate) as iYear, sum(OrderDetail.siQty) as iTotalSold
from OrderDetail
join Orders
on OrderDetail.cOrderNo = Orders.cOrderNo
group by OrderDetail.cToyId, YEAR(Orders.dOrderDate), MONTH(Orders.dOrderDate)
order by OrderDetail.cToyId, YEAR(Orders.dOrderDate), MONTH(Orders.dOrderDate)

-- Step 2-1 查找属于 California 和 Florida 的顾客的名、姓和 emailID

select vFirstname, vLastName, vEmailId
from Shopper
where cState = 'California' or cState = 'Florida'

-- Step 2-2 查找定单号码、顾客ID，定单的总价值，并以定单的总价值的升序排列

select cOrderNo, cShopperId, mTotalCost
from Orders
order by mTotalCost

-- Step 2-3 查找在 orderDetail 表中 vMessage 为空值的行

select *
from OrderDetail
where vMessage is null

-- Step 2-4 查找玩具名字中有 “Racer” 字样的所有玩具的基本资料

select *
from Toys
where vToyName like '%Racer%'

-- Step 2-5 根据 2016 年的玩具销售总数，查找“Pick of the Month”玩具的前五名玩具的ID

select top 5 cToyId
from PickOfMonth
where iYear = '2016'
group by cToyId, iYear
order by sum(iTotalSold) desc

-- Step 2-6 根据 OrderDetail 表，查找玩具总价值大于 $50 的定单的号码和玩具总价值

select cOrderNo, mToyCost
from OrderDetail
where mToyCost > 50

-- Step 2-7 查找一份包含所有装运信息的报表，包括：Order Number, Shipment Date, Actual Delivery Date, Days in Transit. (提示：Days in Transit = Actual Delivery Date – Shipment Date) 

select cOrderNo as 'Order Number', dShipmentDate as 'Shipment Date', dActualDeliveryDate as 'Actual Delivery Date', DATEDIFF(d, dShipmentDate, dActualDeliveryDate) as 'Days in Transit'
from Shipment

-- Step 2-8 查找所有玩具的名称、商标和种类（Toy Name, Brand, Category）

select vToyName as 'Toy Name', cBrandName as Brand, cCategory as Category
from Toys
join ToyBrand
on ToyBrand.cBrandId = Toys.cBrandId
join Category
on Category.cCategoryId = Toys.cCategoryId

-- Step 2-9 查找玩具的名称和所有玩具的购物车ID。如果玩具不在购物车中，也需在结果中出现

select vToyName, cCartId
from Toys
join ShoppingCart
on Toys.cToyId = ShoppingCart.cToyId

-- Step 2-10 以下列格式查找所有购物者的名字和他们的简称：（Initials, vFirstName, vLastName）,例如 Angela Smith 的 Initials 为 A.S

select SUBSTRING(vFirstName,1, 1) + '.' + SUBSTRING(vLastName,1, 1) as Initials, vFirstName, vLastName
from Shopper

-- Step 2-11 查找所有玩具的平均价格，并舍入到整数

select convert(int, AVG(mToyRate)) as avarage
from Toys

-- Step 2-12 查找所有购买者和收货人的名、姓、地址和所在城市，要求保留结果中的重复记录

select vFirstName, vLastName, vAddress, cCity
from Shopper
union all
select vFirstName, vLastName, vAddress, cCity
from Recipient

-- Step 2-13 查找没有包装的所有玩具的名称。（要求用子查询实现）

select vToyName
from Toys
where cToyId in(
	select cToyId
	from OrderDetail
	where cGiftWrap = 'N')

-- Step 2-14 查找已收货定单的定单号码以及下定单的时间。（要求用子查询实现）

select cOrderNo, dOrderDate
from Orders
where cOrderNo in(
	select cOrderNo
	from Shipment
	where cDeliveryStatus = 'd')

-- Step 2-15 查找一份基于 Orderdetail 的报表，包括 cOrderNo, cToyId 和 mToyCost，记录以 cOrderNo 升序排列，并计算每一笔定单的玩具总价值

select COALESCE(cOrderNo, 'SUM OF') as cOrderNo, COALESCE(cToyId, 'OrderTotal') as cToyId, sum(mToyCost) as mOrderCost
from OrderDetail
group by cOrderNo, cToyId
with rollup
order by cOrderNo

-- Step 2-16 查找从来没有下过订单的顾客

select *
from Shopper
where not cShopperId in(
	select cShopperId
	from Orders)

-- Step 2-17 删除“Largo”牌的所有玩具

delete PickOfMonth
where cToyId in(	
	select cToyId
	from Toys
	where cBrandId in(
		select cBrandId
		from ToyBrand
		where cBrandName = 'Largo'))

delete OrderDetail
where cToyId in(	
	select cToyId
	from Toys
	where cBrandId in(
		select cBrandId
		from ToyBrand
		where cBrandName = 'Largo'))

delete ShoppingCart
where cToyId in(	
	select cToyId
	from Toys
	where cBrandId in(
		select cBrandId
		from ToyBrand
		where cBrandName = 'Largo'))

delete Toys
where cBrandId in(
	select cBrandId
	from ToyBrand
	where cBrandName = 'Largo')
