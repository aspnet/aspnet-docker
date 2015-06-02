FROM mono:4.0

ENV KRE_VERSION 1.0.0-beta3
ENV KVM_USER_HOME /opt/kre

RUN apt-get -qq update && apt-get -qqy install unzip

RUN curl -sSL https://raw.githubusercontent.com/aspnet/Home/release/kvminstall.sh | KRE_USER_HOME=$KVM_USER_HOME KVM_BRANCH=v$KRE_VERSION sh
RUN bash -c "source $KVM_USER_HOME/kvm/kvm.sh \
	&& kvm install $KRE_VERSION -a default \
	&& kvm alias default | xargs -i ln -s $KVM_USER_HOME/runtimes/{} $KVM_USER_HOME/runtimes/default"

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

ENV PATH $PATH:$KVM_USER_HOME/runtimes/default/bin
