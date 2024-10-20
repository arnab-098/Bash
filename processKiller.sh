#!/bin/bash

if [ $# -eq 0 ]; then
  echo "Invalid Syntex"
  echo "Syntax: ./processKiller.sh <process name>"
  exit 1
fi

for process in "$@"; do
  pids=$(ps -eaf | tr -s " " | grep -iP "^([^ ]* ){7}$process$" | cut -d " " -f 2)

  if [ "$pids" == "" ]; then
    echo "No such process: $process"
  else
    kill $pids
    wait $pids 2>/dev/null
    if [ -z "$(ps -eaf | tr -s " " | grep -iP "^([^ ]* ){7}$process$")" ]; then
      echo "Killed process(s): $process"
    else
      echo "Failed to kill process: $process"
    fi
  fi
done
