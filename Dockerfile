
FROM jboss/base-jdk:8

EXPOSE 9042 9160 7000 7001


ENV CASSANDRA_VERSION="3.0.10" \
    CASSANDRA_HOME="/opt/apache-cassandra" \
    HOME="/home/cassandra" \
    PATH="/opt/apache-cassandra/bin:$PATH" 


USER root
RUN groupadd -r cassandra  && useradd -r -g cassandra cassandra
RUN yum install -y -q bind-utils && \
   yum clean all

RUN cd /opt &&\
	curl -LO http://apache.uvigo.es/cassandra/$CASSANDRA_VERSION/apache-cassandra-$CASSANDRA_VERSION-bin.tar.gz && ls -l &&\ 
    tar xvzf apache-cassandra-$CASSANDRA_VERSION-bin.tar.gz && \
    rm apache-cassandra-$CASSANDRA_VERSION-bin.tar.gz && \
    ln -s apache-cassandra-$CASSANDRA_VERSION apache-cassandra

COPY cassandra.yaml.template \
     /opt/apache-cassandra/conf/

COPY cassandra-lucene-index-plugin-3.0.10.3.jar \
     /opt/apache-cassandra/lib/

COPY docker-entrypoint.sh \
     /opt/apache-cassandra/bin/

RUN  mkdir -p /var/lib/cassandra $HOME \
	&& chown -R cassandra:cassandra /var/lib/cassandra $HOME \
	&& chmod 777 /var/lib/cassandra "$HOME" && chmod +x /opt/apache-cassandra/bin/docker-entrypoint.sh

VOLUME /var/lib/cassandra
