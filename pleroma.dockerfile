FROM elixir:1.6-alpine

WORKDIR /pleroma

# Prepare system
RUN apk add --no-cache --virtual .build alpine-sdk git rsync

# Perform a clone that can be cached
RUN git clone https://git.pleroma.social/pleroma/pleroma.git .

# Prepare pleroma
ADD ./docker-config.exs /docker-config.exs
ARG PLEROMA_VERSION
RUN \
    git checkout $PLEROMA_VERSION && \
    git pull --rebase --autostash && \
    ln -s /docker-config.exs config/prod.secret.exs && \
    ln -s /docker-config.exs config/dev.secret.exs

# Register entrypoint
ADD ./entrypoint.ash /
RUN chmod +x /entrypoint.ash
CMD ["/entrypoint.ash"]

EXPOSE 4000
