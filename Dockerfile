# WildFly 10.0.0.Final on OpenJDK 1.8
# docker run -it hexaforce/wildfly

FROM alpine:3.3

ENV WILDFLY wildfly-10.0.0.Final
ENV JBOSS_HOME /opt/wildfly

RUN apk --no-cache add openjdk8-jre \
    && wget http://download.jboss.org/wildfly/10.0.0.Final/$WILDFLY.zip \
    && unzip $WILDFLY.zip \
    && rm $WILDFLY.zip \
    && mkdir /opt \
    && mv $WILDFLY/ $JBOSS_HOME
    
EXPOSE 8080 9999 9990

ENV LAUNCH_JBOSS_IN_BACKGROUND 1

CMD ash $JBOSS_HOME/bin/standalone.sh -b 0.0.0.0 &
