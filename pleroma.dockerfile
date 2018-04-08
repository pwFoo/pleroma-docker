FROM elixir:1.6-alpine

RUN apk add --no-cache --virtual .build alpine-sdk git

ADD ./docker-config.exs /docker-config.exs

ADD ./entrypoint.ash /
RUN chmod +x /entrypoint.ash
ENTRYPOINT ["/entrypoint.ash"]
CMD ["run"]

EXPOSE 4000
