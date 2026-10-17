FROM debian:bookworm-slim AS builder
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl xz-utils libsqlite3-dev ca-certificates && \
    rm -rf /var/lib/apt/lists/*
RUN curl -fsSL https://ziglang.org/download/0.14.0/zig-linux-x86_64-0.14.0.tar.xz \
    | tar -xJ -C /usr/local --strip-components=1
WORKDIR /app
COPY . .
RUN zig build -Doptimize=ReleaseSafe

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends libsqlite3-0 ca-certificates && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=builder /app/zig-out/bin/cards_project .
ENV PORT=8080
EXPOSE 8080
CMD ["./cards_project"]
