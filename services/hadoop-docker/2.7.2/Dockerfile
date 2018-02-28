FROM twinsen/os-jvm:centos6-openjdk8

MAINTAINER twinsen <ruoyu-chen@foxmail.com>

USER root

ENV HADOOP_HOME=/root/hadoop
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV SQOOP_HOME=/root/sqoop
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HADOOP_HOME/lib/native/:/root/protobuf/lib
ENV PATH=$PATH:/root/protobuf/bin:$SQOOP_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:.

# 1. 安装 OpenSSH, OpenSSL, bzip2-devel
# 2. 同时配置SSH免密钥登陆
RUN yum install -y openssh openssh-server openssh-clients openssl openssl-devel bzip2-devel && \
    yum clean all && \
    ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
    
ADD config/other/ssh_config /root/.ssh/config
RUN chmod 600 /root/.ssh/config && \
    chown root:root /root/.ssh/config

#安装Protocol Buffer, Hadoop
RUN wget https://github.com/ruoyu-chen/hadoop-docker/raw/master/dist/hadoop-2.7.2.tar.gz && \
	tar -xzvf hadoop-2.7.2.tar.gz -C /root/ && \
    mv /root/hadoop-2.7.2 $HADOOP_HOME && \
    rm -rf hadoop-2.7.2.tar.gz && \
    rm -rf $HADOOP_HOME/bin/*.cmd && \
    rm -rf $HADOOP_HOME/sbin/*.cmd && \
    rm -rf $HADOOP_HOME/sbin/*all* && \
    rm -rf $HADOOP_CONF_DIR/*.cmd && \
    rm -rf $HADOOP_CONF_DIR/*.template && \
    rm -rf $HADOOP_CONF_DIR/*.example && \
    wget https://github.com/ruoyu-chen/hadoop-docker/raw/master/dist/protobuf.tar.gz && \
	tar -xzvf protobuf.tar.gz -C /root/ && \
	rm -rf protobuf.tar.gz	&& \

    mkdir $SQOOP_HOME && wget -qO- https://mirrors.tuna.tsinghua.edu.cn/apache/sqoop/1.4.7/sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz | \
    tar -xzv -C $SQOOP_HOME --strip-components=1 && ln $SQOOP_HOME/sqoop-1.4.7.jar $HADOOP_HOME/share/hadoop/mapreduce/ && \
    wget -qO- https://gist.githubusercontent.com/anonymous/8cff07bb657997b5bf93f0a5297be3ea/raw/bed24dce4d4de0dd1d335a1cea23265ce1e2cbc9/ojdbc8.jar |base64 -d > $SQOOP_HOME/lib/ojdbc8.jar
    

#拷贝环境变量配置文件
ADD config/other/bashrc /root/.bashrc

#拷贝Hadoop配置文件
ADD config/hadoop/* $HADOOP_HOME/etc/hadoop/

#建立HDFS目录，日志目录. 格式化NameNode
#RUN mkdir -p /works/hadoop/dfs/name && \ 
#    mkdir -p /works/hadoop/dfs/data && \
#    mkdir -p /works/hadoop/dfs/namesecondary && \
#    mkdir $HADOOP_HOME/logs && \
#    $HADOOP_HOME/bin/hdfs namenode -format

CMD [ "sh", "-c", "service sshd start; bash"]
