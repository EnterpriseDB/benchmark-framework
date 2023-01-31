#!/bin/sh

usage () {
  echo "Usage: $0 dbt2|pgbench|tprocc|tproch [<number of runs (default: 6)>] [<first run number (default 1)>]"
  echo
  echo "Run a benchmark of the specified type, optionally specifying the number of runs and the first run number."
  exit 1
}

if [ $# -lt 1 ]; then
  usage
fi

if [ $1 != "dbt2" -a $1 != "pgbench" -a $1 != "tprocc" -a $1 != "tproch" ]; then
  usage
fi

BENCHMARK=$1
NUM_RUNS=${2:-6}
FIRST_RUN=${3:-1}
LAST_RUN=$((${NUM_RUNS} + ${FIRST_RUN} - 1))

for RUN in $(seq ${FIRST_RUN} ${LAST_RUN})
do
  echo "Executing ${BENCHMARK} run ${RUN}"
  ansible-playbook -i inventory.yml --extra-vars "RUN_NUM=${RUN}" playbooks/scratch-run-${BENCHMARK}.yml
  RESULT=$?

  if [[ ${RESULT} > 0 ]]; then
    echo "Series run ${RUN}} returned non-zero exit status: ${RESULT}"
    echo "Check the ansible log and benchmark log for more info."
    exit ${RESULT}
  fi
done
