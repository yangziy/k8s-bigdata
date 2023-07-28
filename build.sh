#!/bin/bash

set -e

# Original repo: https://github.com/hrchlhck/k8s-bigdata
# Original author: vpemfh7
USER=$1

### FUNCTIONS ###
# Build a docker image
function docker_build() {
    local name=$1
    local prefix=$2
    local image=$prefix-$name
    cd $([ -z "$3" ] && echo "$prefix/$name" || echo "$3")
    echo "-------------------------" building image $image in $(pwd)
    docker build --rm -t $image -t $USER/$image . 
    cd -
}


function docker_push() {
	local name=$1
	local prefix=$2
	docker push $USER/$prefix-$name:
}

function build_all() {
	local flag=$1
	local base_dir=$2
	local prefix=$base_dir

	if [[ $flag == "-S" ]]; then
		echo "Building subdirectories"
		for dir in $(ls $base_dir); do
			docker_build $dir $prefix
		done
	else
		docker_build $1
	fi
}

function push_all() {
	local repo_prefix=$1
	for image in $(ls $repo_prefix); do
		echo $USER/$repo_prefix-$image
		docker push $USER/$repo_prefix-$image
	done
}

# Build every directory passed as parameter of the script
# E.g. ./build.sh hibench namenode
# The command above will build Dockerfiles inside ./hibench and ./namenode

docker build spark -t spark-base -t $USER/spark-base
build_all "-S" "hadoop" 
push_all "hadoop"
docker push $USER/spark-base

