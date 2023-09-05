FROM eclipse-temurin:20-jdk-jammy as base
LABEL authors="vine"

WORKDIR /app

COPY .mvn/ .mvn
COPY mvnw pom.xml ./

RUN ./mvnw dependency:resolve

COPY src ./src

FROM base as test
CMD ["./mvnw", "test"]

FROM base as development
CMD ["./mvnw", "spring-boot:run", "-Dspring-boot.run.profiles=postgresql", "-Dspring-boot.run.jvmArguments='-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:8000'"]

FROM base as build
RUN ./mvnw package

FROM eclipse-temurin:20-jre-jammy as production
EXPOSE 8080
COPY --from=build /app/target/trading-platform-*.jar /trading-platform.jar
CMD ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "/trading-platform.jar"]