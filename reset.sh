#!/bin/bash

source ~/code/ktx/ktx-completion.sh

function router() {
    eval $(ktx router)
}

function cluster1() {
    eval $(ktx cluster1)
}

function cluster2() {
    eval $(ktx cluster2)
}

function cluster3() {
    eval $(ktx cluster3)
}

export PATH=$PATH:~/go/src/github.com/ncdc/routingdemo

function wait_for_error() {
  while true; do
    if ! $($1 &> /dev/null); then
      return 0
    fi
    echo -n .
    sleep 1
  done
}

router
r delete-backend cluster1
r delete-backend cluster2
r delete-vhost kuard
kubectl delete ns/demo
wait_for_error "kubectl get ns/demo"

cluster1
ark backup delete kuard --confirm
kubectl delete ns/demo
wait_for_error "kubectl get ns/demo"

cluster2
kubectl delete -f ark/20-ark-deployment.yaml
ark restore delete kuard
kubectl delete ns/demo
wait_for_error "kubectl get ns/demo"
kubectl delete -f ark/00-prereqs.yaml -f ark/10-ark-config-restore-only.yaml -f ark/20-ark-deployment.yaml
wait_for_error "kubectl get ns/heptio-ark"