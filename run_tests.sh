#!/usr/bin/env bash
# Manual test matrix runner for the Campus Parking CLI.
#
# This is a helper for filling in the "Actual" column of the test matrix
# in README.md. It feeds each case's keystrokes into the program and prints
# only the lines that matter, so the result can be compared with "Expected".
#
# Usage:  bash run_tests.sh            (all cases)
#         bash run_tests.sh T26        (one case)
#         bash run_tests.sh > result.txt

set -u

FILTER="${1:-}"

# Lines worth showing: fee breakdown, error messages, summary, cancel notice.
KEEP='Normal fee|Member discount|Lost-ticket fee|Lost ticket|Final fee'
KEEP="$KEEP"'|Invalid number|Duration cannot be negative|Plate cannot be empty'
KEEP="$KEEP"'|Invalid vehicle type|Please enter y or n|Invalid choice'
KEEP="$KEEP"'|Transaction cancelled|Car Out'
KEEP="$KEEP"'|Total transactions|Cars |Motorcycles |Other |Members |Lost tickets |Total revenue'

run_case() {
  local id="$1" desc="$2" expected="$3" input="$4"

  if [ -n "$FILTER" ] && [ "$FILTER" != "$id" ]; then
    return
  fi

  echo "===================================================================="
  echo "$id  |  $desc"
  echo "Expected: $expected"
  echo "--------------------------------------------------------------------"
  printf '%b' "$input" | dart run bin/main.dart 2>&1 | grep -E "$KEEP" || true
  echo
}

echo "Campus Parking - manual test matrix"
echo "Generated: $(date '+%Y-%m-%d %H:%M')"
echo

echo "#### GROUP 1 - BOUNDARY CASES ####"
echo
run_case T01 "car, 0 min"          "Final fee 0.00"   '1\nABC123\ncar\n0\nn\nn\n3\n'
run_case T02 "car, 15 min"         "Final fee 0.00"   '1\nABC123\ncar\n15\nn\nn\n3\n'
run_case T03 "car, 16 min"         "Final fee 20.00"  '1\nABC123\ncar\n16\nn\nn\n3\n'
run_case T04 "car, 60 min"         "Final fee 20.00"  '1\nABC123\ncar\n60\nn\nn\n3\n'
run_case T05 "car, 61 min"         "Final fee 40.00"  '1\nABC123\ncar\n61\nn\nn\n3\n'
run_case T06 "car, 120 min"        "Final fee 40.00"  '1\nABC123\ncar\n120\nn\nn\n3\n'
run_case T07 "car, 121 min"        "Final fee 60.00"  '1\nABC123\ncar\n121\nn\nn\n3\n'
run_case T08 "car, 500 min (cap)"  "Final fee 100.00" '1\nABC123\ncar\n500\nn\nn\n3\n'
run_case T09 "motorcycle, 15 min"  "Final fee 0.00"   '1\nABC123\nmotorcycle\n15\nn\nn\n3\n'
run_case T10 "motorcycle, 16 min"  "Final fee 10.00"  '1\nABC123\nmotorcycle\n16\nn\nn\n3\n'
run_case T11 "motorcycle, 61 min"  "Final fee 20.00"  '1\nABC123\nmotorcycle\n61\nn\nn\n3\n'
run_case T12 "motorcycle, 121 min" "Final fee 30.00"  '1\nABC123\nmotorcycle\n121\nn\nn\n3\n'
run_case T13 "motorcycle, 500 min" "Final fee 50.00"  '1\nABC123\nmotorcycle\n500\nn\nn\n3\n'
run_case T14 "car, 999999 min"     "Final fee 100.00" '1\nABC123\ncar\n999999\nn\nn\n3\n'

echo "#### GROUP 2 - INVALID INPUT ####"
echo
run_case T15 "vehicle type CAR (upper case)"  "accepted as car, 20.00"     '1\nABC123\nCAR\n30\nn\nn\n3\n'
run_case T16 "vehicle type ' car ' (spaces)"  "accepted as car, 20.00"     '1\nABC123\n car \n30\nn\nn\n3\n'
run_case T17 "vehicle type truck"             "Invalid vehicle type, ask again" '1\nABC123\ntruck\ncar\n30\nn\nn\n3\n'
run_case T18 "vehicle type empty"             "Invalid vehicle type, ask again" '1\nABC123\n\ncar\n30\nn\nn\n3\n'
run_case T19 "duration abc"                   "Invalid number, ask again"  '1\nABC123\ncar\nabc\n30\nn\nn\n3\n'
run_case T20 "duration -1"                    "Duration cannot be negative" '1\nABC123\ncar\n-1\n30\nn\nn\n3\n'
run_case T21 "duration empty"                 "Invalid number, ask again"  '1\nABC123\ncar\n\n30\nn\nn\n3\n'
run_case T22 "duration 0"                     "accepted, Final fee 0.00"   '1\nABC123\ncar\n0\nn\nn\n3\n'
run_case T23 "member answer x"                "Please enter y or n"        '1\nABC123\ncar\n30\nx\nn\nn\n3\n'
run_case T24 "menu choice 9"                  "Invalid choice, no crash"   '9\n3\n'

echo "#### GROUP 3 - BUSINESS RULE INTERACTION ####"
echo
run_case T25 "car 500, non-member"            "Final fee 100.00"                 '1\nABC123\ncar\n500\nn\nn\n3\n'
run_case T26 "car 500, member (cap first)"    "Normal 100 / Discount 20 / 80.00" '1\nABC123\ncar\n500\ny\nn\n3\n'
run_case T27 "motorcycle 500, member"         "Normal 50 / Discount 10 / 40.00"  '1\nABC123\nmotorcycle\n500\ny\nn\n3\n'
run_case T28 "car 10, member (free + member)" "Final fee 0.00"                   '1\nABC123\ncar\n10\ny\nn\n3\n'
run_case T29 "car, lost ticket"               "Final fee 200.00"                 '1\nABC123\ncar\n30\nn\ny\n3\n'
run_case T30 "car, member + lost ticket"      "Final fee 200.00, no discount"    '1\nABC123\ncar\n30\ny\ny\n3\n'
run_case T31 "motorcycle, lost ticket"        "Final fee 100.00"                 '1\nABC123\nmotorcycle\n30\nn\ny\n3\n'
run_case T32 "car 185, member"                "Normal 80 / Discount 16 / 64.00"  '1\nABC123\ncar\n185\ny\nn\n3\n'

echo "#### GROUP 4 - APPLICATION STATE ####"
echo
run_case T33 "summary before any transaction" "all counters 0, revenue 0.00" '2\n3\n'
run_case T34 "three transactions (task section 14)" \
  "total 3 / cars 2 / mc 1 / members 2 / lost 1 / revenue 244.00" \
  '1\nA1\ncar\n30\nn\nn\n1\nA2\nmotorcycle\n121\ny\nn\n1\nA3\ncar\n10\ny\ny\n2\n3\n'
run_case T35 "cancel halfway, then summary" \
  "total stays 1, revenue 20.00" \
  '1\nA1\ncar\n30\nn\nn\n1\nA2\ncar\ncancel\n2\n3\n'
run_case T36 "two transactions then exit" "exits cleanly" \
  '1\nA1\ncar\n30\nn\nn\n1\nA2\ncar\n61\nn\nn\n3\n'

echo "#### EXTRA CASES ####"
echo
run_case T37 "plate empty"              "Plate cannot be empty, ask again" '1\n\nABC123\ncar\n30\nn\nn\n3\n'
run_case T38 "cancel at the first field" "Transaction cancelled, summary 0" '1\ncancel\n2\n3\n'
run_case T39 "input runs out (no exit command)" "cancels and exits cleanly" '1\nABC123\ncar\n'
run_case T40 "other, 30 min"          "Final fee 30.00"  '1\nABC123\nother\n30\nn\nn\n3\n'
run_case T41 "other, 500 min (cap)"   "Final fee 150.00" '1\nABC123\nother\n500\nn\nn\n3\n'
run_case T42 "other, lost ticket"     "Final fee 300.00" '1\nABC123\nother\n30\nn\ny\n3\n'

echo "===================================================================="
echo "Done. Compare each Expected line with the output below it."
