FROM golang:latest as builder
ADD . /go/src/websocket 
WORKDIR /go/src/websocket
RUN go get github.com/gorilla/websocket
COPY index.html .
COPY src/main.go .
RUN CGO_ENABLED=0 GOOS=linux go install
EXPOSE 3000
CMD ["/go/bin/websocket"]


FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /go/bin/websocket .
COPY index.html .
EXPOSE 3000
CMD ["./websocket"]