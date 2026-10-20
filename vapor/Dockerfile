# Build stage
FROM swift:5.9-jammy AS builder
WORKDIR /app
COPY . .
RUN swift build -c release --disable-sandbox

# Runtime stage
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y libssl-dev ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=builder /app/.build/release/App .
COPY --from=builder /app/Resources ./Resources
EXPOSE 8080
ENTRYPOINT ["./App", "serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]
