#! /bin/bash
date && echo start exection
MASTER=$(yc compute instance list | grep kuber1 | awk '{print $10}')
date && echo master=$MASTER 
KUBER2=$(yc compute instance list | grep kuber2 | awk '{print $10}')
date && echo kuber2=$KUBER2 
WORKERS=($KUBER2) && declare -a WORKERS
date && echo worker_list=${WORKERS[@]}
TOKEN=$(ssh ubuntu\@$MASTER "sudo kubeadm token list" | awk '{print $1}' | grep -v TOKEN)
date && echo token=$TOKEN
HASH=$(ssh ubuntu\@$MASTER 'echo sha256:$(openssl x509 -in /etc/kubernetes/pki/ca.crt -noout -pubkey | openssl rsa -pubin -outform DER 2>/dev/null | sha256sum | cut -d" " -f1)')
date && echo hash=$HASH

for WORKER in $WORKERS; do echo $WORKER; ssh ubuntu\@$WORKER "sudo kubeadm join kuber1:6443 --token $TOKEN --discovery-token-ca-cert-hash $HASH"; done
