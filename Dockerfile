FROM amazonlinux:latest
RUN yum -y install which unzip aws-cli jq tar gzip

ENV AWSNUKE_VERSION=2.10.0
ADD https://github.com/rebuy-de/aws-nuke/releases/download/v${AWSNUKE_VERSION}/aws-nuke-v${AWSNUKE_VERSION}-linux-amd64.tar.gz .
RUN tar xzf aws-nuke-v${AWSNUKE_VERSION}-linux-amd64.tar.gz && \
    mv aws-nuke-v${AWSNUKE_VERSION}-linux-amd64 /usr/local/bin/aws-nuke && \
    rm -rf aws-nuke-v${AWSNUKE_VERSION}-linux-amd64.tar.gz && \
    chmod 744 /usr/local/bin/aws-nuke

ADD docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod 744 /usr/local/bin/docker-entrypoint.sh
WORKDIR /tmp
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
