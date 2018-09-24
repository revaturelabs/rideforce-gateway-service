FROM openjdk:8-jdk-alpine
VOLUME /tmp
ADD rideshare-zuul.jar app.jar
RUN bash -c 'touch /app.jar'
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"]
