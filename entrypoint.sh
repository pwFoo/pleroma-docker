#!/bin/bash

set -e
set -x

mix deps.get
mix ecto.create
mix ecto.migrate
exec mix phx.server
