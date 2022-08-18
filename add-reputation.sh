#!/bin/bash

# usage ./add-reputation reputation.rules

sed -e 's/$/,1,10/' -i $1
