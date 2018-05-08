#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

agent=$(uuidgen)
now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo 'Running a 5-second load test'
wrk -c5 -t3 -d5s -H "User-Agent: ${agent}" http://kuard.demo/ &> /dev/null

#kubectl --kubeconfig ~/.kube/router -n heptio-contour logs deploy/contour -c envoy --since-time "${now}" | grep "${agent}" | grep -o '10\.211\.55\.5[0-9]' | sort | uniq -c

echo
echo 'Results:'
echo

kubectl --kubeconfig ~/.kube/router -n heptio-contour logs deploy/contour -c envoy --since-time "${now}" | \
  grep "${agent}" | \
  awk 'BEGIN{FPAT="([^ ]+)|(\"[^\"]+\")"}{print $13}' | \
  tr -d '"' | \
  cut -d: -f1 | \
  sort | \
  uniq -c
