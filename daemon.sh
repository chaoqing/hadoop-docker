#!/bin/bash
if [ $# -eq 0 ]; then
	echo daemon.sh "[create|init|start|test|stop|restart|destroy]"
	exit
fi

if [ $1 = create ]; then
#[创建容器]
docker-compose up -d
fi

if [ $1 = init ]; then
#[格式化HDFS。第一次启动集群前，需要先格式化HDFS；以后每次启动集群时，都不需要再次格式化HDFS]
docker-compose exec spark-master hdfs namenode -format
#[初始化Hive数据库。仅在第一次启动集群前执行一次]
docker-compose exec spark-master schematool -dbType mysql -initSchema
#[将Spark相关的jar文件打包，存储在/code目录下，命名为spark-libs.jar]
docker-compose exec spark-master jar cv0f /code/spark-libs.jar -C /root/spark/jars/ .
#[启动HDFS]
docker-compose exec spark-master start-dfs.sh
#[在HDFS中创建/user/spark/share/lib/目录]
docker-compose exec spark-master hadoop fs -mkdir -p /user/spark/share/lib/
#[将/code/spark-libs.jar文件上传至HDFS下的/user/spark/share/lib/目录下]
docker-compose exec spark-master hadoop fs -put /code/spark-libs.jar /user/spark/share/lib/
#[关闭HDFS]
docker-compose exec spark-master stop-dfs.sh
fi

# =========================== Start =========================== 
if [ $1 = start ]; then
docker-compose start
#[启动HDFS]
docker-compose exec spark-master start-dfs.sh
#[启动YARN]
docker-compose exec spark-master start-yarn.sh
#[启动Spark]
docker-compose exec spark-master start-all.sh

#echo networks:
#docker network inspect hadoopdocker_spark | \
	#awk -F: '/(Name|IPv4)/{print $2}'
fi

if [ $1 = test ]; then
#docker-compose exec spark-master /root/spark/bin/spark-shell --master yarn --driver-memory 1g --executor-memory 1g --executor-cores 1

# Run a test on another unrelated running container ds, remember to add it to spark network first
docker network inspect hadoopdocker_spark | grep -q '"Name": "ds"'
if [ $? -ne 0 ] ; then
docker network connect hadoopdocker_spark ds
docker network disconnect bridge ds
fi

docker exec -e JAVA_HOME=/opt/jdk1.8 ds \
	/opt/spark/spark-2.1.0-bin-hadoop2.7/bin/spark-submit \
	--class org.apache.spark.examples.SparkPi \
	--master spark://spark-master:7077 \
	--executor-memory 1G \
	--driver-memory 1G \
	--total-executor-cores 4 \
	/opt/spark/spark-2.1.0-bin-hadoop2.7/examples/jars/spark-examples_2.11-2.1.0.jar \
	5

#sqoop import-all-tables --connect jdbc:oracle:thin:@//HOST:PORT/SERVICE --username $USERNAME --password $PASSWD -m 1 --target-dir /user/spark --as-parquetfile
#sqoop import --connect jdbc:oracle:thin:@//HOST:PORT/SERVICE --username $USERNAME --password $PASSWD -m 1 --table TABLE_NAME --target-dir /user/spark --as-parquetfile
fi


# =========================== Stop =========================== 
if [ $1 = stop ]; then
#[停止Spark]
docker-compose exec spark-master stop-all.sh
#[停止YARN]
docker-compose exec spark-master stop-yarn.sh
#[停止HDFS]
docker-compose exec spark-master stop-dfs.sh
docker-compose stop
fi

if [ $1 = restart ]; then
#[重启容器]
$0 stop
$0 start
fi

if [ $1 = destroy ]; then
#[停止容器]
docker-compose down
fi
