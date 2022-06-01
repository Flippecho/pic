import sys
from PySide6 import QtWidgets
from MyMainWindow import MyMainWindow
from db_access import create_database

if __name__ == "__main__":
    create_database()

    app = QtWidgets.QApplication(sys.argv)

    window = MyMainWindow()
    window.show()

    sys.exit(app.exec())
