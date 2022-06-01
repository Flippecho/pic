# -*- coding: utf-8 -*-

################################################################################
## Form generated from reading UI file 'MainWindow.ui'
##
## Created by: Qt User Interface Compiler version 6.3.0
##
## WARNING! All changes made in this file will be lost when recompiling UI file!
################################################################################

from PySide6.QtCore import (QCoreApplication, QDate, QDateTime, QLocale,
    QMetaObject, QObject, QPoint, QRect,
    QSize, QTime, QUrl, Qt)
from PySide6.QtGui import (QBrush, QColor, QConicalGradient, QCursor,
    QFont, QFontDatabase, QGradient, QIcon,
    QImage, QKeySequence, QLinearGradient, QPainter,
    QPalette, QPixmap, QRadialGradient, QTransform)
from PySide6.QtWidgets import (QApplication, QComboBox, QLabel, QLineEdit,
    QMainWindow, QPushButton, QSizePolicy, QTabWidget,
    QWidget)

class Ui_MainWindow(object):
    def setupUi(self, MainWindow):
        if not MainWindow.objectName():
            MainWindow.setObjectName(u"MainWindow")
        MainWindow.resize(800, 600)
        sizePolicy = QSizePolicy(QSizePolicy.Ignored, QSizePolicy.Ignored)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(MainWindow.sizePolicy().hasHeightForWidth())
        MainWindow.setSizePolicy(sizePolicy)
        MainWindow.setMinimumSize(QSize(800, 600))
        MainWindow.setMaximumSize(QSize(800, 600))
        font = QFont()
        font.setFamilies([u"JetBrains Mono"])
        font.setPointSize(14)
        MainWindow.setFont(font)
        MainWindow.setStyleSheet(u"")
        MainWindow.setToolButtonStyle(Qt.ToolButtonIconOnly)
        MainWindow.setAnimated(True)
        MainWindow.setDocumentMode(False)
        MainWindow.setTabShape(QTabWidget.Rounded)
        MainWindow.setDockNestingEnabled(False)
        MainWindow.setUnifiedTitleAndToolBarOnMac(False)
        self.centralwidget = QWidget(MainWindow)
        self.centralwidget.setObjectName(u"centralwidget")
        sizePolicy.setHeightForWidth(self.centralwidget.sizePolicy().hasHeightForWidth())
        self.centralwidget.setSizePolicy(sizePolicy)
        self.TWStocks = QTabWidget(self.centralwidget)
        self.TWStocks.setObjectName(u"TWStocks")
        self.TWStocks.setGeometry(QRect(0, 0, 800, 520))
        self.TWStocks.setFont(font)
        self.Welcome = QWidget()
        self.Welcome.setObjectName(u"Welcome")
        self.LID = QLabel(self.Welcome)
        self.LID.setObjectName(u"LID")
        self.LID.setGeometry(QRect(420, 220, 180, 40))
        self.LWelcome = QLabel(self.Welcome)
        self.LWelcome.setObjectName(u"LWelcome")
        self.LWelcome.setGeometry(QRect(120, 100, 600, 60))
        font1 = QFont()
        font1.setFamilies([u"JetBrains Mono"])
        font1.setPointSize(36)
        self.LWelcome.setFont(font1)
        self.LAuthor = QLabel(self.Welcome)
        self.LAuthor.setObjectName(u"LAuthor")
        self.LAuthor.setGeometry(QRect(220, 220, 130, 40))
        self.LAuthor.setFont(font)
        self.TTip1 = QLabel(self.Welcome)
        self.TTip1.setObjectName(u"TTip1")
        self.TTip1.setGeometry(QRect(220, 280, 380, 40))
        self.TTip2 = QLabel(self.Welcome)
        self.TTip2.setObjectName(u"TTip2")
        self.TTip2.setGeometry(QRect(220, 340, 370, 40))
        self.TWStocks.addTab(self.Welcome, "")
        self.CBBColor = QComboBox(self.centralwidget)
        self.CBBColor.addItem("")
        self.CBBColor.addItem("")
        self.CBBColor.addItem("")
        self.CBBColor.setObjectName(u"CBBColor")
        self.CBBColor.setGeometry(QRect(180, 540, 150, 40))
        self.CBBColor.setFont(font)
        self.CBBColor.setContextMenuPolicy(Qt.DefaultContextMenu)
        self.CBBColor.setLayoutDirection(Qt.LeftToRight)
        self.CBBColor.setStyleSheet(u"padding-left: 32")
        self.CBBColor.setInputMethodHints(Qt.ImhNone)
        self.PBCommit = QPushButton(self.centralwidget)
        self.PBCommit.setObjectName(u"PBCommit")
        self.PBCommit.setGeometry(QRect(590, 540, 100, 40))
        self.PBCommit.setAutoDefault(False)
        self.PBCommit.setFlat(False)
        self.LStock = QLabel(self.centralwidget)
        self.LStock.setObjectName(u"LStock")
        self.LStock.setGeometry(QRect(400, 540, 70, 40))
        font2 = QFont()
        font2.setFamilies([u"JetBrains Mono"])
        font2.setPointSize(11)
        self.LStock.setFont(font2)
        self.LEStock = QLineEdit(self.centralwidget)
        self.LEStock.setObjectName(u"LEStock")
        self.LEStock.setGeometry(QRect(470, 540, 100, 40))
        self.LEStock.setStyleSheet(u"")
        self.LEStock.setFrame(True)
        self.LEStock.setAlignment(Qt.AlignCenter)
        self.LColor = QLabel(self.centralwidget)
        self.LColor.setObjectName(u"LColor")
        self.LColor.setGeometry(QRect(110, 540, 70, 40))
        self.LColor.setFont(font2)
        MainWindow.setCentralWidget(self.centralwidget)

        self.retranslateUi(MainWindow)

        self.TWStocks.setCurrentIndex(0)
        self.PBCommit.setDefault(False)


        QMetaObject.connectSlotsByName(MainWindow)
    # setupUi

    def retranslateUi(self, MainWindow):
        MainWindow.setWindowTitle(QCoreApplication.translate("MainWindow", u" Visual Stock", None))
        self.LID.setText(QCoreApplication.translate("MainWindow", u"\u5b66\u53f7\uff1a8208201030", None))
        self.LWelcome.setText(QCoreApplication.translate("MainWindow", u"\u6b22\u8fce\u4f7f\u7528 Visual Stock", None))
        self.LAuthor.setText(QCoreApplication.translate("MainWindow", u"\u4f5c\u8005\uff1a \u5f20\u5ca9\u5cf0", None))
        self.TTip1.setText(QCoreApplication.translate("MainWindow", u"\u7a0b\u5e8f\u4f7f\u7528 SQLite \u6570\u636e\u5e93\uff0c\u65e0\u9700\u5355\u72ec\u5b89\u88c5", None))
        self.TTip2.setText(QCoreApplication.translate("MainWindow", u"\u6570\u636e\u6765\u6e90\u4e3a Nasdaq\uff0c\u6bcf\u6b21\u67e5\u8be2 30 \u6761\u8bb0\u5f55", None))
        self.TWStocks.setTabText(self.TWStocks.indexOf(self.Welcome), QCoreApplication.translate("MainWindow", u"\u4f7f\u7528\u8bf4\u660e", None))
        self.CBBColor.setItemText(0, QCoreApplication.translate("MainWindow", u"\u7ea2\u6da8\u7eff\u8dcc", None))
        self.CBBColor.setItemText(1, QCoreApplication.translate("MainWindow", u"\u7eff\u6da8\u7ea2\u8dcc", None))
        self.CBBColor.setItemText(2, QCoreApplication.translate("MainWindow", u"\u9ec4\u6da8\u7d2b\u8dcc", None))

        self.PBCommit.setText(QCoreApplication.translate("MainWindow", u"\u67e5\u8be2", None))
        self.LStock.setText(QCoreApplication.translate("MainWindow", u"\u80a1\u7968\u4ee3\u7801", None))
        self.LEStock.setText(QCoreApplication.translate("MainWindow", u"msft", None))
        self.LColor.setText(QCoreApplication.translate("MainWindow", u"\u989c\u8272\u914d\u7f6e", None))
    # retranslateUi

