FROM debian:bullseye
# apt mirror
RUN apt-get update && \
    apt-get install -y --fix-missing apt-transport-https ca-certificates && \
    sed -i "s@http://deb.debian.org@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list && \
    sed -i "s@http://security.debian.org@https://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --fix-missing unzip curl wget jq git software-properties-common libgd3 libtiff5 && \
    apt-get upgrade -y --fix-missing && apt-get dist-upgrade -y && apt-get clean;
# set up taos env
COPY libs/taos.h /usr/include/taos.h
COPY libs/libtaos.so.1 /usr/lib
RUN ln -s /usr/lib/libtaos.so.1 /usr/lib/libtaos.so
