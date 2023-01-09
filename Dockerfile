FROM adoptopenjdk/openjdk8:alpine-slim as base
EXPOSE 8080
USER k8s-pipeline

FROM base

ARG JAR_FILE=target/*.jar
RUN addgroup -S pipeline && adduser -S k8s-pipeline -G pipeline
COPY ${JAR_FILE} /home/k8s-pipeline/app.jar
ENTRYPOINT ["java","-jar","/home/k8s-pipeline/app.jar"]