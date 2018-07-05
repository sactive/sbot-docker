FROM opensuse-base:42.3

ENV NODE_VERSION=v8.11.3 \
    YARN_VERSION=v1.7.0

ENV NODE_ENV=production \
    NODE_BIN_URL=https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-linux-x64.tar.gz \
    NODE_INSTALL_DIR=/usr/local/node \
    YARN_BIN_URL=https://github.com/yarnpkg/yarn/releases/download/${YARN_VERSION}/yarn-${YARN_VERSION}.tar.gz \
    YARN_INSTALL_DIR=/opt/yarn

RUN zypper -n ref && \
    zypper -n install \
        ca-certificates \
        bash \
        curl \
        tar && \
    zypper clean && \
    rm -rf /var/cache/zypp/* && \
    mkdir -p $NODE_INSTALL_DIR && \
    cd $NODE_INSTALL_DIR && \
    curl $NODE_BIN_URL | tar xz --strip=1 && \
    PATH=$PATH:$NODE_INSTALL_DIR/bin && \
    mkdir -p $YARN_INSTALL_DIR && \
    cd $YARN_INSTALL_DIR && \
    curl -L $YARN_BIN_URL | tar xz --strip=1 && \
    PATH=$PATH:$YARN_INSTALL_DIR/bin && \
    yarn global add coffee-script && \
    yarn cache clean && \
    npm cache clean --force && \
    zypper -n remove tar && \
    zypper clean

ENV PATH=$PATH:$NODE_INSTALL_DIR/bin:$YARN_INSTALL_DIR/bin

COPY . /opt/sbot/

RUN mkdir -p /etc/sbot/packages/ && \
    mkdir -p /etc/opt/sbot && \
    mkdir -p /var/opt/sbot/log && \
    chmod 555 /opt/startsbot.sh && \
    chmod 777 /etc/sbot/packages/ && \
    chmod 777 /etc/opt/sbot && \
    chmod 777 /var/opt/sbot/log && \
    chmod 777 /opt/sbot && \
    cd /opt/sbot && yarn install --production

ENTRYPOINT ["/opt/startsbot.sh"]

