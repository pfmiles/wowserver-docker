##############################################
# vmangos server端镜像，包含世界服务器和登录服务器;
# 两个服务器可在同一容器实例中启动，也可单独启动;
# 可分别配置logs、characters、mangos、realmd数据库
# 连接字符串;
# 可分别配置世界服务器和登录服务器的端口
##############################################
FROM ubuntu:18.04
LABEL Author="pf_miles <miles.wy.1@gmail.com>"
##############################################
## 可选值：amd64、arm64, 分别对应x64和arm平台上构建
ARG arch=amd64
## 是否在编译过程中自动下载解压DBC, Map, VMap and MMap文件
ARG USE_EXTRACTORS=0
## 数据库连接字符串默认值
ARG realmdDBStr="host.docker.internal;3306;root;root;realmd"
ARG mangosDBStr="host.docker.internal;3306;root;root;mangos"
ARG characterDBStr="host.docker.internal;3306;root;root;characters"
ARG logsDBStr="host.docker.internal;3306;root;root;logs"
## 世界服务器端口默认值
ARG mangosServerPort=8085
## 登录服务器端口默认值
ARG realmServerPort=3724
## 编译出的服务端对应的客户端版本
ARG SUPPORTED_CLIENT_BUILD=5875
## 资料片剧情进度:
## 1.2   = 0
## 1.3   = 1
## 1.4   = 2
## 1.5   = 3
## 1.6   = 4
## 1.7   = 5
## 1.8   = 6
## 1.9   = 7
## 1.10  = 8
## 1.11  = 9
## 1.12  = 10
ARG wowPatch=10
## 服务器类型
## 0 = NORMAL; 1 = PVP; 4 = NORMAL; 6 = RP; 8 = RPPVP
## 16 FFA_PVP (除休息区域外全域默认开启pvp)
ARG gameType=1
## 时区
ARG timeZoneOffset=8
## 登录界面消息
ARG motd="Welcome to World of Warcraft!"
## 启动何种类型的server, realmd/mangosd/all, 默认两个都启动
ARG serverType="all"

## ubuntu源
COPY sources-amd64.list /tmp/sources-amd64.list
COPY sources-arm64.list /tmp/sources-arm64.list
RUN if [ "arm64" = "$arch" ] ; then cp /tmp/sources-arm64.list /etc/apt/sources.list ; else cp /tmp/sources-amd64.list /etc/apt/sources.list ; fi
RUN rm /tmp/sources-amd64.list; rm /tmp/sources-arm64.list

## 升级软件包，安装基础软件
RUN apt-get update -y
RUN DEBIAN_FRONTEND="noninteractive" apt-get upgrade -y

RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y sudo gosu vim less net-tools curl g++ libace-dev libtbb-dev git cmake libmysqlclient-dev openssl libssl-dev build-essential checkinstall zlib1g-dev iputils-ping telnet unzip tmux

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
RUN mkdir -p /home/admin/vmangos && cd /home/admin/vmangos && git clone -b development https://github.com/vmangos/core
RUN mkdir -p /home/admin/vmangos/build && cd /home/admin/vmangos/build && cmake /home/admin/vmangos/core -DDEBUG=0 -DSUPPORTED_CLIENT_BUILD=${SUPPORTED_CLIENT_BUILD} -DUSE_EXTRACTORS=${USE_EXTRACTORS} -DCMAKE_INSTALL_PREFIX=/home/admin/vmangos
RUN cd /home/admin/vmangos/build && make -j 4 && make install

## 若没有在编译过程中自动准备data, 则专门拷贝一份
COPY data.zip /tmp/data.zip
RUN if [ "0" = "$USE_EXTRACTORS" ] ; then unzip -d /home/admin/vmangos /tmp/data.zip && mv /home/admin/vmangos/data/dbc /home/admin/vmangos/data/${SUPPORTED_CLIENT_BUILD}/ ; fi
RUN rm /tmp/data.zip

## 准备配置文件
RUN cp /home/admin/vmangos/etc/mangosd.conf.dist /home/admin/vmangos/etc/mangosd.conf
RUN cp /home/admin/vmangos/etc/realmd.conf.dist /home/admin/vmangos/etc/realmd.conf
## 配置文件写入默认值
## mangosd.conf
RUN sed -i 's/^DataDir = "."$/DataDir = "\/home\/admin\/vmangos\/data"/g' /home/admin/vmangos/etc/mangosd.conf
RUN sed -i 's/^LogsDir = ""$/LogsDir = "\/home\/admin\/vmangos\/logs\/mangosd"/g' /home/admin/vmangos/etc/mangosd.conf
RUN sed -i 's/^HonorDir = ""$/HonorDir = "\/home\/admin\/vmangos\/logs\/honor"/g' /home/admin/vmangos/etc/mangosd.conf

RUN sed -i 's/^LoginDatabase\.Info.*$/LoginDatabase.Info              = "${realmdDBStr}"/g' /home/admin/vmangos/etc/mangosd.conf
RUN sed -i 's/^WorldDatabase\.Info.*$/WorldDatabase.Info              = "${mangosDBStr}"/g' /home/admin/vmangos/etc/mangosd.conf
RUN sed -i 's/^CharacterDatabase\.Info.*$/CharacterDatabase.Info          = "${characterDBStr}"/g' /home/admin/vmangos/etc/mangosd.conf
RUN sed -i 's/^LogsDatabase\.Info.*$/LogsDatabase.Info               = "${logsDBStr}"/g' /home/admin/vmangos/etc/mangosd.conf

RUN sed -i 's/^WorldServerPort.*$/WorldServerPort = ${mangosServerPort}/g' /home/admin/vmangos/etc/mangosd.conf

RUN sed -i 's/^WowPatch.*$/WowPatch = ${wowPatch}/g' /home/admin/vmangos/etc/mangosd.conf
RUN sed -i 's/^GameType.*$/GameType = ${gameType}/g' /home/admin/vmangos/etc/mangosd.conf
RUN sed -i 's/^TimeZoneOffset.*$/TimeZoneOffset = ${timeZoneOffset}/g' /home/admin/vmangos/etc/mangosd.conf
RUN sed -i 's/^Motd.*$/Motd = ${motd}/g' /home/admin/vmangos/etc/mangosd.conf

## realmd.conf
RUN sed -i 's/^LoginDatabaseInfo.*$/LoginDatabaseInfo = "${realmdDBStr}"/g' /home/admin/vmangos/etc/realmd.conf
RUN sed -i 's/^LogsDir.*$/LogsDir = "\/home\/admin\/vmangos\/logs\/realmd"/g' /home/admin/vmangos/etc/realmd.conf
RUN sed -i 's/^RealmServerPort.*$/RealmServerPort = ${realmServerPort}/g' /home/admin/vmangos/etc/realmd.conf

## 准备目录
RUN mkdir -p /home/admin/vmangos/logs/mangosd && mkdir -p /home/admin/vmangos/logs/realmd && mkdir -p /home/admin/vmangos/logs/honor
RUN mkdir -p /home/admin/vmangos/data

## 准备启动脚本
COPY run.sh /home/admin/vmangos
RUN chmod 755 /home/admin/vmangos/run.sh

## 所有文件授权admin
RUN chown -R admin:admin /home/admin/vmangos

## 暴露端口
EXPOSE 22/tcp
EXPOSE ${mangosServerPort}/tcp
EXPOSE ${realmServerPort}/tcp

ENTRYPOINT ["/bin/bash", "/home/admin/vmangos/run.sh"]
