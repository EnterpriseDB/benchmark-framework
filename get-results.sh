#!/bin/bash

usage () {
  echo "Usage: $0 pgbench|tprocc|tproch [text|table (default: text)] [<path to logs (default: .)>]"
  echo
  echo "Extract benchmark results for the specified test type, and output them in the specified format."
  exit 1
}

if [ $# -lt 1 ]; then
  usage
fi

BENCHMARK=$1
FORMAT=${2:-text}
DIRECTORY=${3:-.}

if [ ${FORMAT} != "text" -a ${FORMAT} != "table" ]; then
  usage
fi

pgbench_text () {
  for FILE in $1/pgbench-20*.log
  do
    grep "tps = " $FILE | awk -v file=$FILE '{print file,":",$3,"TPS"}'
  done
}

pgbench_table () {
  PREV_RUN=0

  for FILE in $1/pgbench-20*.log
  do
    HOST_NUM=$(echo $FILE | awk -F '-' '{ print $3 }' | sed 's/cto//g')
    RUN_NUM=$(echo $FILE | awk -F '-' '{ print $4 }' | sed 's/run//g')
    TPS=$(grep "tps = " $FILE | awk '{ print $3 }')

    if [ $PREV_RUN -ne $RUN_NUM ]; then
      PREV_RUN=$RUN_NUM
      echo ""
    else
      echo -n ","
    fi

    echo -n "$TPS"
  done

  echo ""
}

tprocc_text () {
  for FILE in $1/tprocc-20*.log
  do
    grep NOPM $FILE | awk -v file=$FILE '{print file,":",$7,"NOPM,",$10, "TPM"}'
  done
}

tprocc_table() {
  PREV_RUN=0

  for FILE in $1/tprocc-20*.log
  do
    HOST_NUM=$(echo $FILE | awk -F '-' '{ print $3 }' | sed 's/cto//g')
    RUN_NUM=$(echo $FILE | awk -F '-' '{ print $4 }' | sed 's/run//g')
    NOPM=$(grep NOPM $FILE | awk '{ print $7 }')
    TPM=$(grep NOPM $FILE | awk '{ print $10 }')

    if [ $PREV_RUN -ne $RUN_NUM ]; then
      PREV_RUN=$RUN_NUM
      echo ""
    else
      echo -n ","
    fi

    echo -n "$NOPM.0,$TPM.0"
  done

  echo ""
}

tproch_text () {
  for FILE in $1/tproch-20*.log
  do
    grep Geometric $FILE | awk -v file=$FILE '{s+=$11}END{print file,":",s/NR}' RS="\n"
  done
}

tproch_table () {
  PREV_RUN=0

  for FILE in $1/tproch-20*.log
  do
    HOST_NUM=$(echo $FILE | awk -F '-' '{ print $3 }' | sed 's/cto//g')
    RUN_NUM=$(echo $FILE | awk -F '-' '{ print $4 }' | sed 's/run//g')
    GEOM=$(grep Geometric $FILE | awk '{s+=$11}END{print s/NR}' RS="\n")

    if [ $PREV_RUN -ne $RUN_NUM ]; then
      PREV_RUN=$RUN_NUM
      echo ""
    else
      echo -n ","
    fi

    echo -n "$GEOM"
  done

  echo ""
}

case ${BENCHMARK} in
  pgbench)
    if [ ${FORMAT} == "text" ]; then
      pgbench_text ${DIRECTORY}
    else
      pgbench_table ${DIRECTORY}
    fi
    ;;
  tprocc)
    if [ ${FORMAT} == "text" ]; then
      tprocc_text ${DIRECTORY}
    else
      tprocc_table ${DIRECTORY}
    fi
    ;;
  tproch)
    if [ ${FORMAT} == "text" ]; then
      tproch_text ${DIRECTORY}
    else
      tproch_table ${DIRECTORY}
    fi
    ;;
esac