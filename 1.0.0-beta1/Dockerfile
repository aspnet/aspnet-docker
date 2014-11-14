FROM mono:3.10

ENV KRE_VERSION 1.0.0-beta1

RUN apt-get -qq update && apt-get -qqy install unzip

RUN curl -s https://raw.githubusercontent.com/aspnet/Home/v$KRE_VERSION/kvminstall.sh | sh
RUN bash -c "source /root/.kre/kvm/kvm.sh \
	&& kvm install $KRE_VERSION -a default \
	&& kvm alias default | xargs -i ln -s /root/.kre/packages/{} /root/.kre/packages/default"

ENV PATH $PATH:/root/.kre/packages/default/bin