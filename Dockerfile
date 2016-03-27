# WildFly 10.0.0.Final on OpenJDK 1.8
# docker run -it hexaforce/wildfly

FROM alpine:latest

ENV WILDFLY wildfly-10.0.0.Final
ENV WILDFLY_HOME /opt/wildfly

RUN apk --no-cache add openjdk8-jre curl \
    && wget http://download.jboss.org/wildfly/10.0.0.Final/$WILDFLY.zip \
    && unzip $WILDFLY.zip \
    && rm $WILDFLY.zip \
    && mkdir /opt \
    && mv $WILDFLY/ $WILDFLY_HOME \
    && curl -L -o /etc/init.d/wildfly https://raw.githubusercontent.com/hexaforce/wildfly/master/wildfly_init_alpine.sh \
    && chmod 755 /etc/init.d/wildfly \
    && $WILDFLY_HOME/bin/add-user.sh -a wildfly wildfly
EXPOSE 8080 9999 9990
CMD ["service" , "wildfly" , "start"]
