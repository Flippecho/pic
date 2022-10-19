#include <iostream>
#include <cmath>

#define PI acos(-1)

using namespace std;

class Shape {
protected:  // available for succession, unavailable for others
    double radius;

public:
    Shape(double r) {
        radius = r;
    }

    virtual double getArea() = 0;   // define the virtual function

    virtual double getPerimeter() = 0;
};

class Circle : public Shape {
public:
    Circle(double r) : Shape(r) {};     // you have to construct the class with parameters

    double getArea() {      // redefine the virtual function
        return PI * radius * radius;
    }

    double getPerimeter() {
        return 2 * PI * radius;
    }
};

class InnerSquare : public Shape {
public:
    InnerSquare(double r) : Shape(r) {};

    double getArea() {
        return radius * radius * 2;
    }

    double getPerimeter() {
        return 4 * radius * sqrt(2);
    }
};

class OuterSquare : public Shape {
public:
    OuterSquare(double r) : Shape(r) {};

    double getArea() {
        return radius * radius * 4;
    }

    double getPerimeter() {
        return 8 * radius;
    }
};

int main() {
    Shape* p;   // define a pointer to the class Shape
    Circle circle(3);   // construct a Circle object
    InnerSquare square1(3);
    OuterSquare square2(3);

    p = &circle;    // redirect the point to the Circle object
    cout << "Circle area: " << p->getArea() << "\tperimeter: " << p->getPerimeter() << endl;
    p = &square1;
    cout << "InnerSquare area: " << p->getArea() << "\tperimeter: " << p->getPerimeter() << endl;
    p = &square2;
    cout << "OuterSquare area: " << p->getArea() << "\tperimeter: " << p->getPerimeter() << endl;
}