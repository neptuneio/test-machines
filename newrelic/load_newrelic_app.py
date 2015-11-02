#!/usr/bin/env python

import time
import urllib2


def normal_call(count):
    print("Making 100 normal calls.")
    for number in range(count):
        try:
            urllib2.urlopen("http://localhost:3000")
        except:
            pass
        time.sleep(1)


def error_call(count):
    print("Generating 10 errors.")
    for number in range(count):
        try:
            urllib2.urlopen("http://localhost:3000/error")
        except:
            pass
        time.sleep(1)


def timeout_call(count):
    print("Making 10 timeouts.")
    for number in range(count):
        try:
            urllib2.urlopen("http://localhost:3000/5000")
        except:
            pass


if __name__ == "__main__":
    calls = 0
    timeouts = 0
    errors = 0

    while True:
        # First make 1000 normal calls.
        normal_call(1000)
        calls += 1000

        # Then create 100 errors
        error_call(100)
        errors += 100

        # Then create 100 timeouts so that NR generates alerts for this.
        timeout_call(100)
        timeouts += 100

        print("calls: ", calls, ", errors: ", errors, ", timeouts: ", timeouts)
