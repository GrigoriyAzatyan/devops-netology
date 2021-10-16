#! /usr/bin/env python3
import json

with open('file.json', 'r') as file:
   result = json.load(file)
   print(result.items())
