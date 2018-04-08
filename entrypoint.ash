#!/bin/ash

set -e

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

# Make sure that the tooling is present
mix local.hex --force
mix local.rebar --force

# Recompile
mix deps.get
mix clean && mix compile

# Prepare DB
mix ecto.create
mix ecto.migrate

# Liftoff o/
exec mix phx.server
