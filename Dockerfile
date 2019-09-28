FROM amazonlinux:latest

RUN yum -y update \
 && yum -y install which unzip aws-cli jq tar gzip shadow-utils \
 && yum clean all

RUN adduser aws-nuke

ENV AWSNUKE_VERSION=2.11.0
ADD https://github.com/rebuy-de/aws-nuke/releases/download/v${AWSNUKE_VERSION}/aws-nuke-v${AWSNUKE_VERSION}-linux-amd64.tar.gz .
RUN tar xzf aws-nuke-v${AWSNUKE_VERSION}-linux-amd64.tar.gz && \
    mv dist/aws-nuke-v${AWSNUKE_VERSION}-linux-amd64 /usr/local/bin/aws-nuke && \
    rm -rf dist aws-nuke-v${AWSNUKE_VERSION}-linux-amd64.tar.gz && \
    chmod 755 /usr/local/bin/aws-nuke

ADD docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod 755 /usr/local/bin/docker-entrypoint.sh
RUN chown aws-nuke: /usr/local/bin/docker-entrypoint.sh

USER aws-nuke
WORKDIR /home/aws-nuke

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
