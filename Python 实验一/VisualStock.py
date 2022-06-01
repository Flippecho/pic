# coding=utf-8

import datetime

import matplotlib
import matplotlib.pyplot as plt
import pandas as pd
from PySide6.QtWidgets import QTableView
from bs4 import BeautifulSoup
from matplotlib.backends.backend_qtagg import FigureCanvasQTAgg
from selenium import webdriver
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.common.by import By
from selenium.webdriver.edge.options import Options
from selenium.webdriver.support import expected_conditions as ec
from selenium.webdriver.support.wait import WebDriverWait

from PandasModel import PandasModel
from db_access import insert_into_stocks, insert_into_records, select_from_stocks, \
    select_from_records, delete_from_stocks


def scrapyData(data, driver, stock):
    page = driver.page_source
    sp = BeautifulSoup(page, 'html.parser')
    tr_list = sp.select('.historical-data__row')
    for tr in tr_list:
        temp = []
        row = tr.select('.historical-data__cell')
        for cell in row:
            temp.append(cell.text.replace('$', ''))
        row = temp

        fields = {}
        try:
            df = '%m/%d/%Y'
            fields['Date'] = datetime.datetime.strptime(row[0], df).date()
        except ValueError:
            continue
        fields['Close'] = float(row[1])
        fields['Open'] = float(row[3])
        fields['High'] = float(row[4])
        fields['Low'] = float(row[5])
        fields['Symbol'] = stock
        if fields in data:
            continue
        data.append(fields)


def updateData(stock, days=30):
    tuple_stock = select_from_stocks(stock)
    if tuple_stock is not None and tuple_stock[1] == str(datetime.date.today()):
        # print("Reading data of %s from database..." % stock)
        data = select_from_records(stock, days)
    else:
        data = []
        # print("Scrapping data of %s from nasdaq..." % stock)
        url = 'https://www.nasdaq.com/market-activity/stocks/' + stock + '/historical'
        options = Options()
        options.headless = True
        options.add_argument('user-agent=The No.7 User Agent of Baluth')
        driver = webdriver.Edge(options=options, executable_path=r"D:\Folder\edgedriver\msedgedriver")

        try:
            driver.get(url)
            WebDriverWait(driver, 11).until(
                ec.presence_of_element_located((By.CSS_SELECTOR, '.alert--bad-symbol, .historical-data')))
        except TimeoutException:
            return 1
        except Exception:
            return 3

        if driver.current_url != url:
            return 2
        btn = driver.find_elements(By.CLASS_NAME, "table-tabs__tab")[5]
        driver.execute_script("arguments[0].click();", btn)

        scrapyData(data, driver, stock)
        while len(data) < days:
            btn = driver.find_elements(By.CLASS_NAME, "pagination__next")[0]
            driver.execute_script("arguments[0].click();", btn)

            try:
                WebDriverWait(driver, 3).until(
                    ec.presence_of_element_located((By.CLASS_NAME, 'pagination__next')))
            except TimeoutException:
                return 1
            except Exception:
                return 3

            scrapyData(data, driver, stock)
        data = data[0:days]
        driver.quit()

        writeToDB(data, stock)

    return data


def writeToDB(data, stock):
    for row in data:
        insert_into_records(row)
    delete_from_stocks(stock)
    insert_into_stocks({"Symbol": stock, "Date": datetime.date.today()})


def dataVisualization(data, index):
    temp = data.copy()
    temp.reverse()
    prices = pd.DataFrame(temp)
    prices = prices.drop(columns='Symbol')
    prices['Up/Down'] = round(prices['Close'] - prices['Open'], 4)
    # print(prices)

    matplotlib.use('QtAgg')
    fig_candlestick = plt.figure()
    fc_candlestick = FigureCanvasQTAgg(fig_candlestick)

    color_set = [{"up": "red", "down": "green"},
                 {"up": "green", "down": "red"},
                 {"up": "yellow", "down": "purple"}]

    color = color_set[index]

    width_thin = 0.1
    width_thick = 0.5

    up = prices[prices.Close > prices.Open]
    down = prices[prices.Close < prices.Open]
    flat = prices[prices.Close == prices.Open]

    plt.bar(up.Date, up.High - up.Close, width_thin, bottom=up.Close, color=color["up"])
    plt.bar(up.Date, up.Close - up.Open, width_thick, bottom=up.Open, color=color["up"])
    plt.bar(up.Date, up.Open - up.Low, width_thin, bottom=up.Low, color=color["up"])

    plt.bar(down.Date, down.High - down.Open, width_thin, bottom=down.Open, color=color["down"])
    plt.bar(down.Date, down.Open - down.Close, width_thick, bottom=down.Close, color=color["down"])
    plt.bar(down.Date, down.Close - down.Low, width_thin, bottom=down.Low, color=color["down"])

    plt.bar(flat.Date, flat.High - flat.Close, width_thin, bottom=flat.Close, color='black')
    plt.bar(flat.Date, 0, width_thick, bottom=flat.Close, color='black')
    plt.bar(flat.Date, flat.Close - flat.Low, width_thin, bottom=flat.Low, color='black')

    view_table = QTableView()
    view_table.horizontalHeader().setStretchLastSection(True)
    view_table.setAlternatingRowColors(True)
    view_table.setSelectionBehavior(QTableView.SelectRows)

    model = PandasModel(prices)
    view_table.setModel(model)

    return fc_candlestick, view_table


def main():
    stock = input("请输入 stock 代码: ")
    updateData(stock, 30)


if __name__ == '__main__':
    main()
