FROM maven:3-alpine

COPY pom.xml pipelines/

COPY src/ pipelines/src/

WORKDIR pipelines/

RUN mvn clean install

EXPOSE 8090

ENTRYPOINT [ "java", "-jar", "/pipelines/target/openshift-pipelines.jar"]