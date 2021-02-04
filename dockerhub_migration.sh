#!/bin/bash
declare -a arr=("istio/sidecar_injector:1.2.0" "istio/proxyv2:1.2.0" "istio/proxy_init:1.2.0") #Put any images you want in the array
DEST_HUB=*******.dkr.ecr.us-east-1.amazonaws.com

for i in "${arr[@]}"
do
    version=$(echo "$i" | cut -d ":" -f 2) # v1.9.7
    rest=$(echo "$i" | cut -d ":" -f 1)
    image=$(echo "$rest" | awk -F "/" '{print $NF}') 
    source_hub=$(echo ${rest%/*}) 
    echo $i
    echo $source_hub
    echo $image
    echo $version
    echo
    echo "===================================="
    name=$image:$version
    docker pull $source_hub/$name
    docker tag $source_hub/$name $DEST_HUB/$name
    aws ecr describe-repositories --repository-names $image || aws ecr create-repository --repository-name $image
    docker push $DEST_HUB/$name
    docker rmi $source_hub/$name
    docker rmi $DEST_HUB/$name
done
