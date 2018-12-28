FROM ubuntu:latest

MAINTAINER Nico Lucciola version: 0.2

ENV MACVERSION=0.16

ENV MACPREFIX=/machinecoin/depends/x86_64-pc-linux-gnu

RUN apt-get update && apt-get install -y git build-essential wget pkg-config curl libtool autotools-dev automake libssl-dev libevent-dev bsdmainutils libboost-system-dev libboost-filesystem-dev libboost-chrono-dev libboost-program-options-dev libboost-test-dev libboost-thread-dev

WORKDIR /

RUN mkdir -p /berkeleydb && git clone https://gitlab.com/machinecoin-project/machinecoin-core.git machinecoin

WORKDIR /berkeleydb

RUN wget http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz && tar -xvf db-4.8.30.NC.tar.gz && rm db-4.8.30.NC.tar.gz && mkdir -p db-4.8.30.NC/build_unix/build

ENV BDB_PREFIX=/berkeleydb/db-4.8.30.NC/build_unix/build

WORKDIR /berkeleydb/db-4.8.30.NC/build_unix

RUN ../dist/configure --disable-shared --enable-cxx --with-pic --prefix=$BDB_PREFIX

RUN make install

RUN apt-get update && apt-get install -y libminiupnpc-dev libzmq3-dev libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler libqrencode-dev

WORKDIR /machinecoin

RUN git checkout ${MACVERSION} && mkdir -p /machinecoin/machinecoin-${MACVERSION}

WORKDIR /machinecoin/depends

RUN make -j4

WORKDIR /machinecoin

RUN ./autogen.sh

RUN ./configure CPPFLAGS="-I${BDB_PREFIX}/include/ -O2" LDFLAGS="-L${BDB_PREFIX}/lib/ -static-libstdc++" --with-gui --prefix=${MACPREFIX} --disable-ccache --disable-maintainer-mode --disable-dependency-tracking --enable-glibc-back-compat --enable-reduce-exports --disable-bench --disable-gui-tests --enable-static

RUN make -j4

RUN make install DESTDIR=/machinecoin/machinecoin-${MACVERSION}

RUN mv /machinecoin/machinecoin-${MACVERSION}${MACPREFIX} /machinecoin-${MACVERSION} && strip /machinecoin-${MACVERSION}/bin/* && rm -rf /machinecoin-${MACVERSION}/lib/pkgconfig && find /machinecoin-${MACVERSION} -name "lib*.la" -delete && find /machinecoin-${MACVERSION} -name "lib*.a" -delete 

WORKDIR /

RUN tar cvf machinecoin-${MACVERSION}.tar machinecoin-${MACVERSION} 
