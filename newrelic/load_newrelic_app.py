#!/usr/bin/env python

import time
import urllib2
import random


def normal_call():
    for number in range(100):
        urllib2.urlopen("http://localhost:3000")
        time.sleep(5)


def error_call():
    for number in range(10):
        try:
            urllib2.urlopen("http://localhost:3000/error")
        except:
            pass
        time.sleep(5)


def timeout_call():
    for number in range(10):
        urllib2.urlopen("http://localhost:3000/5000")
        time.sleep(1)


if __name__ == "__main__":
    calls = 0
    timeouts = 0
    errors = 0

    while True:
        i = random.randint(1, 3)
        if i == 1:
            error_call()
            errors += 10
        elif i == 2:
            timeout_call()
            timeouts += 10
        else:
            normal_call()
            calls += 100

        print("calls: ", calls, ", errors: ", errors, ", timeouts: ", timeouts)
