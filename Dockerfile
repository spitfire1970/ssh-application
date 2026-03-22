FROM golang:1.22-alpine AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o server .

FROM alpine:3.19

RUN apk add --no-cache openssh-keygen

WORKDIR /app
COPY --from=builder /app/server .

EXPOSE 22

CMD mkdir -p .ssh && \
    [ -f .ssh/id_ed25519 ] || ssh-keygen -t ed25519 -f .ssh/id_ed25519 -N "" && \
    ./server
