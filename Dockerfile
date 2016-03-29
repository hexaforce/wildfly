# wildfly-10.0.0.CR2 on java-1.8-openjdk
# docker run -it -p 8080:8080 -p 9990:9990 -p 9999:9999 -p 8787:8787 hexaforce/wildfly /bin/ash

FROM alpine:latest

ENV VERSION 10.0.0.CR2

# Java intall
RUN apk --no-cache add openjdk8 openrc

# WildFly intall
RUN mkdir /opt
ADD wildfly-$VERSION.tar.gz /opt

# Service add
COPY wildfly /etc/init.d/
RUN rc-update add wildfly default

# WildFly config
RUN /opt/wildfly-$VERSION/bin/add-user.sh admin Admin
RUN echo 'JAVA_OPTS="$JAVA_OPTS -agentlib:jdwp=transport=dt_socket,address=8787,server=y,suspend=n"' >> /opt/wildfly-$VERSION/bin/standalone.conf

EXPOSE 8080 9990 9999 8787

CMD ["service", "wildfly", "start"]
