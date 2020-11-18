FROM maven:3.6

ARG sample

RUN mkdir -p /work/server/java
WORKDIR /work/server/java

COPY ${sample}/server/java /work/server/java
RUN mvn package -q

COPY ${sample}/client /work/client
