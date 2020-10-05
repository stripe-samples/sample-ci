FROM ruby:2.7.1

RUN mkdir /work
WORKDIR /work

COPY Gemfile /work/
RUN bundle install -j4 --quiet

COPY .rspec /work/
COPY spec /work/spec
