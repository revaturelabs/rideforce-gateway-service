FROM openjdk:8-jdk-alpine
COPY target/rideforce-zuul.jar /opt/lib/
ENTRYPOINT ["/usr/bin/java"]
EXPOSE 2222
CMD ["-jar", "/opt/lib/rideforce-zuul.jar"]
