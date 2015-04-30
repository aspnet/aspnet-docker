FROM coreclr-1.0.0-beta5-11624:latest

EXPOSE 5004
# Download the PartsUnlimited demo application
RUN curl -sSL https://dotnet2015.blob.core.windows.net/binaries/PartsUnlimited-demo-app-linux.tar.gz | tar zxfv - -C /opt --exclude=.dnx*

# Uncomment the next line to run the PartsUnlimited app
#CMD ["/bin/bash","/opt/demo/Kestrel"]
