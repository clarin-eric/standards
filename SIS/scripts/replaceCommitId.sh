#!/bin/env sh

# A bash script to replace <lastUpdateCommitID> in a recommendation file,
# that should be done when there has been an update to the recommendation 
# file.
#
# Technically it deletes the 3rd line of the 1st input file,
# adds a commit-id from the 2nd input file,
# and writes a new recommendation file.
#
#  Command example:
#
#  ./replaceCommitId.sh ACDH-ARCHE-recommendation.xml commit-id.xml output.xml
#
# Author: Eliza Margaretha Illig
# Date: Feb 16h, 2022


INPUT=$1
COMMIT_ID_FILE=$2
OUTPUT=$3
head -n2 "$INPUT" > "$OUTPUT"
echo -n "        <lastUpdateCommitID>" >> "$OUTPUT"
tail -n2 "$COMMIT_ID_FILE" | head -n1 | head -c-1 >> "$OUTPUT"
echo "</lastUpdateCommitID>" >> "$OUTPUT"
tail -n+4  "$INPUT" >> "$OUTPUT"
