#!/bin/bash


sleep 5

my_ip=$(hostname --ip-address)

CASSANDRA_SEEDS=$(host $PEER_DISCOVERY_SERVICE | \
    grep -v "not found" | \
    grep -v "connection timed out" | \
    sort | \
    head -3 | \
    awk '{print $4}' | \
    xargs)

echo "$CASSANDRA_SEEDS" 
set -- "$CASSANDRA_SEEDS "   
IFS=" "; declare -a Array=($*) 
echo "${Array[0]}" 

sed -i 's/${SEEDS}/'$CASSANDRA_SEEDS'/g' /opt/apache-cassandra/conf/cassandra.yaml



mkdir -p /var/lib/cassandra/data
mkdir -p /var/lib/cassandra/commitlog
mkdir -p /var/lib/cassandra/saved_caches


# set the hostname in the cassandra configuration file
sed -i 's/${HOSTNAME}/'$HOSTNAME'/g' /opt/apache-cassandra/conf/cassandra.yaml

# set the cluster name if set, default to "test_cluster" if not set
if [ -n "$CLUSTER_NAME" ]; then
    sed -i 's/${CLUSTER_NAME}/'$CLUSTER_NAME'/g' /opt/apache-cassandra/conf/cassandra.yaml
else
    sed -i 's/${CLUSTER_NAME}/test_cluster/g' /opt/apache-cassandra/conf/cassandra.yaml
fi

cat /opt/apache-cassandra/conf/cassandra.yaml

if [ -n "$CASSANDRA_HOME" ]; then
  # remove -R once CASSANDRA-12641 is fixed
  exec ${CASSANDRA_HOME}/bin/cassandra -f -R
else
  # remove -R once CASSANDRA-12641 is fixed
  exec /opt/apache-cassandra/bin/cassandra -f -R
fi
