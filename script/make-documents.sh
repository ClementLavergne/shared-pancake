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

wait_all_tasks() {
  pids="$@"
  EXIT_CODE=0
  for job in "${pids[@]}"; do
      CODE=0;
      wait ${job} || CODE=$?
      if [[ "${CODE}" != "0" ]]; then
          echo "At least one operation failed with exit code ${CODE}" ;
          EXIT_CODE=1;
      fi
  done
}

background_tasks=()
for yaml in $source_folder/*yml; do
    yaml=${yaml#"$project/"}
    echo "### Processing of '$yaml'"
    make PRJ_PATH=$project SRC_FILE=$yaml OUT_PATH=$out & current_pid=$!
    background_tasks+=("$current_pid")
done

wait_all_tasks "${background_tasks[@]}"

exit "$EXIT_CODE"