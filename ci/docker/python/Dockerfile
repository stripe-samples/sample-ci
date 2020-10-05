FROM python:3

ARG sample

ENV FLASK_APP=server.py FLASK_ENV=development

RUN mkdir -p /work/server/python
WORKDIR /work/server/python

COPY ${sample}/server/python/requirements.txt /work/server/python/
RUN pip install -r requirements.txt -q

COPY ${sample}/client /work/client
COPY ${sample}/server/python /work/server/python
