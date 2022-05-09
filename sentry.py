#! /usr/bin/env python3

import sentry_sdk
sentry_sdk.init(
    "https://c63884114d9641b898b85b6764373069@o1147850.ingest.sentry.io/6219206",
    traces_sample_rate=1.0
)

if True == True:
    print("Да что же такое! Никогда ведь не было - и вот опять!")
    division_by_zero = 1 / 0
