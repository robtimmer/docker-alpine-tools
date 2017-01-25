# Use base image, tag 3.4
FROM robtimmer/alpine-base:3.4

# Set maintainer
MAINTAINER Rob Timmer <rob@robtimmer.com>

# Set service environment variables
ENV SERVICE_VOLUME=/opt/tools \
    SERVICE_ARCHIVE=/opt/tools.tgz \
    KEEP_ALIVE=0

# Compile and install monit + confd
ENV CONFD_VERSION=v0.11.0 \
    CONFD_HOME=${SERVICE_VOLUME}/confd \
    GOMAXPROCS=2 \
    GOROOT=/usr/lib/go \
    GOPATH=/opt/src \
    GOBIN=/gopath/bin \
    PATH=$PATH:${SERVICE_VOLUME}/confd/bin:${SERVICE_VOLUME}/scripts \
    JQ_URL=https://github.com/stedolan/jq/releases/download \
    JQ_VERSION=1.5

RUN apk add --update go git gcc musl-dev make openssl-dev && \
    mkdir -p /opt/src; cd /opt/src && \
    mkdir -p ${SERVICE_VOLUME}/monit/conf.d ${SERVICE_VOLUME}/scripts ${CONFD_HOME}/etc/templates ${CONFD_HOME}/etc/conf.d ${CONFD_HOME}/bin ${CONFD_HOME}/log && \
    git clone -b "$CONFD_VERSION" https://github.com/kelseyhightower/confd.git && \
    cd $GOPATH/confd/src/github.com/kelseyhightower/confd && \
    GOPATH=$GOPATH/confd/vendor:$GOPATH/confd CGO_ENABLED=0 go build -v -installsuffix cgo -ldflags '-extld ld -extldflags -static' -a -x . && \
    mv ./confd ${CONFD_HOME}/bin/ && \
    chmod +x ${CONFD_HOME}/bin/confd && \
    curl -L $JQ_URL/jq-${JQ_VERSION}/jq-linux64 -o ${SERVICE_VOLUME}/scripts/jq && \
    chmod 755 ${SERVICE_VOLUME}/scripts/jq && \
    cd ${SERVICE_VOLUME} && \
    tar czvf ${SERVICE_ARCHIVE} * && \
    apk del go git gcc musl-dev make openssl-dev && \
    rm -rf /var/cache/apk/* /opt/src ${SERVICE_VOLUME}/* 

# Add root files to the image root
ADD root /

# Set working directory
WORKDIR "${SERVICE_VOLUME}"

# Set entrypoint
ENTRYPOINT ["bash","/start.sh"]
