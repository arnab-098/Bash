#!/bin/bash

if [ -z "$1" ]; then
  echo "Directory path(s) not provided"
  exit
fi

declare -a paths

idx=0
for path in "$@"; do
  if [ -d "$path" ]; then
    paths[$idx]="$path"
    idx=$(expr $idx + 1)
  else
    echo "$path does not exist"
  fi
done

for path in ${paths[@]}; do
  length=$(expr $(ls -la $path | wc -l) - 3)
  files=$(ls -la $path | tr -s " " | cut -d " " -f 9 | tail -n $length)

  filePath=""
  idx=0

  declare -a deletedFiles=()

  for file in $files; do
    if [[ $file =~ ^[^.]*[^\..*]$ || "$file" == "a.out" ]]; then
      if [ -f "$path$file" ]; then
        filePath="$path$file"
      else
        filePath="$path/$file"
      fi
      rm "$filePath" &>/dev/null
      deletedFiles[$idx]="$filePath"
      idx=$(expr $idx + 1)
    fi
  done

  if [ ${#deletedFiles[@]} -eq 0 ]; then
    echo "No executable found in $path"
    continue
  fi

  length=$(expr $(ls -la $path | wc -l) - 3)
  files=$(ls -la $path | tr -s " " | cut -d " " -f 9 | tail -n $length)

  for file in ${deletedFiles[@]}; do
    if [ $(echo ${files[@]} | grep -c "$file") -eq 0 ]; then
      echo "Deleted file $file"
    else
      echo "Failed to delete file $file"
    fi
  done
done
