FROM sbtscala/scala-sbt:eclipse-temurin-21.0.4_7_1.10.6_3.3.4 AS builder
WORKDIR /app
COPY . .
RUN sbt dist

FROM eclipse-temurin:21-jre-jammy
WORKDIR /app
COPY --from=builder /app/target/universal/*.zip app.zip
RUN unzip app.zip && mv $(ls -d */ | head -1) dist
ENV PORT=9000
EXPOSE 9000
CMD ["./dist/bin/cards_project"]
