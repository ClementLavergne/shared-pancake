#!/bin/bash
if [ $# -eq 0 ]
  then
    echo "Generating example!"
    project="$PWD/example"
    out="$project/generated"
    source_folder="$project/source"
else
  project="$1"
  out="$2"

  if [ -z "$3" ]
    then
      source_folder="$project"
  else
      source_folder="$project/$3"
  fi
fi

for yaml in $source_folder/*yml; do
    yaml=${yaml#"$project/"}
    echo "### Processing of '$yaml'"
    make PRJ_PATH=$project SRC_FILE=$yaml OUT_PATH=$out &
done
wait