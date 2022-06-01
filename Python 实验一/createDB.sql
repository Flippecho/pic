create table if not exists Records
(
    Symbol varchar(10)   not null,
    Date   date          not null,
    Open   decimal(8, 4) not null,
    Close  decimal(8, 4) not null,
    High   decimal(8, 4) not null,
    Low    decimal(8, 4) not null,
    primary key (Symbol, Date)
);

create table if not exists Stocks
(
    Symbol     varchar(10),
    LastUpdate date not null
);