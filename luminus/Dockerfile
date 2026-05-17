FROM clojure:temurin-21-tools-deps AS build

WORKDIR /app
COPY deps.edn build.clj ./
RUN clojure -P

COPY . .
RUN clojure -T:build uber

FROM eclipse-temurin:21-jre-alpine
RUN apk add --no-cache sqlite
WORKDIR /app
COPY --from=build /app/target/cards-project.jar app.jar
EXPOSE 3000
CMD ["java", "-jar", "app.jar"]
