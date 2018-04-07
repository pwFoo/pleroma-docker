#!/bin/ash

set -e

function action__build {
    mix local.hex --force
    mix local.rebar --force
    mix deps.get
    mix compile
}

function action__configure {
    mix generate_config
}

function action__run {
    if [[ ! -f /meta/ECTO_REPO_CREATED ]]; then
        mix ecto.create
        touch /meta/ECTO_REPO_CREATED
    fi

    mix ecto.migrate
    exec mix phx.server
}

if [[ -z "$1" ]]; then
    echo "No action provided."
    exit 1
fi

if [[ -z "$PLEROMA_WORKSPACE" ]]; then
    echo "Please set the PLEROMA_WORKSPACE variable to your pleroma root."
    exit 1
fi
cd $PLEROMA_WORKSPACE

case "$1" in
build) action__build;;
configure) action__configure;;
run) action__run;;
*)
    echo "The action '$1' is invalid."
    exit 1
;;
esac
shift
