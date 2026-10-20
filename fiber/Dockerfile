FROM golang:1.22-bookworm AS builder
RUN apt-get update && apt-get install -y --no-install-recommends gcc libsqlite3-dev && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go mod tidy && CGO_ENABLED=1 GOOS=linux go build -o server .

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends libsqlite3-0 ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=builder /app/server .
ENV PORT=8080
EXPOSE 8080
CMD ["./server"]
