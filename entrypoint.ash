#!/bin/ash

set -e

function compile {
    # Make sure that the tooling is present
    mix local.hex --force
    mix local.rebar --force

    # Recompile
    mix deps.get
    mix compile
}

# Execute onbuild actions if required
if [[ "$1" == "onbuild" ]]; then
    # On build we use the sources instead of the runtime
    cd /pleroma
    compile
    exit 0
fi

# Ensure that the environment is clean
if [[ -d /pleroma-runtime ]]; then
    rm -rf /pleroma-runtime
fi
mkdir /pleroma-runtime

# Copy sources
rsync -azI /pleroma/ /pleroma-runtime/

# Copy overrides
rsync -azI /custom.d/ /pleroma-runtime/

# Go to runtime workspace
cd /pleroma-runtime

# Build
compile

# Prepare DB
mix ecto.create
mix ecto.migrate

# Liftoff o/
exec mix phx.server
