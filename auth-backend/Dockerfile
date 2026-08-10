FROM golang:1.23-alpine AS build
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /out/mobile-auth ./cmd/auth

FROM alpine:3.21
RUN apk add --no-cache ca-certificates wget && addgroup -S auth && adduser -S -G auth auth
COPY --from=build /out/mobile-auth /usr/local/bin/mobile-auth
USER auth:auth
EXPOSE 2027
ENTRYPOINT ["/usr/local/bin/mobile-auth"]
CMD ["serve"]
