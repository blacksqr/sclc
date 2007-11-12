#!/bin/env python
#
# This is a sample Python file
# Note: Documentation strings are counted as source in SCLC-UH

class ExampleClass:
    """This is an example of a Python class"""

    def __init__(self,x):
        """This is the initializer function"""
        self.x = x

    def nop(self):
        """This function does nothing"""
        pass


def myfunc(x,y):
    z = x + y
    return x


# This will get executed if sample.py is run directly
if __name__=='__main__':
    c1 = ExampleClass(5)
    c2 = ExampleClass(6)
    x = myfunc(c1.x,c2.x)
    print "The value of x is %d" % x
