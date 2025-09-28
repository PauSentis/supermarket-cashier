FROM ruby:3.4.6

WORKDIR /app

COPY Gemfile ./

RUN bundle install

COPY . .

CMD ["ruby", "cli.rb"]