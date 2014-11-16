FROM microsoft/aspnet:1.0.0-beta1

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

ONBUILD ADD . /usr/src/app/
ONBUILD RUN kpm restore
