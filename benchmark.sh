# Script to run benchmarks on some pre-chosen, structured problems (every cnf
# file in the ./bench directory).  Results are placed in the $RESULTS_DIR, which
# is dependent on the current date to the minute, and simply contain the output
# of the SAT solver as well as timing information.
#
# These results can be interpreted and put into a comparison graph with
# bench/GraphResult.hs

DSAT=./dist/build/funsat/funsat
RESULTS_DIR=bench-results/$(gdate +%F.%H%M)

MAX_PROB_SECONDS="300"
echo "Max time per problem:" $MAX_PROB_SECONDS "seconds"

# Use expect to terminate process if it times out.
TIMED="expect -f /Volumes/work/scripts/misc/timed-run $MAX_PROB_SECONDS"

mkdir -p $RESULTS_DIR

echo "Timeout:" $MAX_PROB_SECONDS "seconds" >> $RESULTS_DIR/info

read -p "Purpose: " -e MOREINFO
echo $MOREINFO >> $RESULTS_DIR/info

# record feature set


i=$((0))
for options in ""
#               "--no-clause-learning"                \
#               "--no-restarts"                       \
#               "--no-watched-literals"               \
#               "--no-vsids"
do
    i=$(($i+1))
    OUTPUT="$RESULTS_DIR/result.$i"

    CMD="$DSAT $options"
    echo "-->" $CMD

#     find ./bench -iname "*.cnf" -exec $TIMED $CMD 2>&1 > $OUTPUT \;
    find ./bench -iname "*.cnf" |
      while read FILE
      do
          ( $TIMED /usr/bin/time $CMD $FILE ) >> $OUTPUT 2>> $OUTPUT
          if [ "$?" -ne 0 ]
          then exit 1
          fi
      done
done