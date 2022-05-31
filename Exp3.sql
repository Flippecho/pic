-- Step 1 创建一个名为 prcCharges 的存储过程，它返回某个定单号的装运费用和包装费用

create procedure prcCharges(
    @cOrderNo char(6),
    @mShippingCharges money output,
    @mGiftWrapCharges money output
)
as
begin
    select @mShippingCharges = mShippingCharges, @mGiftWrapCharges = mGiftWrapCharges
    from Orders
    where cOrderNo = @cOrderNo
end

declare @mShippingCharges money, @mGiftWrapCharges money
exec prcCharges '000001', @mShippingCharges output, @mGiftWrapCharges output
select @mShippingCharges as mShippingCharges, @mGiftWrapCharges as mGiftWrapCharges

-- Step 2 创建一个名为 prcHandlingCharges 的过程，它接收定单号并显示经营费用。PrchandlingCharges 过程应使用 prcCharges 过程来得到装运费和礼品包装费。提示：经营费用=装运费+礼品包装费

create procedure prcHandlingCharges(
    @cOrderNo char(6),
    @mOperatingCost money output
)
as
begin
    declare @mShippingCharges money, @mGiftWrapCharges money
    exec prcCharges '000001', @mShippingCharges output, @mGiftWrapCharges output
    set @mOperatingCost = @mShippingCharges + @mGiftWrapCharges
end

declare @mOperatingCost money
exec prcHandlingCharges '000001', @mOperatingCost output
select @mOperatingCost as mOperatingCost

-- Step 3 在 OrderDetail 上定义一个触发器，当向 OrderDetail 表中新增一条记录时，自动修改 Toys 表中玩具的库存数量（siToyQoh）

create trigger trigger_OrderDetail_insert
on OrderDetail
    after insert
as
begin
    declare @cToyId char(6), @siQty smallint
    select @cToyId = cToyId, @siQty = siQty
    from inserted
    update Toys
    set siToyQoh = siToyQoh - @siQty
    where cToyId = @cToyId
end

-- Step 4 Orders 表是 GlobalToyz 数据库里的一张核心的表，对这张表上做的任何更新动作（增、删、改）都需要记录下来，这是数据库审计（Audit）的基本思想。要求设计一张表存储对 Orders 表的更新操作，包括操作者、操作时间、操作类型、更新前的数据、更新后的数据。设计触发器实现对 Orders 表的审计。

create table OrdersAudit {
    Operator sysname default SUSER_SNAME(),
    OperatingTime datetime default getdate(),
    OperatingType char(6),
    cOrderNo_old 	char(6) default null,
	dOrderDate_old 	datetime default null,
	cCartId_old		char(6) default null, 
	cShopperId_old	char(6) default null,
	cShippingModeId_old	char(2) default null,
	mShippingCharges_old money default null,
	mGiftWrapCharges_old	money default null,
	cOrderProcessed_old	char default null,
	mTotalCost_old	money default null,
	dExpDelDate_old	DateTime default null,
    cOrderNo_new 	char(6) default null,
	dOrderDate_new 	datetime default null,
	cCartId_new		char(6) default null,
	cShopperId_new	char(6) default null,
	cShippingModeId_new	char(2) default null,
	mShippingCharges_new money default null,
	mGiftWrapCharges_new	money default null,
	cOrderProcessed_new	char default null,
	mTotalCost_new	money default null,
	dExpDelDate_new	DateTime default null,
    primary key(OperatingTime, Operator, OperatingType)
}

create trigger trigger_Orders_insert
on Orders
    after insert
as
begin
    insert into OrdersAudit(OperatingType, cOrderNo_new, dOrderDate_new, cCartId_new, cShopperId_new, cShippingModeId_new, mShippingCharges_new, mGiftWrapCharges_new, cOrderProcessed_new, mTotalCost_new, dExpDelDate_new)
    select 'insert' as OperatingType, inserted.*
    from inserted
end

insert into Orders
values('001011', getdate(), '000001', '000002', null, null, null, null, null, null)

create trigger trigger_Orders_delete
on Orders
    after delete
as
begin
    insert into OrdersAudit(OperatingType, cOrderNo_old, dOrderDate_old, cCartId_old, cShopperId_old, cShippingModeId_old, mShippingCharges_old, mGiftWrapCharges_old, cOrderProcessed_old, mTotalCost_old, dExpDelDate_old)
    select 'delete' as OperatingType, deleted.*
    from deleted
end

delete from Orders
where cOrderNo = '001011'

create trigger trigger_Orders_update
on Orders
    after update
as
begin
    insert into OrdersAudit
    select SUSER_SNAME() as Operator, getdate() as OperatingTime, 'update' as OperatingType, deleted.*, inserted.*
    from inserted
    join deleted
    on 1 = 1
end

update Orders
set cOrderNo = '110100'
where cOrderNo = '001011'

-- Step 5 编写代码，分析玩具和地域的关系，例如哪个城市的购买者对哪一种、哪一类或哪一个品牌的玩具更有兴趣。这道题是个开放的题目，同学们可以按照自己的理解从不同的角度进行分析。实验报告中需给出代码、结果截图和对分析结果的文字描述

-- 编写代码，分析玩具和地域的关系，例如哪个城市的购买者对哪一种、哪一类或哪一个品牌的玩具更有兴趣。
-- 这道题是个开放的题目，同学们可以按照自己的理解从不同的角度进行分析。
-- 实验报告中需给出代码、结果截图和对分析结果的文字描述。



create procedure prcAreaInterest(
	@cInterest varchar(8),
	@siMode varchar(5)
)
as
begin
	if @cInterest = 'toy' and @siMode = 'both'
	begin
		select COALESCE(vToyName, 'All') as vToyName, COALESCE(cState, 'Toy') as cState, COALESCE(cCity,'Total') as cCity, sum(siQty) as Qty
		from Toys
		join OrderDetail
		on OrderDetail.cToyId = Toys.cToyId
		join Orders
		on Orders.cOrderNo = OrderDetail.cOrderNo
		join Shopper
		on Shopper.cShopperId = Orders.cShopperId
		group by vToyName, cState, cCity
		with rollup
	end
	else if @cInterest = 'toy' and @siMode = 'city'
	begin
		select cCity, vToyName, sum(siQty) as Qty
		from Toys
		join OrderDetail
		on OrderDetail.cToyId = Toys.cToyId
		join Orders
		on Orders.cOrderNo = OrderDetail.cOrderNo
		join Shopper
		on Shopper.cShopperId = Orders.cShopperId
		group by vToyName, cCity
		order by cCity, Qty desc
	end
	else if @cInterest = 'toy' and @siMode = 'state'
	begin
		select cState, vToyName, sum(siQty) as Qty
		from Toys
		join OrderDetail
		on OrderDetail.cToyId = Toys.cToyId
		join Orders
		on Orders.cOrderNo = OrderDetail.cOrderNo
		join Shopper
		on Shopper.cShopperId = Orders.cShopperId
		group by vToyName, cState
		order by cState, Qty desc
	end
	else if @cInterest = 'brand' and @siMode = 'both'
	begin
		select COALESCE(cBrandName, 'All') as cBrandName, COALESCE(cState, 'Brand') as cState, COALESCE(cCity,'Total') as cCity, sum(siQty) as Qty
		from Toys
		join ToyBrand
		on ToyBrand.cBrandId = Toys.cBrandId
		join OrderDetail
		on OrderDetail.cToyId = Toys.cToyId
		join Orders
		on Orders.cOrderNo = OrderDetail.cOrderNo
		join Shopper
		on Shopper.cShopperId = Orders.cShopperId
		group by cBrandName, cState, cCity
		with rollup
	end
	else if @cInterest = 'brand' and @siMode = 'city'
	begin
		select cCity, cBrandName, sum(siQty) as Qty
		from Toys
		join ToyBrand
		on ToyBrand.cBrandId = Toys.cBrandId
		join OrderDetail
		on OrderDetail.cToyId = Toys.cToyId
		join Orders
		on Orders.cOrderNo = OrderDetail.cOrderNo
		join Shopper
		on Shopper.cShopperId = Orders.cShopperId
		group by cBrandName, cCity
		order by cCity, Qty desc
	end
	else if @cInterest = 'brand' and @siMode = 'state'
	begin
		select cState, cBrandName, sum(siQty) as Qty
		from Toys
		join ToyBrand
		on ToyBrand.cBrandId = Toys.cBrandId
		join OrderDetail
		on OrderDetail.cToyId = Toys.cToyId
		join Orders
		on Orders.cOrderNo = OrderDetail.cOrderNo
		join Shopper
		on Shopper.cShopperId = Orders.cShopperId
		group by cBrandName, cState
		order by cState, Qty desc
	end
	else if @cInterest = 'category' and @siMode = 'both'
	begin
		select COALESCE(cCategory, 'All') as cCategory, COALESCE(cState, 'Category') as cState, COALESCE(cCity,'Total') as cCity, sum(siQty) as Qty
		from Toys
		join Category
		on Category.cCategoryId = Toys.cCategoryId
		join OrderDetail
		on OrderDetail.cToyId = Toys.cToyId
		join Orders
		on Orders.cOrderNo = OrderDetail.cOrderNo
		join Shopper
		on Shopper.cShopperId = Orders.cShopperId
		group by cCategory, cState, cCity
		with rollup
	end
	else if @cInterest = 'category' and @siMode = 'city'
	begin
		select cCity, cCategory, sum(siQty) as Qty
		from Toys
		join Category
		on Category.cCategoryId = Toys.cCategoryId
		join OrderDetail
		on OrderDetail.cToyId = Toys.cToyId
		join Orders
		on Orders.cOrderNo = OrderDetail.cOrderNo
		join Shopper
		on Shopper.cShopperId = Orders.cShopperId
		group by cCategory, cCity
		order by cCity, Qty desc
	end
	else if @cInterest = 'category' and @siMode = 'state'
	begin
		select cState, cCategory, sum(siQty) as Qty
		from Toys
		join Category
		on Category.cCategoryId = Toys.cCategoryId
		join OrderDetail
		on OrderDetail.cToyId = Toys.cToyId
		join Orders
		on Orders.cOrderNo = OrderDetail.cOrderNo
		join Shopper
		on Shopper.cShopperId = Orders.cShopperId
		group by cCategory, cState
		order by cState, Qty desc
	end
end

exec prcAreaInterest 'toy', 'both'
