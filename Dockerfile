FROM gradle:9-jdk21 AS build
WORKDIR /home/gradle/app

# Copy Gradle configuration files first for better layer caching
COPY build.gradle.kts settings.gradle.kts gradle.properties ./
COPY gradle ./gradle

# Download dependencies with optimizations:
# --parallel: Build projects in parallel
# --build-cache: Use Gradle build cache
# --no-configuration-cache: Avoid configuration cache issues in Docker
# This step caches dependencies in a separate layer for faster rebuilds
RUN gradle dependencies --no-daemon --parallel --build-cache

# Copy source code
COPY src ./src

# Build the application with same optimizations
RUN gradle shadowJar --no-daemon --parallel --build-cache



FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /home/gradle/app/build/libs/*-all.jar /app/kotatsu-syncserver.jar
EXPOSE 8080
CMD ["java", "-jar", "/app/kotatsu-syncserver.jar"]
