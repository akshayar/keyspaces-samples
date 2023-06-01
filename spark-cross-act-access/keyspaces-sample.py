import sys
from datetime import datetime
from pyspark.sql import SparkSession
from pyspark.sql.functions import *
if __name__ == "__main__":

    keyspace_name = sys.argv[1]
    table_name = sys.argv[2]
    s3_path = sys.argv[3] #"s3://akshaya-emr-on-eks/keyspaces_sample_table.csv"
    spark = SparkSession \
    .builder \
    .appName("SparkDelta") \
    .getOrCreate()
    ## Read Data First
    data = spark.read.format("org.apache.spark.sql.cassandra").options(table=table_name,keyspace=keyspace_name).load()
    data.show()
    ## Create a DataFrame
    data = spark.read.option("header","true").option("inferSchema","true").csv(s3_path)
    data.write.format("org.apache.spark.sql.cassandra").options(table=table_name,keyspace=keyspace_name).mode("APPEND").save()
    newData = spark.read.format("org.apache.spark.sql.cassandra").options(table=table_name,keyspace=keyspace_name).load()
    newData.show()
    spark.stop()
