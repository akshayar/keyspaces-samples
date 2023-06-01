#!/bin/bash
TARGET_DIR=/home/hadoop
aws s3 cp s3://aksh-code-binaries/application-crossact.conf $TARGET_DIR/application-crossact.conf
aws s3 cp s3://aksh-code-binaries/cassandra_truststore.jks $TARGET_DIR/cassandra_truststore.jks
exit 0

