FROM elixir:1.7-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV MIX_ENV=prod

VOLUME /custom.d

EXPOSE 4000

# Register pseudo-entrypoint
ADD ./entrypoint.sh /
RUN chmod +x /entrypoint.sh
CMD ["/entrypoint.sh"]

# Set "real" entrypoint to an init system.
# TODO: Replace with --init when docker 18.06 is GA
ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]

# Get git
RUN \
       apt-get update \
    && apt-get install -y --no-install-recommends git ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Limit rights
ARG DOCKER_UID
ARG DOCKER_GID
ARG PLEROMA_UPLOADS_PATH

RUN \
       addgroup --gid ${DOCKER_GID} pleroma \
    && adduser --system --home /pleroma --shell /bin/bash --ingroup pleroma --uid ${DOCKER_UID} pleroma \
    && mkdir -p /pleroma /custom.d $PLEROMA_UPLOADS_PATH \
    && touch /pleroma.md5 \
    && chown -R pleroma:pleroma /pleroma /pleroma.md5 /custom.d $PLEROMA_UPLOADS_PATH

USER pleroma

# Get the sources and rebar/hex
ARG PLEROMA_VERSION
WORKDIR /pleroma

RUN \
       git clone --progress https://git.pleroma.social/pleroma/pleroma.git . \
    && mix local.hex --force \
    && mix local.rebar --force

# Bust the build cache
ARG __BUST_CACHE
ENV __BUST_CACHE $__BUST_CACHE

# Fetch changes, checkout
RUN \
       git fetch --all \
    && git checkout $PLEROMA_VERSION \
    && git pull --rebase --autostash

# Modify sources
ADD ./docker-config.exs /docker-config.exs

RUN \
    ln -s /docker-config.exs config/prod.secret.exs && \
    ln -s /docker-config.exs config/dev.secret.exs

ADD ./custom.d /pleroma
