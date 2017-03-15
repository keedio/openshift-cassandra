#!/bin/bash

for args in "$@"
do
  case $args in
    --seeds=*)
      SEEDS="${args#*=}"
    ;;
    --cluster_name=*)
      CLUSTER_NAME="${args#*=}"
    ;;
    --data_volume=*)
      DATA_VOLUME="${args#*=}"
    ;;
    --commitlog_volume=*)
      COMMITLOG_VOLUME="${args#*=}"
    ;;
    --seed_provider_classname=*)
      SEED_PROVIDER_CLASSNAME="${args#*=}"
    ;;
    --help)
      HELP=true
    ;;
  esac
done

if [ -n "$HELP" ]; then
  echo
  echo Starts up a Cassandra Docker image
  echo
  echo Usage: [OPTIONS]...
  echo
  echo Options:
  echo "  --seeds=SEEDS"
  echo "        comma separated list of hosts to use as a seed list"
  echo "        default: \$HOSTNAME"
  echo
  echo "  --cluster_name=NAME"
  echo "        the name to use for the cluster"
  echo "        default: test_cluster"
  echo
  echo "  --data_volume=VOLUME_PATH"
  echo "        the path to where the data volume should be located"
  echo "        default: \$CASSANDRA_HOME/data"
  echo
  echo "  --seed_provider_classname"
  echo "        the classname to use as the seed provider"
  echo "        default: org.apache.cassandra.locator.SimpleSeedProvider"
  echo
  echo
  exit 0
fi

# set the hostname in the cassandra configuration file
sed -i 's/${HOSTNAME}/'$HOSTNAME'/g' /opt/apache-cassandra/conf/cassandra.yaml


echo "Setting seeds to be ${SEEDS}"
sed -i 's/${SEEDS}/'${SEEDS}'/g' /opt/apache-cassandra/conf/cassandra.yaml

# set the cluster name if set, default to "test_cluster" if not set
if [ -n "$CLUSTER_NAME" ]; then
    sed -i 's/${CLUSTER_NAME}/'$CLUSTER_NAME'/g' /opt/apache-cassandra/conf/cassandra.yaml
else
    sed -i 's/${CLUSTER_NAME}/test_cluster/g' /opt/apache-cassandra/conf/cassandra.yaml
fi

# set the commitlog volume if set, otherwise use the DATA_VOLUME value instead
if [ -n "$COMMITLOG_VOLUME" ]; then
  sed -i 's#${COMMITLOG_VOLUME}#'$COMMITLOG_VOLUME'#g' /opt/apache-cassandra/conf/cassandra.yaml
else
  sed -i 's#${COMMITLOG_VOLUME}#'$DATA_VOLUME'#g' /opt/apache-cassandra/conf/cassandra.yaml
fi

# set the seed provider class name, otherwise default to the SimpleSeedProvider
if [ -n "$SEED_PROVIDER_CLASSNAME" ]; then
    sed -i 's#${SEED_PROVIDER_CLASSNAME}#'$SEED_PROVIDER_CLASSNAME'#g' /opt/apache-cassandra/conf/cassandra.yaml
else
    sed -i 's#${SEED_PROVIDER_CLASSNAME}#org.apache.cassandra.locator.SimpleSeedProvider#g' /opt/apache-cassandra/conf/cassandra.yaml
fi

# create the cqlshrc file so that cqlsh can be used much more easily from the system
mkdir -p $HOME/.cassandra
cat >> $HOME/.cassandra/cqlshrc << DONE
[connection]
hostname= $HOSTNAME
factory = cqlshlib.ssl.ssl_transport_factory
port = 9042
DONE

if [ -n "$CASSANDRA_HOME" ]; then
  # remove -R once CASSANDRA-12641 is fixed
  exec ${CASSANDRA_HOME}/bin/cassandra -f 
else
  # remove -R once CASSANDRA-12641 is fixed
  exec /opt/apache-cassandra/bin/cassandra -f 
fi
