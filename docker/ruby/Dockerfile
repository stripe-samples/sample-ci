FROM ruby:2.7

ARG sample

RUN mkdir -p /work/server/ruby
WORKDIR /work/server/ruby

COPY ${sample}/server/ruby/Gemfile /work/server/ruby/
RUN bundle install -j4 --quiet

COPY ${sample}/client /work/client
COPY ${sample}/server/ruby /work/server/ruby
