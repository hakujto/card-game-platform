FROM crystallang/crystal:1.10 AS builder
WORKDIR /app
COPY shard.yml shard.lock* ./
RUN shards install --production
COPY . .
RUN crystal build src/cards_project.cr -o bin/cards_project --release

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends libsqlite3-0 ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=builder /app/bin/cards_project ./server
ENV PORT=3000
EXPOSE 3000
CMD ["./server"]
