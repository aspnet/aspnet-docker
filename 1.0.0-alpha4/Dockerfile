FROM mono:3.10

ENV KRE_VERSION 1.0.0-alpha4

RUN apt-get -qq update && apt-get -qqy install unzip

RUN curl -s https://raw.githubusercontent.com/aspnet/Home/v$KRE_VERSION/kvminstall.sh | sh
RUN bash -c "source /root/.kre/kvm/kvm.sh \
	&& kvm install $KRE_VERSION -a default \
	&& kvm alias default | xargs -i ln -s /root/.kre/packages/{} /root/.kre/packages/default"

# Install libuv for Kestrel from source code (binary is not in wheezy and one in jessie is still too old)
RUN apt-get -qqy install autoconf automake build-essential libtool
RUN LIBUV_VERSION=1.0.0-rc2 \
	&& curl -sSL https://github.com/joyent/libuv/archive/v${LIBUV_VERSION}.tar.gz | tar zxfv - -C /usr/local/src \
	&& cd /usr/local/src/libuv-$LIBUV_VERSION \
	&& sh autogen.sh && ./configure && make && make install \
	&& rm -rf /usr/local/src/libuv-$LIBUV_VERSION \
	&& ldconfig

ENV PATH $PATH:/root/.kre/packages/default/bin
