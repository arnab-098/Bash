#!/bin/bash

input_file="d.txt"
output_file="o.txt"

>$input_file
>$output_file

ls ~ -lah | tr -s " " >>$input_file
awk '{NR > 3 && $9 == "/\.*/"} {print $9}' $input_file >>$output_file

echo "DONE"
