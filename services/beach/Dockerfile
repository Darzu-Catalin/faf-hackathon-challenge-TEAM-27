# syntax=docker/dockerfile:1
# Beach — Kotlin + Ktor + Exposed + Postgres.
# Build with the gradle image (NOT ./gradlew — gradle-wrapper.jar is missing from the repo).
FROM gradle:8.7-jdk21 AS build
WORKDIR /home/gradle/src
COPY --chown=gradle:gradle . .
RUN gradle --no-daemon clean buildFatJar

FROM eclipse-temurin:21-jre
WORKDIR /app
# rootProject.name = "beach" -> Ktor buildFatJar produces beach-all.jar
COPY --from=build /home/gradle/src/build/libs/beach-all.jar /app/beach.jar
ENV APP_PORT=8080
EXPOSE 8080
# Beach currently has NO /health route (see TICKETS BCH-HEALTH) — TCP-probe the port instead.
HEALTHCHECK --interval=15s --timeout=4s --start-period=30s --retries=5 \
  CMD bash -c 'exec 3<>/dev/tcp/localhost/${APP_PORT}' || exit 1
ENTRYPOINT ["java", "-jar", "/app/beach.jar"]
