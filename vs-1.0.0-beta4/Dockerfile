FROM mono:3.12

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
    && rm mono -r

# Install aspnet 1.0.0-beta4
ENV DNX_FEED https://www.myget.org/F/aspnetmaster/api/v2
ENV DNX_USER_HOME /opt/dnx

RUN curl -sSL https://raw.githubusercontent.com/aspnet/Home/7d6f78ed7a59594ce7cdb54a026f09cb0cbecb2a/dnvminstall.sh | DNX_BRANCH=master sh
RUN bash -c "source $DNX_USER_HOME/dnvm/dnvm.sh \
	&& dnvm install 1.0.0-beta4 -a default \
	&& dnvm alias default | xargs -i ln -s $DNX_USER_HOME/runtimes/{} $DNX_USER_HOME/runtimes/default"

# Install libuv for Kestrel from source code (binary is not in wheezy and one in jessie is still too old)
RUN LIBUV_VERSION=1.4.2 \
	&& curl -sSL https://github.com/libuv/libuv/archive/v${LIBUV_VERSION}.tar.gz | tar zxfv - -C /usr/local/src \
	&& cd /usr/local/src/libuv-$LIBUV_VERSION \
	&& sh autogen.sh && ./configure && make && make install \
	&& rm -rf /usr/local/src/libuv-$LIBUV_VERSION \
	&& ldconfig

# Update NuGet feeds
RUN mkdir -p $HOME/.config/NuGet/
COPY NuGet.Config $HOME/.config/NuGet/

ENV PATH $PATH:$DNX_USER_HOME/runtimes/default/bin
