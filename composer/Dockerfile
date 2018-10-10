FROM hyperledger/composer-rest-server:0.19.13

RUN  npm config set registry https://registry.cnpmjs.org/

RUN npm install --production -g loopback-connector-mongodb passport-openid passport-openidconnect && \
    npm cache clean --force && \
    ln -s node_modules .node_modules
