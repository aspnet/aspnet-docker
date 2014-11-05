FROM mono:3.10

# Update certificate store
RUN yes | certmgr -ssl -m \
	https://go.microsoft.com \
	https://myget.org \
	https://nuget.org
RUN mozroots --import --sync --quiet

# unzip required by kvminstall.sh
RUN apt-get -qq update && apt-get -qqy install unzip

# Install KRE upon image build to pull latest from master feed
RUN curl -s https://raw.githubusercontent.com/aspnet/Home/master/kvminstall.sh | sh
RUN bash -c "source /root/.kre/kvm/kvm.sh \
	&& kvm upgrade \
	&& kvm alias default | xargs -i ln -s /root/.kre/packages/{} /root/.kre/packages/default"
ENV PATH $PATH:/root/.kre/packages/default/bin