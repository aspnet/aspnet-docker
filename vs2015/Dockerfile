FROM microsoft/aspnet
RUN apt-get -qq update
RUN apt-get -qqy install git python
WORKDIR /tmp
RUN curl -O http://nodejs.org/dist/v0.10.35/node-v0.10.35.tar.gz
RUN tar xvfz node-v0.10.35.tar.gz
WORKDIR /tmp/node-v0.10.35
RUN ./configure --prefix=/usr
RUN make
RUN make install
RUN npm install -g grunt-cli

