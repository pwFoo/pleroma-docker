FROM elixir:1.6-alpine

env MIX_HOME /mix
env MIX_ARCHIVES /mix-archives

# Prepare system
RUN apk add --no-cache --virtual .build alpine-sdk git rsync

# Perform a clone that can be cached
WORKDIR /pleroma
RUN git clone --progress https://git.pleroma.social/pleroma/pleroma.git .

# Bust the cache with a build arg
# that is different on every build
ARG __BUST_CACHE
ENV __BUST_CACHE $__BUST_CACHE

# Update pleroma
ARG PLEROMA_VERSION
RUN \
    git checkout $PLEROMA_VERSION && \
    git pull --rebase --autostash

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
