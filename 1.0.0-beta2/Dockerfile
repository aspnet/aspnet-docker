FROM mono:3.10

ENV KRE_VERSION 1.0.0-beta2
ENV KRE_USER_HOME /opt/kre

RUN apt-get -qq update && apt-get -qqy --no-install-recommends install \
	git \
	unzip

# Install Node.js and Grunt
RUN curl -sL https://deb.nodesource.com/setup | bash - \
	&& apt-get install -qqy nodejs \
	&& npm install -g grunt-cli

RUN curl -sSL https://raw.githubusercontent.com/aspnet/Home/v$KRE_VERSION/kvminstall.sh | sh
RUN bash -c "source $KRE_USER_HOME/kvm/kvm.sh \
	&& kvm install $KRE_VERSION -a default \
	&& kvm alias default | xargs -i ln -s $KRE_USER_HOME/packages/{} $KRE_USER_HOME/packages/default"

# Install libuv for Kestrel from source code (binary is not in wheezy and one in jessie is still too old)
RUN apt-get -qqy install \
	autoconf \
	automake \
	build-essential \
	libtool
RUN LIBUV_VERSION=1.0.0-rc2 \
	&& curl -sSL https://github.com/joyent/libuv/archive/v${LIBUV_VERSION}.tar.gz | tar zxfv - -C /usr/local/src \
	&& cd /usr/local/src/libuv-$LIBUV_VERSION \
	&& sh autogen.sh && ./configure && make && make install \
	&& rm -rf /usr/local/src/libuv-$LIBUV_VERSION \
	&& ldconfig

ENV PATH $PATH:$KRE_USER_HOME/packages/default/bin
