# coding=utf-8

import logging
import sqlite3
import datetime

logger = logging.getLogger(__name__)


def create_database():
    # 1. 建立数据库连接
    connection = sqlite3.connect('VisualStock.db')
    # 2. 创建游标对象
    cursor = connection.cursor()

    # 3. 执行SQL操作
    sql = "create table if not exists Records(" \
          "Symbol varchar(10)   not null, " \
          "Date   date          not null," \
          "Open   decimal(8, 4) not null," \
          "Close  decimal(8, 4) not null," \
          "High   decimal(8, 4) not null," \
          "Low    decimal(8, 4) not null," \
          "primary key (Symbol, Date)" \
          ");"
    cursor.execute(sql)

    sql = "create table if not exists Stocks(" \
          "Symbol     varchar(10)," \
          "LastUpdate date not null" \
          ");"

    cursor.execute(sql)

    # 4. 提交数据库事物
    connection.commit()
    # 5. 关闭游标
    cursor.close()
    # 6. 关闭数据连接
    connection.close()


def insert_into_stocks(row):
    # 1. 建立数据库连接
    connection = sqlite3.connect('VisualStock.db')
    # 2. 创建游标对象
    cursor = connection.cursor()

    try:
        # 3. 执行SQL操作
        symbol, date = row['Symbol'], row['Date']
        sql = 'insert into stocks ' \
              'values (?, ?)'

        cursor.execute(sql, (symbol, date))

        # 4. 提交数据库事物
        connection.commit()

    except sqlite3.DatabaseError as error:
        # 4. 回滚数据库事物
        connection.rollback()
        logger.debug('插入数据失败', error)

    finally:
        # 5. 关闭游标
        cursor.close()
        # 6. 关闭数据连接
        connection.close()


def insert_into_records(row):
    # 1. 建立数据库连接
    connection = sqlite3.connect('VisualStock.db')
    # 2. 创建游标对象
    cursor = connection.cursor()

    try:
        # 3. 执行SQL操作
        v_tuple = row['Symbol'], row['Date'], row['Open'], row['Close'], row['High'], row['Low']
        sql = 'insert into records ' \
              'values (?, ?, ? ,? ,? ,?)'

        cursor.execute(sql, v_tuple)

        # 4. 提交数据库事物
        connection.commit()

    except sqlite3.DatabaseError as error:
        # 4. 回滚数据库事物
        connection.rollback()
        logger.debug('插入数据失败', error)

    finally:
        # 5. 关闭游标
        cursor.close()
        # 6. 关闭数据连接
        connection.close()


def select_from_stocks(stock):
    data = None

    # 1. 建立数据库连接
    connection = sqlite3.connect('VisualStock.db')
    # 2. 创建游标对象
    cursor = connection.cursor()

    try:
        # 3. 执行SQL操作
        sql = "select * " \
              "from stocks " \
              "where Symbol=? "
        cursor.execute(sql, (stock,))
        data = cursor.fetchone()

        # 4. 提交数据库事物
        connection.commit()

    except sqlite3.DatabaseError as error:
        # 4. 回滚数据库事物
        connection.rollback()
        logger.debug('读取数据失败', error)

    finally:
        # 5. 关闭游标
        cursor.close()
        # 6. 关闭数据连接
        connection.close()
        return data


def select_from_records(stock, days=30):
    results = []

    # 1. 建立数据库连接
    connection = sqlite3.connect('VisualStock.db')
    # 2. 创建游标对象
    cursor = connection.cursor()

    try:
        # 3. 执行SQL操作
        sql = "select * " \
              "from records " \
              "where Symbol=? " \
              "order by Date desc "
        cursor.execute(sql, (stock,))
        data = cursor.fetchall()
        for row in data:
            field = {'Date': datetime.datetime.strptime(row[1], "%Y-%m-%d").date(), 'Open': float(row[2]),
                     'Close': float(row[3]), 'High': float(row[4]),
                     'Low': float(row[5]), 'Symbol': stock}
            results.append(field)
            if len(results) == days:
                break

        # 4. 提交数据库事物
        connection.commit()

    except sqlite3.DatabaseError as error:
        # 4. 回滚数据库事物
        connection.rollback()
        logger.debug('读取数据失败', error)

    finally:
        # 5. 关闭游标
        cursor.close()
        # 6. 关闭数据连接
        connection.close()
        return results


def delete_from_stocks(stock):
    # 1. 建立数据库连接
    connection = sqlite3.connect('VisualStock.db')
    # 2. 创建游标对象
    cursor = connection.cursor()

    try:
        # 3. 执行SQL操作
        sql = 'delete from stocks ' \
              'where Symbol = ? '

        cursor.execute(sql, (stock,))

        # 4. 提交数据库事物
        connection.commit()

    except sqlite3.DatabaseError as error:
        # 4. 回滚数据库事物
        connection.rollback()
        logger.debug('删除数据失败', error)

    finally:
        # 5. 关闭游标
        cursor.close()
        # 6. 关闭数据连接
        connection.close()
