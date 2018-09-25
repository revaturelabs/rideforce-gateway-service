FROM openjdk:8-jdk-alpine
COPY target/rideshare-zuul.jar /opt/lib/
ENTRYPOINT ["/usr/bin/java"]
CMD ["-jar", "/opt/lib/rideshare-zuul.jar"]