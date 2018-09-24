FROM openjdk:8-jdk-alpine
COPY target/rideshare-zuul.jar /opt/lib/
#RUN mkdir /var/lib/config-repo
#COPY config-repo /var/lib/config-repo
ENTRYPOINT ["/usr/bin/java"]
CMD ["-jar", "/opt/lib/rideshare-zuul.jar"]
#VOLUME /var/lib/config-repo
#EXPOSE 9090