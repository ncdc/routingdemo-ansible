#!/bin/bash

#set -o errexit
set -o pipefail

DEMO_PROMPT="> "

. demo-magic.sh

#TYPE_SPEED=50

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

function show_ingress() {
  pe "kubectl -n demo get ing/kuard -o json | jq '{ns:.metadata.namespace,name:.metadata.name,annotations:.metadata.annotations, rules: .spec.rules[]}'"
}

export PATH=$PATH:~/go/src/github.com/ncdc/routingdemo

clear

pe cluster1
p "# cluster1 is running v1.9.6:"
pe "kubectl get nodes"
wait
clear

p "# Let's deploy kuard-v1 to cluster1"
pe "kubectl create namespace demo"
pe "kubectl -n demo run --image gcr.io/kuar-demo/kuard-amd64:1 --expose --port 8080 kuard"
pe "kubectl -n demo apply -f kuard-ingress.yaml"
wait
clear

p "# Let's tell the router about kuard.demo"
pe router
pe "kubectl create namespace demo"
pe "r add-vhost kuard"
show_ingress
wait
clear

p "# Let's tell the router about a backend cluster"
pe "r add-backend cluster1"
p "# Let's see how that changed the ingress"
show_ingress
wait
clear

p "# Let's load test it"
pe "bench.sh"
wait
clear

p "# Let's create a backup"
pe cluster1
pe "ark backup create kuard --include-namespaces demo"
wait
clear

# p "# Let's deploy a new 1.10 cluster"
# pe "KUBERNETES_VERSION=1.10.1 vagrant up cluster2"
# wait
# clear

p "# We have a new 1.10.1 cluster waiting for us :-)"
pe cluster2
pe "kubectl get nodes"
wait
clear

p "# Let's install Ark there"
pe "kubectl apply -f ark/00-prereqs.yaml -f ark/10-ark-config-restore-only.yaml -f ark/20-ark-deployment.yaml"
wait
clear

p "# Let's see if the backup synced"
pe "ark backup get"
wait
clear

p "# There's no 'demo' namespace in the new cluster:"
pe "kubectl get ns/demo"

p "# Let's restore from the backup"
pe "ark restore create kuard --from-backup kuard"
wait
clear

p "# Let's check out the demo namespace"
pe "kubectl -n demo get deployments"
pe "kubectl -n demo get services"
pe "kubectl -n demo get ingresses"
wait
clear

p "# Let's add the new cluster as a backend to the router"
pe router
pe "r add-backend cluster2"
p "# Let's see how that changed the ingress"
show_ingress
wait
clear

p "# Let's send 10% of traffic to the new cluster"
pe "kubectl -n demo annotate ing/kuard --overwrite weight.kuard-cluster1=90 weight.kuard-cluster2=10"
p "# Let's see how that changed the ingress"
show_ingress
wait
clear

p "# Let's load test it"
pe "bench.sh"
wait
clear

p "# Let's send all traffic to the new cluster"
pe "kubectl -n demo annotate ing/kuard --overwrite weight.kuard-cluster1=0 weight.kuard-cluster2=100"
p "# Let's see how that changed the ingress"
show_ingress
wait
clear

p "# Let's load test it again"
pe "bench.sh"
wait
clear

p "# Let's delete the cluster1 backend"
pe "r delete-backend cluster1"
p "# Let's see how that changed the ingress"
show_ingress
wait
clear

p "# Let's load test it again"
pe "bench.sh"