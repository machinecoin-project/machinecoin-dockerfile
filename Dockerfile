FROM ubuntu:bionic

ARG VERSION=0.17.1

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils python3 cmake libgmp3-dev libboost-all-dev software-properties-common libminiupnpc-dev libzmq3-dev wget git unzip
RUN add-apt-repository -y ppa:bitcoin/bitcoin && \
    apt-get update && \
    apt-get install -y libdb4.8-dev libdb4.8++-dev

WORKDIR /opt/bls

RUN wget https://github.com/codablock/bls-signatures/archive/v20181101.zip && \
    unzip v20181101.zip && \
    cd bls-signatures-20181101 && \
    cmake . && \
    make install

WORKDIR /opt/machinecoin

RUN git clone https://github.com/machinecoin-project/machinecoin-core && \
    cd machinecoin-core && \
    git checkout ${VERSION} && \
    ./autogen.sh && \
    ./configure --enable-static && \
    make -j4

RUN cp /opt/machinecoin/machinecoin-core/src/machinecoin-cli /usr/local/bin && \
    cp /opt/machinecoin/machinecoin-core/src/machinecoin-tx /usr/local/bin && \
    cp /opt/machinecoin/machinecoin-core/src/machinecoind /usr/local/bin

CMD [ "machinecoind" ]