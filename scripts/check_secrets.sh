#!/bin/bash
if grep -rE "sk_live_|sk_test_|4cad4bf7-9530-42fc" lib; then
  echo "Error: Hardcoded secrets found!"
  exit 1
fi
echo "No secrets found."
exit 0
