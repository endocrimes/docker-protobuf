FROM golang:1.8.0
MAINTAINER Danielle Tomlinson <dani@tomlinson.io>

ENV GRPC_VERSION=1.3.1              \
    PROTOBUF_VERSION=3.2.0          \
    GOPATH=/go

RUN apt-get update && apt-get install -y \
        unzip \
        libtool \
        autoconf \
        zlib1g-dev \
        make \
        cmake \
    && apt-get clean \

    # Install protobuf
    && wget https://github.com/google/protobuf/archive/v${PROTOBUF_VERSION}.tar.gz \
    && tar xvzf v${PROTOBUF_VERSION}.tar.gz \
    && cd protobuf-${PROTOBUF_VERSION} \
    && /go/protobuf-${PROTOBUF_VERSION}/autogen.sh \
    && /go/protobuf-${PROTOBUF_VERSION}/configure \
    && make -C /go/protobuf-${PROTOBUF_VERSION} \
    && make install -C /go/protobuf-${PROTOBUF_VERSION} \
    && cd /go \

    # Install grpc
    && git clone https://github.com/grpc/grpc -b v${GRPC_VERSION} /go/grpc \
    && cd /go/grpc \
    && git submodule update --init --recursive\
    && LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib make -C /go/grpc \
    && make install -C /go/grpc \

    # Install grpc-go
    && go get -u google.golang.org/grpc \

    # Install protoc-gen-go
    && go get -a github.com/golang/protobuf/protoc-gen-go \
    && mkdir -p /protobuf/google/protobuf \
    && for f in any duration descriptor empty struct timestamp wrappers; do \
         curl -L -o /protobuf/google/protobuf/${f}.proto https://raw.githubusercontent.com/google/protobuf/master/src/google/protobuf/${f}.proto; \
       done \
    # Clean up
    && cd /go \
    && rm /go/v${PROTOBUF_VERSION}.tar.gz \
    && rm -rf /go/${PROTOBUF_VERSION} \
    && rm -rf /go/grpc

ENTRYPOINT ["/usr/local/bin/protoc", "-I/protobuf"]
