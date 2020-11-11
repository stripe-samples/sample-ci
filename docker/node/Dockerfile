FROM node:14.15

ARG sample

RUN mkdir -p /work/server/node
WORKDIR /work/server/node

COPY ${sample}/server/node/package* /work/server/node/
RUN npm install -q

COPY ${sample}/client /work/client
COPY ${sample}/server/node /work/server/node
