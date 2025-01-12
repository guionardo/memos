# Build frontend dist.
FROM node:18.12.1-alpine3.16 AS frontend
WORKDIR /frontend-build

COPY ./web/ .

RUN yarn
RUN yarn build

# Build backend exec file.
FROM golang:1.19.3-alpine3.16 AS backend
WORKDIR /backend-build

RUN apk update
RUN apk --no-cache add gcc musl-dev

COPY . .
COPY --from=frontend /frontend-build/dist ./server/dist

RUN go build -o memos ./bin/server/main.go

# Make workspace with above generated files.
FROM alpine:3.21.2 AS monolithic
WORKDIR /usr/local/memos

COPY --from=backend /backend-build/memos /usr/local/memos/

# Directory to store the data, which can be referenced as the mounting point.
RUN mkdir -p /var/opt/memos

ENTRYPOINT ["./memos", "--mode", "prod", "--port", "5230"]
