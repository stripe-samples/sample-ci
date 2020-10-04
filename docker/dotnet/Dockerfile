FROM mcr.microsoft.com/dotnet/core/sdk

ARG sample

RUN mkdir -p /work/server/dotnet
WORKDIR /work/server/dotnet

COPY ${sample}/server/dotnet /work/server/dotnet
COPY ${sample}/client /work/client
