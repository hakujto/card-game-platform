FROM ocaml/opam:debian-12-ocaml-5.1 AS build

WORKDIR /app
COPY cards_project.opam ./
RUN opam install --deps-only -y .

COPY . .
RUN eval $(opam env) && dune build

RUN eval $(opam env) && ./_build/default/migrate.exe

FROM debian:12-slim
RUN apt-get update && apt-get install -y libsqlite3-0 && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=build /app/_build/default/main.exe ./server
COPY --from=build /app/cards_project.db ./
EXPOSE 3000
CMD ["./server"]
