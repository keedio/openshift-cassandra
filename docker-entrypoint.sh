#!/bin/bash
echo "Setting seeds to be $( hostname -I)/"

sed -i "s/%%host_ip%%/$(hostname -I)/g" /opt/apache-cassandra/conf/cassandra.yaml

export CLASSPATH=/kubernetes-cassandra.jar

if [ -n "$CLUSTER_NAME" ]; then
    sed -i 's/${CLUSTER_NAME}/'$CLUSTER_NAME'/g' /opt/apache-cassandra/conf/cassandra.yaml
else
    sed -i 's/${CLUSTER_NAME}/test_cluster/g' /opt/apache-cassandra/conf/cassandra.yaml
fi

if [ -n "$CASSANDRA_HOME" ]; then
  
  exec ${CASSANDRA_HOME}/bin/cassandra -f 
else

  exec /opt/apache-cassandra/bin/cassandra -f 
fi
