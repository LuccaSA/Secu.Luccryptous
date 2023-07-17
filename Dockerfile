# Build the application
FROM docker.io/library/golang:1.19-buster@sha256:46bab7f043402231a9ed12ef2a4b0a9d090e3abc005297de920160a76bc71da3 AS back

WORKDIR /go/src/app

COPY . .

RUN go get -d -v ./...
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags "-s" -o luccryptous .


# Build the Svelte SPA
FROM docker.io/library/debian:buster@sha256:c21dbb23d41cb3f1c1a7f841e8642bf713934fb4dc5187979bd46f0b4b488616 AS front

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
FROM docker.io/library/alpine:latest@sha256:82d1e9d7ed48a7523bdebc18cf6290bdb97b82302a8a9c27d4fe885949ea94d1

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
