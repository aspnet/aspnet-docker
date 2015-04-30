FROM ubuntu:14.04

ENV DNX_FEED https://www.myget.org/F/aspnetvnext/api/v2

RUN apt-get update -qq \
    && apt-get install -qqy libunwind8 libssl-dev curl unzip libtool automake build-essential

# Install libuv for Kestrel from source code (binary is not in wheezy and one in jessie is still too old)
RUN LIBUV_VERSION=1.4.2 \
    && curl -sSL https://github.com/libuv/libuv/archive/v${LIBUV_VERSION}.tar.gz | tar zxfv - -C /usr/local/src \
    && cd /usr/local/src/libuv-$LIBUV_VERSION \
    && sh autogen.sh && ./configure && make && make install \
    && rm -rf /usr/local/src/libuv-$LIBUV_VERSION \
    && ldconfig

RUN curl -sSL https://raw.githubusercontent.com/aspnet/Home/dev/dnvminstall.sh | DNX_BRANCH=dev sh \
    && bash -c "source $HOME/.dnx/dnvm/dnvm.sh \
       && dnvm install 1.0.0-beta5-11624 -r coreclr -arch x64 -a default \
       && ln -s $HOME/.dnx/runtimes/dnx-coreclr-linux-x64.1.0.0-beta5-11624 $HOME/.dnx/runtimes/default"

ENV PATH $PATH:/root/.dnx/runtimes/default/bin
