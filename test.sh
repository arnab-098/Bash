#!/bin/bash

arr=("a" "abc" "wxyz hello")

for i in "${!arr[@]}"; do
  if [ $i -gt 0 ]; then
    echo "${arr[$i]}"
  fi
done
