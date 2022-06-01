import sys

from PySide6 import QtWidgets
from PySide6.QtCore import Slot, QThreadPool, QRect
from PySide6.QtGui import QIcon

from MainWindow import Ui_MainWindow
from VisualStock import updateData, dataVisualization
from Worker import Worker
from db_access import create_database


class MainWindow(QtWidgets.QMainWindow, Ui_MainWindow):
    data = None

    def __init__(self):
        super(MainWindow, self).__init__()
        self.setupUi(self)
        window_icon = QIcon()
        window_icon.addFile('icon.png')
        self.setWindowIcon(window_icon)

        self.threadpool = QThreadPool()
        # print("Multithreading with maximum %d threads\n" % self.threadpool.maxThreadCount())

        self.PBCommit.clicked.connect(self.PCCommitClicked)

    @Slot()
    def PCCommitClicked(self):
        self.PBCommit.setText("查询中")
        self.PBCommit.setDisabled(True)
        stock = self.LEStock.text()

        worker = Worker(self.fetch_data_thread, stock)
        worker.signals.finished.connect(self.fetch_data_finished)

        self.threadpool.start(worker)

    def fetch_data_thread(self, stock, progress_callback):
        self.data = updateData(stock)
        # print(self.data)
        # if self.data == 1:
        #     print("Error: network connection timeout.\n")
        # elif self.data == 2:
        #     print("Error: stock not found from nasdaq.\n")
        # elif self.data == 3:
        #     print("Unknown error.")
        # else:
        #     print("Data ready.")
        return "Done."

    def fetch_data_finished(self):
        if self.data == 1:
            label = QtWidgets.QLabel()
            label.setText("连接超时，请检查网络是否正常！")
            self.TWStocks.clear()
            self.TWStocks.addTab(label, "查询出错")
            label.setGeometry(QRect(260, 220, 280, 40))
        elif self.data == 2:
            label = QtWidgets.QLabel()
            label.setText("未查询到数据，请检查股票代码是否正确！")
            self.TWStocks.clear()
            self.TWStocks.addTab(label, "查询出错")
            label.setGeometry(QRect(220, 220, 360, 40))
        elif self.data == 3:
            label = QtWidgets.QLabel()
            label.setText("很抱歉，程序发生了未知错误！")
            self.TWStocks.clear()
            self.TWStocks.addTab(label, "查询出错")
            label.setGeometry(QRect(260, 220, 320, 40))
        else:
            # print("Visualizing data...")
            stock = self.LEStock.text()
            color_set_index = self.CBBColor.currentIndex()
            fc_candlestick, fc_table = dataVisualization(self.data, color_set_index)
            table_name = stock + "-数据表"
            candlestick_name = stock + "-K线图"
            self.TWStocks.clear()
            self.TWStocks.addTab(fc_candlestick, candlestick_name)
            self.TWStocks.addTab(fc_table, table_name)
            # print("Data visualization done.\n")
        self.PBCommit.setText("查询")
        self.PBCommit.setEnabled(True)


if __name__ == "__main__":
    create_database()

    app = QtWidgets.QApplication(sys.argv)

    window = MainWindow()
    window.show()

    sys.exit(app.exec())
