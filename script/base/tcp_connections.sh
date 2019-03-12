#!/bin/bash
#version 1.0
netstat -an | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a,S[a]}' | grep $1 |awk '{print $2}'

