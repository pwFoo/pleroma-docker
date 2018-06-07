FROM elixir:1.6-alpine

ENV MIX_HOME /mix
ENV MIX_ARCHIVES /mix-archives

# Prepare system
RUN apk add --no-cache --virtual .build alpine-sdk git rsync

# Bust the cache with a build arg
# that is different on every build
ARG __BUST_CACHE
ENV __BUST_CACHE $__BUST_CACHE

# Get the sources
ARG PLEROMA_VERSION
WORKDIR /pleroma
RUN git clone --progress https://git.pleroma.social/pleroma/pleroma.git . && git checkout $PLEROMA_VERSION

# Inject config
ADD ./docker-config.exs /docker-config.exs
RUN \
    ln -s /docker-config.exs config/prod.secret.exs && \
    ln -s /docker-config.exs config/dev.secret.exs

# Correct paths
WORKDIR /
VOLUME /custom.d

# Register entrypoint
ADD ./entrypoint.ash /
RUN chmod +x /entrypoint.ash
CMD ["/entrypoint.ash"]

# Call entrypoint to precompile pleroma
RUN /entrypoint.ash onbuild

EXPOSE 4000
