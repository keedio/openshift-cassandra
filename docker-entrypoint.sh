#!/bin/bash

mkdir -p /var/lib/cassandra/data
mkdir -p /var/lib/cassandra/commitlog
mkdir -p /var/lib/cassandra/saved_caches


# set the hostname in the cassandra configuration file
sed -i 's/${HOSTNAME}/'$HOSTNAME'/g' /opt/apache-cassandra/conf/cassandra.yaml


echo "Setting seeds to be ${SEEDS}"
sed -i 's/${SEEDS}/'$( hostname -I)'/g' /opt/apache-cassandra/conf/cassandra.yaml

# set the cluster name if set, default to "test_cluster" if not set
if [ -n "$CLUSTER_NAME" ]; then
    sed -i 's/${CLUSTER_NAME}/'$CLUSTER_NAME'/g' /opt/apache-cassandra/conf/cassandra.yaml
else
    sed -i 's/${CLUSTER_NAME}/test_cluster/g' /opt/apache-cassandra/conf/cassandra.yaml
fi


if [ -n "$CASSANDRA_HOME" ]; then
  # remove -R once CASSANDRA-12641 is fixed
  exec ${CASSANDRA_HOME}/bin/cassandra -f 
else
  # remove -R once CASSANDRA-12641 is fixed
  exec /opt/apache-cassandra/bin/cassandra -f 
fi
