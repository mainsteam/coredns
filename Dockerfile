FROM golang:1.17-bullseye
RUN apt-get update && apt-get -uy upgrade
RUN apt-get -y install ca-certificates libunbound-dev && update-ca-certificates

#COPY ./ /build
RUN mkdir /build
WORKDIR /build
RUN git clone https://github.com/coredns/coredns

WORKDIR /build/coredns
RUN git checkout tags/v1.9.1 -b v1.9.1
RUN echo "unbound:github.com/coredns/unbound" >> /build/coredns/plugin.cfg

RUN go get github.com/coredns/unbound
RUN go generate
RUN CGO_ENABLED=1 go build


FROM debian:bullseye-slim

RUN apt-get update && apt-get -uy upgrade
RUN apt-get -y install libunbound-dev libunbound8

COPY --from=0 /etc/ssl/certs /etc/ssl/certs
COPY --from=0 /build/coredns/coredns /coredns

EXPOSE 53 53/udp
ENTRYPOINT ["/coredns"]
