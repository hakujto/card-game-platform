FROM haskell:9.12 AS build

WORKDIR /app
COPY cards-project.cabal cabal.project ./
RUN cabal update && cabal build --only-dependencies

COPY . .
RUN cabal build && cp $(cabal list-bin cards-project) /app/server

FROM debian:bookworm-slim
RUN apt-get update -qq && apt-get install -y libsqlite3-0 sqlite3 && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=build /app/server .
COPY schema.sql .
RUN mkdir -p db && sqlite3 db/cards-project.db < schema.sql
EXPOSE 8080
CMD ["./server"]
