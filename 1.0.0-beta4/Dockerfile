FROM mono:4

# Get build dependencies, download/build/install mono 4.1.0
RUN apt-get update -qq \
    && apt-get install -qqy git autoconf libtool automake build-essential mono-devel gettext unzip \
    && git clone https://github.com/mono/mono.git \
    && cd mono \
    && git reset --hard 53dc56ee39a8e3b013231957aca4671b202c6410 \
    && ./autogen.sh --prefix="/usr/local" \
    && make \
    && make install \
    && cd .. \
    && rm -rf mono

ENV DNX_VERSION 1.0.0-beta4
ENV DNX_USER_HOME /opt/dnx

RUN curl -sSL https://raw.githubusercontent.com/aspnet/Home/dev/dnvminstall.sh | DNX_USER_HOME=$DNX_USER_HOME DNX_BRANCH=v$DNX_VERSION sh
RUN bash -c "source $DNX_USER_HOME/dnvm/dnvm.sh \
	&& dnvm install $DNX_VERSION -a default \
	&& dnvm alias default | xargs -i ln -s $DNX_USER_HOME/runtimes/{} $DNX_USER_HOME/runtimes/default"

# Install libuv for Kestrel from source code (binary is not in wheezy and one in jessie is still too old)
RUN apt-get -qqy install \
	autoconf \
	automake \
	build-essential \
	libtool
RUN LIBUV_VERSION=1.4.2 \
	&& curl -sSL https://github.com/libuv/libuv/archive/v${LIBUV_VERSION}.tar.gz | tar zxfv - -C /usr/local/src \
	&& cd /usr/local/src/libuv-$LIBUV_VERSION \
	&& sh autogen.sh && ./configure && make && make install \
	&& rm -rf /usr/local/src/libuv-$LIBUV_VERSION \
	&& ldconfig

ENV PATH $PATH:$DNX_USER_HOME/runtimes/default/bin
