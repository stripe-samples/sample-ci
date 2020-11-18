FROM node:14.15

ARG sample

RUN mkdir -p /work/server/node-typescript
WORKDIR /work/server/node-typescript

COPY ${sample}/server/node-typescript/package* /work/server/node-typescript/
RUN npm install -q

COPY ${sample}/client /work/client
COPY ${sample}/server/node-typescript /work/server/node-typescript
