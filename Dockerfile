# Build the application
FROM docker.io/library/golang:1.23-bookworm@sha256:18d2f940cc20497f85466fdbe6c3d7a52ed2db1d5a1a49a4508ffeee2dff1463 AS back

WORKDIR /go/src/app

COPY . .

RUN go get -d -v ./...
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags "-s" -o luccryptous .


# Build the Svelte SPA
FROM docker.io/library/debian:bookworm@sha256:27586f4609433f2f49a9157405b473c62c3cb28a581c413393975b4e8496d0ab AS front

WORKDIR /app

RUN apt update -y \
 && apt install -y \
        git \
        npm \
        nodejs \
 && rm -rf /var/lib/apt/lists/*

COPY front .

RUN npm install
RUN npm run build


# Image release
FROM docker.io/library/alpine:latest@sha256:beefdbd8a1da6d2915566fde36db9db0b524eb737fc57cd1367effd16dc0d06d

WORKDIR /root/
EXPOSE 3000

RUN apk --no-cache add ca-certificates

COPY views ./views
COPY --from=back /go/src/app/luccryptous .
COPY --from=front /app/public/build/bundle.js ./views/
COPY --from=front /app/public/build/bundle.css ./views/

# Use a volume instead
COPY luccryptous.toml .

CMD ["./luccryptous"]
