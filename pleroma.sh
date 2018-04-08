#!/bin/bash

set -e

function log_generic { # $1: color, $2: prefix, $3: message #
    echo -e "[$(tput setaf $1)$(tput bold)$2$(tput sgr0)] $3"
}

function log_error { # $1: message #
    log_generic 1 ERR "$1"
}

function log_ok { # $1: message #
    log_generic 2 "OK " "$1"
}

function log_info { # $1: message #
    log_generic 4 INF "$1"
}

function print_help {
    echo "
Pleroma Maintenance Script

Usage:
    $0 [action] [flags]

Actions:
    build      Build the pleroma container and all dependencies
    configure  Runs the interactive configuration script
    run        Start pleroma and sibling services
    stop       Stop pleroma and sibling services
    logs       Show the current container logs
"
}

function run_dockerized {
    log_info "Stopping existing containers (if any)"
    docker-compose down

    log_info "Rebuilding images"
    docker-compose build

    log_info "Running action '$1'"
    docker-compose run server $1

    log_info "Cleaning up.."
    docker-compose down
}

function action__build {
    run_dockerized "build"
    log_ok "Done"
}

function action__configure {
    run_dockerized "configure"
    log_ok "Done"
}

function action__run {
    log_info "Booting pleroma"
    docker-compose up --remove-orphans -d
    log_ok "Done"
}

function action__stop {
    log_info "Stopping pleroma"
    docker-compose down
    log_ok "Done"
}

function action__logs {
    docker-compose logs -f
}

function prepare {
    log_info "Preparing script"
    m4 docker-compose.m4 > docker-compose.yml
}

function cleanup {
    log_info "Cleaning up"
    rm docker-compose.yml
}

trap "cleanup" INT TERM EXIT

if [[ -z "$1" ]]; then
    log_error "No action provided."
    print_help
    exit 1
fi

prepare

case "$1" in
build) action__build;;
configure) action__configure;;
run) action__run;;
stop) action__stop;;
logs) action__logs;;
*)
    log_error "The action '$1' is invalid."
    print_help
    exit 1
;;
esac
shift
