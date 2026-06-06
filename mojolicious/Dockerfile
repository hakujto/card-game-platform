FROM perl:5.40-slim

RUN apt-get update -qq && apt-get install -y libsqlite3-dev && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY cpanfile .
RUN cpanm --notest --installdeps .

COPY . .
RUN perl script/cards_project eval "CardsProject::Schema->connect('dbi:SQLite:data.db')->deploy"

EXPOSE 3000
CMD ["perl", "script/cards_project", "daemon", "-l", "http://*:3000"]
