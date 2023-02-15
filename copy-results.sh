#!/bin/bash

if [ $# -ne 2 ]; then
  echo "Usage: $0 <source directory> <target directory>"
  echo
  echo "Copy benchmark results from the source directory to the target directory, organising them into the standard structure."
  exit 1
fi

copy_files () {
  for FILE in $1/$3-*; do
    if [[ ${FILE} =~ .*-run([0-9]+).* ]]; then
      TARGET_PATH="$2/$3 Run ${BASH_REMATCH[1]}"
      mkdir -p "${TARGET_PATH}"
      cp "${FILE}" "${TARGET_PATH}"
      echo ${FILE}
    fi
  done
}

copy_files "$1" "$2" dbt2
copy_files "$1" "$2" tprocc
copy_files "$1" "$2" tproch
copy_files "$1" "$2" pgbench