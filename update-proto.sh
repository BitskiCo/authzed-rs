#!/bin/sh

set -e

function update_proto {
    usage="Usage: $0 remote repo branch folder"
    remote="${1:?No remote specified
$usage}"
    repo="${2:?No repo specified
$usage}"
    branch="${3:?No branch specified
$usage}"
    folder="${4:?No folder specified
$usage}"

    git remote add -f -t main --no-tags "$remote" "$repo" 2>/dev/null ||
        git fetch "$remote"
    git rm -rf "proto/${folder:?}" 2>&1 >/dev/null || true
    git read-tree --prefix="proto/$folder" -u "$remote/$branch:$folder"
    find "proto/$folder" -type f -and -not -name '*.proto' -exec \
        git rm -f {} \; 2>&1 >/dev/null
}

function find_dependencies {
    xargs -n1 grep 'import "' |
        sed 's@^.*"\(.*\)".*$@\1@' |
        grep -v 'google/protobuf/' |
        sort -u
}

function find_all_dependencies {
    all_deps="$(cat | sort -u)"
    deps="$all_deps"
    while true; do
        deps="$(echo "$deps" | find_dependencies)"
        next_all_deps="$(echo "$all_deps\n$deps" | sort -u)"
        [ "$all_deps" != "$next_all_deps" ] || break
        all_deps="$next_all_deps"
    done
    echo "$all_deps"
}

update_proto authzed https://github.com/authzed/api.git main authzed
update_proto api-common-protos \
    https://github.com/googleapis/api-common-protos.git main google
update_proto protoc-gen-validate \
    https://github.com/envoyproxy/protoc-gen-validate.git main validate
update_proto protoc-gen-openapiv2 \
    https://github.com/grpc-ecosystem/grpc-gateway.git \
    master protoc-gen-openapiv2/options

cd "$(dirname "$0")/proto"

find authzed -name '*.proto' |
    find_all_dependencies |
    sed 's@^@-not\n-path\n*/@' |
    xargs find . -type f |
    xargs git rm -f 2>&1 >/dev/null
