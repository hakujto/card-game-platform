FROM erlang:26-alpine AS builder
WORKDIR /app
COPY . .
RUN rebar3 release

FROM erlang:26-alpine
WORKDIR /app
COPY --from=builder /app/_build/default/rel/cards_project .
EXPOSE 8080
CMD ["bin/cards_project", "foreground"]
