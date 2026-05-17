FROM ruby:3.3-slim

RUN apt-get update -qq && apt-get install -y build-essential libsqlite3-dev

WORKDIR /app
COPY Gemfile Gemfile.lock* ./
RUN bundle install

COPY . .
RUN bundle exec rails db:create db:migrate

EXPOSE 3000
CMD ["bin/rails", "server", "-b", "0.0.0.0"]
