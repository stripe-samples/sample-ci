FROM mcr.microsoft.com/dotnet/core/sdk:3.1

ARG sample

RUN mkdir -p /work/server/dotnet
WORKDIR /work/server/dotnet

COPY ${sample}/server/dotnet /work/server/dotnet
COPY ${sample}/client /work/client
