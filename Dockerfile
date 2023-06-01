# Build the application
FROM docker.io/library/golang:1.19-buster AS back

WORKDIR /go/src/app

COPY . .

RUN go get -d -v ./...
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags "-s" -o luccryptous .


# Build the Svelte SPA
FROM docker.io/library/debian:buster AS front

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
FROM docker.io/library/alpine:latest

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
