FROM elixir:1.6-alpine

RUN apk add --no-cache --virtual .build alpine-sdk git

ADD ./entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["run"]

EXPOSE 4000
