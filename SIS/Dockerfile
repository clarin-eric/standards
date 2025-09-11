# Use Java 17 LTS
FROM eclipse-temurin:17-jdk-alpine

# Set working directory
WORKDIR /opt/basex

ENV HOME=/opt

# Install required utilities
RUN apk add --no-cache wget unzip bash

# Download BaseX
RUN wget -q https://files.basex.org/releases/BaseX-latest.zip \
    && unzip -q BaseX-latest.zip -d /opt/basex-temp \
    && mv /opt/basex-temp/basex/* /opt/basex/ \
    && rm -rf /opt/basex-temp BaseX-latest.zip

# Copy your custom files
COPY clarin /opt/basex/webapp/clarin
COPY WEB-INF/web.xml /opt/basex/webapp/WEB-INF/web.xml
COPY WEB-INF/jetty.xml /opt/basex/webapp/WEB-INF/jetty.xml

# Make server scripts executable
RUN chmod +x bin/*

# Create BaseX database "data" from clarin/data
RUN /opt/basex/bin/basex -c "CREATE DB data /opt/basex/webapp/clarin/data"

# Expose HTTP and database ports
EXPOSE 8040 1984

# Start the BaseX HTTP server (no options)
ENTRYPOINT ["/opt/basex/bin/basexhttp"]

# build with the following command at root-project/SIS/
# docker build -t basex-http-latest .

# how to run
# docker run --rm -it -p 8040:8040 -p 1984:1984 --name basex-http basex-http-latest
#
# with custom dns
# docker run --rm -it -p 8040:8040 --dns 8.8.8.8 --dns 8.8.4.4 --name basex-http basex-http-latest
