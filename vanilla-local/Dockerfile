##############################################
# vmangos单机版镜像
##############################################
FROM ubuntu:18.04
LABEL Author="pf_miles <miles.wy.1@gmail.com>"
##############################################
## 可选值：amd64、arm64, 分别对应x64和arm平台上构建(TODO 目前暂不具备直接构建m1 mac版镜像的能力)
ARG arch=amd64

## ubuntu源
COPY sources-amd64.list /tmp/sources-amd64.list
COPY sources-arm64.list /tmp/sources-arm64.list
RUN if [ "arm64" = "$arch" ] ; then cp /tmp/sources-arm64.list /etc/apt/sources.list ; else cp /tmp/sources-amd64.list /etc/apt/sources.list ; fi
RUN rm /tmp/sources-amd64.list; rm /tmp/sources-arm64.list

## 升级软件包，安装基础软件
RUN apt-get update -y
RUN DEBIAN_FRONTEND="noninteractive" apt-get upgrade -y

RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y sudo gosu vim less net-tools curl g++ libace-dev libtbb-dev git cmake libmysqlclient-dev openssl libssl-dev build-essential checkinstall zlib1g-dev iputils-ping telnet

RUN echo "ACE_ROOT=/usr/include/ace" >> /etc/environment
RUN echo "TBB_ROOT_DIR=/usr/include/tbb" >> /etc/environment

## 设置locale
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y language-pack-en
RUN echo "LANG=en_US.utf8\nLANGUAGE=en_US" >> /etc/environment && update-locale LANG="en_US.utf8" LANGUAGE="en_US"

## 设置时区
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' > /etc/timezone

## 创建admin用户
ARG ADMIN_PASSWORD=tooj7Looquef
RUN ADMIN_ENCRYPTED_PASSWORD=$(perl -e 'print crypt('"${ADMIN_PASSWORD}"', "gb"),"\n"') && useradd -m -d /home/admin -p ${ADMIN_ENCRYPTED_PASSWORD} admin
## 设置bash为admin用户的默认shell
RUN chsh -s /bin/bash admin

## 下载vmangos源码并安装
RUN mkdir -p /home/admin/vmangos && chown -R admin:admin /home/admin/vmangos && cd /home/admin/vmangos && git clone -b development https://github.com/vmangos/core

RUN mkdir -p /home/admin/vmangos/build && cd /home/admin/vmangos/build && cmake /home/admin/vmangos/core -DDEBUG=0 -DSUPPORTED_CLIENT_BUILD=5875 -DUSE_EXTRACTORS=0 -DCMAKE_INSTALL_PREFIX=/home/admin/vmangos && make -j4 && make install

RUN chown -R admin:admin /home/admin/vmangos
## 拷贝环境配置文件模板
## COPY src /root/src
## RUN chmod 755 /root/src/*.sh

## 拷贝配置文件到admin用户的home目录下
## RUN cd /root/src/config/ && sudo -u admin cp -R .[a-z]* [a-z]* /home/admin/

## docker容器暴露22端口
EXPOSE 22

## 相对固定的入口程序及参数
#ENTRYPOINT ["/bin/bash", "/root/src/startup.sh"]
## 可重载的参数列表，指定主进程命令等可定制参数
CMD ["/bin/bash"]