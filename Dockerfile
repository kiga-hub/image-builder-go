FROM golang:1.20-bullseye
# apt mirror
SHELL ["/bin/bash", "-c"]

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3B4FE6ACC0B21F32

RUN gpg --keyserver keyserver.ubuntu.com --recv 3B4FE6ACC0B21F32 && \
    gpg --export --armor 3B4FE6ACC0B21F32 | apt-key add - && \ 
    gpg --keyserver keyserver.ubuntu.com --recv 871920D1991BC93C && \
    gpg --export --armor 871920D1991BC93C | apt-key add - 

COPY files/sources.list /etc/apt/sources.list



RUN apt install apt-transport-https
RUN apt install ca-certificates
RUN apt-get update

RUN apt-get install -y unzip
# RUN apt install software-properties-common -y 
# RUN add-apt-repository ppa:deadsnakes/ppa 

# RUN apt-get update && \
#     apt-get install -y software-properties-common

# RUN apt-get remove -y libdpkg-perl  &&\
#     dpkg --purge --force-all libdpkg-perl && \
# RUN  apt-get install --fix-broken --fix-missing -f -y --allow-downgrades && \
#      wget bzip2 unzip && \
#      apt-get clean



RUN curl -s https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
    echo 'deb https://deb.nodesource.com/node_18.x bullseye main' > /etc/apt/sources.list.d/nodesource.list && \
    echo 'deb-src https://deb.nodesource.com/node_18.x bullseye main' >> /etc/apt/sources.list.d/nodesource.list && \
    apt-get install --fix-missing -f -y --allow-downgrades \
    nodejs && \
    apt-get clean && \
    rm -f /etc/apt/sources.list.d/nodesource.list

# install nodejs for easy building full-stack projects
# RUN npm config set registry https://registry.npm.taobao.org && \
#     npm install -g npm eslint corepack && \
#     node -v && \
#     npm -v 
# && \
#yarn --version

# go env
WORKDIR $GOPATH/src
ENV GO111MODULE=on
ENV GOPROXY=https://goproxy.cn,goproxy.io,proxy.golang.org,direct
ENV GOPRIVATE=""
ENV GOINSECURE=""
ENV PROTOC_VERSION 3.9.1
ENV PROTOC_GEN_GO_VERSION v1.3.2

# RUN curl -OL https://github.com/protocolbuffers/protobuf/releases/download/v$PROTOC_VERSION/protoc-$PROTOC_VERSION-linux-x86_64.zip && \
COPY files/protoc-$PROTOC_VERSION-linux-x86_64.zip /home/protoc-$PROTOC_VERSION-linux-x86_64.zip
RUN unzip -o /home/protoc-$PROTOC_VERSION-linux-x86_64.zip -d /usr/local bin/protoc && \
    unzip -o /home/protoc-$PROTOC_VERSION-linux-x86_64.zip -d /usr/local include/* && \
    rm -rf protoc-$PROTOC_VERSION-linux-x86_64.zip

RUN go install github.com/golang/protobuf/protoc-gen-go@$PROTOC_GEN_GO_VERSION && \
    go install github.com/pseudomuto/protoc-gen-doc/cmd/protoc-gen-doc@latest && \
    go install github.com/grpc-ecosystem/grpc-gateway/protoc-gen-grpc-gateway@latest && \
    go install github.com/grpc-ecosystem/grpc-gateway/protoc-gen-swagger@latest && \
    go install golang.org/x/lint/golint@latest && \
    go install golang.org/x/tools/cmd/goimports@latest && \
    go install github.com/sqs/goreturns@latest


RUN echo "dash dash/sh boolean false" | debconf-set-selections

# install golangci-lint
ENV GOLANGCI_LINT_VERSION v1.46.2
RUN go install github.com/golangci/golangci-lint/cmd/golangci-lint@$GOLANGCI_LINT_VERSION && \
    golangci-lint --version

# install librdkafka-dev
RUN wget -qO - https://packages.confluent.io/deb/5.5/archive.key | apt-key add - && \
    echo 'deb https://deb.nodesource.com/node_16.x bullseye main' > /etc/apt/sources.list.d/confluent.list && \
    #add-apt-repository "deb [arch=amd64] https://packages.confluent.io/deb/5.5 stable main" && \
    apt-get update && \
    apt install librdkafka-dev -y --fix-missing && \
    apt-get clean

# set up taos env
COPY libs/taos.h /usr/include/taos.h
COPY libs/libtaos.so.1 /usr/lib
RUN ln -s /usr/lib/libtaos.so.1 /usr/lib/libtaos.so
