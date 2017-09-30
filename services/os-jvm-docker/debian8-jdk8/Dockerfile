FROM debian:8

MAINTAINER nick <chaoqingwang@foxmail.com>

USER root

ENV JAVA_HOME=/usr/lib/jdk8

ENV PATH=$PATH:$JAVA_HOME/bin:.

# 安装 wget,rsync
# 设置系统时区为北京时间（实际为Asia/Shanghai）

RUN apt update && apt install -y wget rsync\
    && wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u141-b13/jdk-8u141-linux-x64.tar.gz \
    && tar -xzvf jdk-8u141-linux-x64.tar.gz -C /usr/lib/ \
    && mv /usr/lib/jdk1.8.0_141 $JAVA_HOME \
    && rm -rf /var/lib/apt/lists/* jdk-8u141-linux-x64.tar.gz $JAVA_HOME/src.zip $JAVA_HOME/javafx-src.zip $JAVA_HOME/man \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

CMD ["/bin/bash"]
