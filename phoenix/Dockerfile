FROM elixir:1.17-alpine AS build

RUN apk add --no-cache build-base sqlite-dev

WORKDIR /app
COPY mix.exs mix.lock ./
RUN mix local.hex --force && mix local.rebar --force
RUN MIX_ENV=prod mix deps.get --only prod

COPY . .
RUN MIX_ENV=prod mix compile

FROM elixir:1.17-alpine
RUN apk add --no-cache sqlite-dev
WORKDIR /app
COPY --from=build /app .
RUN mix local.hex --force

ENV MIX_ENV=prod
EXPOSE 4000
CMD ["mix", "phx.server"]
