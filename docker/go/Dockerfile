FROM golang

ARG sample

RUN mkdir -p /work/server/go
WORKDIR /work/server/go

COPY ${sample}/server/go /work/server/go
COPY ${sample}/client /work/client
